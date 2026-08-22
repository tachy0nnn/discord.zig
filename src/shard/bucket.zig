const std = @import("std");
const mem = std.mem;
const math = std.math;
const time = std.time;
const atomic = std.atomic;
const Thread = std.Thread;
const PriorityQueue = std.PriorityQueue;

fn milliTimestamp() u64 {
    return @intCast(std.Io.Clock.real.now(std.Options.debug_io).toMilliseconds());
}

pub const Bucket = struct {
    pub const RequestWithPrio = struct {
        callback: *const fn () void,
        priority: u32 = 1,
    };

    fn lessthan(_: void, a: RequestWithPrio, b: RequestWithPrio) math.Order {
        return math.order(a.priority, b.priority);
    }

    /// The queue of requests to acquire an available request.
    /// Mapped by (shardId, RequestWithPrio)
    queue: PriorityQueue(RequestWithPrio, void, lessthan),
    allocator: mem.Allocator,

    limit: usize,
    refill_interval: u64,
    refill_amount: usize,

    /// The amount of requests that have been used up already.
    used: usize = 0,

    /// Whether or not the queue is already processing.
    processing: bool = false,

    /// Whether the timeout should be killed because there is already one running
    should_stop: atomic.Value(bool) = .init(false),

    /// The timestamp in milliseconds when the next refill is scheduled.
    refills_at: ?u64 = null,

    pub fn init(allocator: mem.Allocator, limit: usize, refill_interval: u64, refill_amount: usize) Bucket {
        return .{
            .queue = PriorityQueue(RequestWithPrio, void, lessthan).initContext({}),
            .allocator = allocator,
            .limit = limit,
            .refill_interval = refill_interval,
            .refill_amount = refill_amount,
        };
    }

    fn remaining(self: *Bucket) usize {
        if (self.limit < self.used) {
            return 0;
        } else {
            return self.limit - self.used;
        }
    }

    pub fn refill(self: *Bucket) Thread.SpawnError!void {
        // Lower the used amount by the refill amount
        self.used = if (self.refill_amount > self.used) 0 else self.used - self.refill_amount;

        // Reset the refills_at timestamp since it just got refilled
        self.refills_at = null;

        if (self.used > 0) {
            if (self.should_stop.load(.monotonic) == true) {
                self.should_stop.store(false, .monotonic);
            }
            const thread = try Thread.spawn(.{}, Bucket.timeout, .{self});
            thread.detach;
            self.refills_at = milliTimestamp() + self.refill_interval;
        }
    }

    fn timeout(self: *Bucket) void {
        while (!self.should_stop.load(.monotonic)) {
            self.refill();
            std.Io.sleep(
                std.Options.debug_io,
                std.Io.Duration.fromNanoseconds(@intCast(time.ns_per_ms * self.refill_interval)),
                .awake,
            ) catch unreachable;
        }
    }

    pub fn processQueue(self: *Bucket) std.Thread.SpawnError!void {
        if (self.processing) return;

        while (self.queue.pop()) |first_element| {
            if (self.remaining() != 0) {
                first_element.callback();
                self.used += 1;

                if (!self.should_stop.load(.monotonic)) {
                    const thread = try Thread.spawn(.{}, Bucket.timeout, .{self});
                    thread.detach;
                    self.refills_at = milliTimestamp() + self.refill_interval;
                }
            } else if (self.refills_at) |ra| {
                const now = milliTimestamp();
                if (ra > now) {
                    std.Io.sleep(
                        std.Options.debug_io,
                        std.Io.Duration.fromNanoseconds(@intCast(time.ns_per_ms * (ra - now))),
                        .awake,
                    ) catch unreachable;
                }
            }
        }

        self.processing = false;
    }

    pub fn acquire(self: *Bucket, rq: RequestWithPrio) !void {
        try self.queue.push(self.allocator, rq);
        try self.processQueue();
    }
};
