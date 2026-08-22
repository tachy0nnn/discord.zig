//! ISC License
//!
//! Copyright (c) 2024-2025 Yuzu
//! Copyright (c) 2026 Yon
//!
//! Permission to use, copy, modify, and/or distribute this software for any
//! purpose with or without fee is hereby granted, provided that the above
//! copyright notice and this permission notice appear in all copies.
//!
//! THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
//! REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
//! AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
//! INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
//! LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
//! OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
//! PERFORMANCE OF THIS SOFTWARE.

const std = @import("std");

pub const Mutex = struct {
    state: std.atomic.Value(bool) = .init(false),

    pub fn lock(self: *Mutex) void {
        while (self.state.cmpxchgWeak(false, true, .acquire, .monotonic) != null) {
            std.Thread.yield() catch {};
        }
    }

    pub fn unlock(self: *Mutex) void {
        self.state.store(false, .release);
    }

    pub fn tryLock(self: *Mutex) bool {
        return self.state.cmpxchgStrong(false, true, .acquire, .monotonic) == null;
    }
};

pub const RwLock = struct {
    mutex: Mutex = .{},

    pub fn lock(self: *RwLock) void {
        self.mutex.lock();
    }

    pub fn unlock(self: *RwLock) void {
        self.mutex.unlock();
    }

    pub fn lockShared(self: *RwLock) void {
        self.mutex.lock();
    }

    pub fn unlockShared(self: *RwLock) void {
        self.mutex.unlock();
    }
};

pub const ThreadPool = struct {
    allocator: std.mem.Allocator = undefined,
    threads: []std.Thread = &[_]std.Thread{},
    mutex: Mutex = .{},
    run_queue: TaskQueue = .{},
    is_running: std.atomic.Value(bool) = .init(true),

    pub const Options = struct {
        allocator: std.mem.Allocator,
        n_jobs: ?usize = null,
    };

    const Task = struct {
        run_fn: *const fn (*Task) void,
        next: ?*Task = null,
    };

    const TaskQueue = struct {
        head: ?*Task = null,
        tail: ?*Task = null,

        fn push(self: *TaskQueue, task: *Task) void {
            task.next = null;
            if (self.tail) |tail| {
                tail.next = task;
                self.tail = task;
            } else {
                self.head = task;
                self.tail = task;
            }
        }

        fn pop(self: *TaskQueue) ?*Task {
            const head = self.head orelse return null;
            self.head = head.next;
            if (self.head == null) {
                self.tail = null;
            }
            return head;
        }
    };

    pub fn init(self: *ThreadPool, options: Options) !void {
        const num_threads = if (options.n_jobs) |n| (if (n == 0) 1 else n) else (std.Thread.getCpuCount() catch 1);
        const threads = try options.allocator.alloc(std.Thread, num_threads);
        errdefer options.allocator.free(threads);

        self.* = .{
            .allocator = options.allocator,
            .threads = threads,
            .mutex = .{},
            .run_queue = .{},
            .is_running = .init(true),
        };

        var spawned: usize = 0;
        errdefer {
            self.is_running.store(false, .release);
            for (threads[0..spawned]) |thread| {
                thread.join();
            }
        }

        for (threads) |*thread| {
            thread.* = try std.Thread.spawn(.{}, worker, .{self});
            spawned += 1;
        }
    }

    pub fn deinit(self: *ThreadPool) void {
        if (self.threads.len == 0) return;
        self.is_running.store(false, .release);
        for (self.threads) |thread| {
            thread.join();
        }
        self.allocator.free(self.threads);
        self.threads = &[_]std.Thread{};
    }

    fn worker(self: *ThreadPool) void {
        while (self.is_running.load(.acquire)) {
            const maybe_task = blk: {
                self.mutex.lock();
                defer self.mutex.unlock();
                break :blk self.run_queue.pop();
            };

            if (maybe_task) |task| {
                task.run_fn(task);
            } else {
                std.Io.sleep(
                    std.Options.debug_io,
                    std.Io.Duration.fromNanoseconds(std.time.ns_per_ms),
                    .awake,
                ) catch unreachable;
            }
        }

        // drain queue on shutdown
        while (true) {
            const maybe_task = blk: {
                self.mutex.lock();
                defer self.mutex.unlock();
                break :blk self.run_queue.pop();
            };
            if (maybe_task) |task| {
                task.run_fn(task);
            } else break;
        }
    }

    pub fn spawn(self: *ThreadPool, comptime function: anytype, args: anytype) !void {
        const Args = @TypeOf(args);
        const Closure = struct {
            task: Task,
            allocator: std.mem.Allocator,
            args: Args,

            fn run(base: *Task) void {
                const closure: *@This() = @fieldParentPtr("task", base);
                defer closure.allocator.destroy(closure);
                @call(.auto, function, closure.args);
            }
        };

        const closure = try self.allocator.create(Closure);
        closure.* = .{
            .task = .{ .run_fn = Closure.run },
            .allocator = self.allocator,
            .args = args,
        };

        self.mutex.lock();
        defer self.mutex.unlock();
        self.run_queue.push(&closure.task);
    }
};
