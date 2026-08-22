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
const zlib = @cImport({
    @cInclude("zlib.h");
});

pub const ZlibStream = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    stream: *zlib.z_stream,
    initialized: bool = false,

    pub fn init(allocator: std.mem.Allocator) !Self {
        const stream = try allocator.create(zlib.z_stream);
        errdefer allocator.destroy(stream);

        stream.* = std.mem.zeroes(zlib.z_stream);
        var self = Self{
            .allocator = allocator,
            .stream = stream,
        };

        const result = zlib.inflateInit2_(self.stream, 15, zlib.ZLIB_VERSION, @sizeOf(zlib.z_stream));
        if (result != zlib.Z_OK) return error.ZlibInitFailed;
        self.initialized = true;
        return self;
    }

    pub fn deinit(self: *Self) void {
        if (self.initialized) {
            _ = zlib.inflateEnd(self.stream);
            self.initialized = false;
        }
        self.allocator.destroy(self.stream);
    }

    pub fn reset(self: *Self) !void {
        if (zlib.inflateReset(self.stream) != zlib.Z_OK)
            return error.ZlibResetFailed;
    }

    pub fn hasFlushSuffix(data: []const u8) bool {
        return std.mem.endsWith(u8, data, &[_]u8{ 0x00, 0x00, 0xFF, 0xFF });
    }

    /// Feed one or more bytes from the current zlib stream into the persistent
    /// inflater. Discord's transport stream ends each Gateway payload with
    /// Z_SYNC_FLUSH, not with a final zlib footer, so `Z_OK` with no remaining
    /// input is the expected result for a complete payload.
    pub fn decompress(self: *Self, chunk: []const u8) ![]u8 {
        var output: std.ArrayListUnmanaged(u8) = .empty;
        errdefer output.deinit(self.allocator);

        var output_buffer: [std.compress.flate.max_window_len]u8 = undefined;
        self.stream.next_in = @constCast(chunk.ptr);
        self.stream.avail_in = @intCast(chunk.len);

        while (self.stream.avail_in > 0) {
            self.stream.next_out = @ptrCast(&output_buffer);
            self.stream.avail_out = @intCast(output_buffer.len);

            const result = zlib.inflate(self.stream, zlib.Z_NO_FLUSH);
            const produced = output_buffer.len - @as(usize, @intCast(self.stream.avail_out));
            try output.appendSlice(self.allocator, output_buffer[0..produced]);

            if (result == zlib.Z_STREAM_END)
                return error.ZlibStreamEnded;
            if (result == zlib.Z_BUF_ERROR and self.stream.avail_in == 0)
                break;
            if (result != zlib.Z_OK)
                return error.ZlibDecompressFailed;
            if (produced == 0 and self.stream.avail_in > 0)
                return error.ZlibNoProgress;
        }

        return output.toOwnedSlice(self.allocator);
    }
};

test "discord zlib-stream payloads" {
    var stream = try ZlibStream.init(std.testing.allocator);
    defer stream.deinit();

    const first = [_]u8{
        0x78, 0x9C, 0xCA, 0x48, 0xCD, 0xC9, 0xC9, 0x07,
        0x00, 0x00, 0x00, 0xFF, 0xFF,
    };
    const second = [_]u8{
        0x52, 0x28, 0xCF, 0x2F, 0xCA, 0x49, 0x01,
        0x00, 0x00, 0x00, 0xFF, 0xFF,
    };

    const first_decoded = try stream.decompress(&first);
    defer std.testing.allocator.free(first_decoded);
    try std.testing.expectEqualStrings("hello", first_decoded);

    const second_decoded = try stream.decompress(&second);
    defer std.testing.allocator.free(second_decoded);
    try std.testing.expectEqualStrings(" world", second_decoded);
}

test "discord zlib-stream can reset for a new connection" {
    var stream = try ZlibStream.init(std.testing.allocator);
    defer stream.deinit();

    const payload = [_]u8{
        0x78, 0x9C, 0xCA, 0x48, 0xCD, 0xC9, 0xC9, 0x07,
        0x00, 0x00, 0x00, 0xFF, 0xFF,
    };

    const first = try stream.decompress(&payload);
    defer std.testing.allocator.free(first);
    try std.testing.expectEqualStrings("hello", first);

    try stream.reset();

    const second = try stream.decompress(&payload);
    defer std.testing.allocator.free(second);
    try std.testing.expectEqualStrings("hello", second);
}

test "discord zlib flush suffix detection handles split reads" {
    try std.testing.expect(!ZlibStream.hasFlushSuffix(&[_]u8{ 0x01, 0x02, 0x00, 0x00, 0x00 }));
    try std.testing.expect(ZlibStream.hasFlushSuffix(&[_]u8{ 0x01, 0x02, 0x00, 0x00, 0xFF, 0xFF }));
}
