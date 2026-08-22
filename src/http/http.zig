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
const mem = std.mem;
const Io = std.Io;
const http = std.http;
const json = std.json;
const json_helpers = @import("../utils/json.zig");

pub const Result = @import("../errors.zig").Result;
pub const DiscordError = @import("../errors.zig").DiscordError;

pub const BASE_URL = "https://discord.com/api/v10";

// zig fmt: off
pub const MakeRequestError = anyerror;
// zig fmt: on

pub const FetchReq = struct {
    allocator: mem.Allocator,
    token: []const u8,
    client: http.Client,
    body: std.ArrayList(u8),
    /// internal
    extra_headers: std.ArrayList(http.Header),
    query_params: std.StringHashMap([]const u8),

    pub fn init(allocator: mem.Allocator, token: []const u8) FetchReq {
        const client = http.Client{
            .allocator = allocator,
            .io = std.Options.debug_io,
        };
        return FetchReq{
            .allocator = allocator,
            .client = client,
            .token = token,
            .body = .empty,
            .extra_headers = .empty,
            .query_params = std.StringHashMap([]const u8).init(allocator),
        };
    }

    pub fn deinit(self: *FetchReq) void {
        self.client.deinit();
        self.body.deinit(self.allocator);
        self.extra_headers.deinit(self.allocator);
        self.query_params.deinit();
    }

    pub fn addHeader(self: *FetchReq, name: []const u8, value: ?[]const u8) !void {
        if (value) |some|
            try self.extra_headers.append(self.allocator, http.Header{ .name = name, .value = some });
    }

    pub fn addQueryParam(self: *FetchReq, name: []const u8, value: anytype) !void {
        if (value == null)
            return;
        var buf: [256]u8 = undefined;
        try self.query_params.put(name, try std.fmt.bufPrint(&buf, "{any}", .{value}));
    }

    fn formatQueryParams(self: *FetchReq) ![]const u8 {
        if (self.query_params.count() == 0)
            return "";

        var query: std.ArrayList(u8) = .empty;
        errdefer query.deinit(self.allocator);

        try query.append(self.allocator, '?');
        var it = self.query_params.iterator();
        var first = true;
        while (it.next()) |kv| {
            if (!first) try query.append(self.allocator, '&');
            first = false;
            try query.appendSlice(self.allocator, kv.key_ptr.*);
            try query.append(self.allocator, '=');
            try query.appendSlice(self.allocator, kv.value_ptr.*);
        }

        return query.toOwnedSlice(self.allocator);
    }

    pub fn get(self: *FetchReq, comptime T: type, path: []const u8) !Result(T) {
        const result = try self.makeRequest(.GET, path, null);
        if (result.status != .ok)
            return try json_helpers.parseLeft(DiscordError, T, self.allocator, try self.body.toOwnedSlice(self.allocator));

        const output = try json_helpers.parseRight(DiscordError, T, self.allocator, try self.body.toOwnedSlice(self.allocator));
        return output;
    }

    pub fn delete(self: *FetchReq, path: []const u8) !Result(void) {
        const result = try self.makeRequest(.DELETE, path, null);
        if (result.status != .no_content)
            return try json_helpers.parseRight(DiscordError, void, self.allocator, try self.body.toOwnedSlice(self.allocator));

        return .ok({});
    }

    pub fn patch(self: *FetchReq, comptime T: type, path: []const u8, object: anytype) !Result(T) {
        var buf: [4096]u8 = undefined;
        const payload = try std.fmt.bufPrint(&buf, "{f}", .{json.fmt(object, .{})});
        const result = try self.makeRequest(.PATCH, path, payload);

        if (result.status != .ok)
            return try json_helpers.parseLeft(DiscordError, T, self.allocator, try self.body.toOwnedSlice(self.allocator));

        return try json_helpers.parseRight(DiscordError, T, self.allocator, try self.body.toOwnedSlice(self.allocator));
    }

    pub fn patch2(self: *FetchReq, path: []const u8, object: anytype) !void {
        var buf: [4096]u8 = undefined;
        const payload = try std.fmt.bufPrint(&buf, "{f}", .{json.fmt(object, .{})});
        const result = try self.makeRequest(.PATCH, path, payload);

        if (result.status != .no_content)
            return try json_helpers.parseLeft(DiscordError, void, self.allocator, try self.body.toOwnedSlice(self.allocator));

        return .ok({});
    }

    pub fn put(self: *FetchReq, comptime T: type, path: []const u8, object: anytype) !Result(T) {
        var buf: [4096]u8 = undefined;
        const payload = try std.fmt.bufPrint(&buf, "{f}", .{json.fmt(object, .{})});
        const result = try self.makeRequest(.PUT, path, payload);

        if (result.status != .ok)
            return try json_helpers.parseLeft(DiscordError, T, self.allocator, try self.body.toOwnedSlice(self.allocator));

        return try json_helpers.parseRight(DiscordError, T, self.allocator, try self.body.toOwnedSlice(self.allocator));
    }

    pub fn put2(self: *FetchReq, comptime T: type, path: []const u8, object: anytype) !Result(T) {
        var buf: [4096]u8 = undefined;
        const payload = try std.fmt.bufPrint(&buf, "{f}", .{json.fmt(object, .{})});
        const result = try self.makeRequest(.PUT, path, payload);

        if (result.status == .no_content)
            return try json_helpers.parseLeft(DiscordError, T, self.allocator, try self.body.toOwnedSlice(self.allocator));

        return try json_helpers.parseRight(DiscordError, T, self.allocator, try self.body.toOwnedSlice(self.allocator));
    }

    pub fn put3(self: *FetchReq, path: []const u8) !Result(void) {
        const result = try self.makeRequest(.PUT, path, null);

        if (result.status != .no_content)
            return try json_helpers.parseLeft(DiscordError, void, self.allocator, try self.body.toOwnedSlice(self.allocator));

        return .ok({});
    }

    pub fn put4(self: *FetchReq, comptime T: type, path: []const u8) !Result(T) {
        const result = try self.makeRequest(.PUT, path, null);

        if (result.status != .ok)
            return try json_helpers.parseLeft(DiscordError, T, self.allocator, try self.body.toOwnedSlice(self.allocator));

        return try json_helpers.parseRight(DiscordError, T, self.allocator, try self.body.toOwnedSlice(self.allocator));
    }

    pub fn put5(self: *FetchReq, path: []const u8, object: anytype) !Result(void) {
        var buf: [4096]u8 = undefined;
        const payload = try std.fmt.bufPrint(&buf, "{f}", .{json.fmt(object, .{})});
        const result = try self.makeRequest(.PUT, path, payload);

        if (result.status != .no_content)
            return try json_helpers.parseLeft(DiscordError, void, self.allocator, try self.body.toOwnedSlice(self.allocator));

        return .ok({});
    }

    pub fn post(self: *FetchReq, comptime T: type, path: []const u8, object: anytype) !Result(T) {
        var buf: [4096]u8 = undefined;
        const payload = try std.fmt.bufPrint(&buf, "{f}", .{json.fmt(object, .{ .emit_null_optional_fields = true })});
        const result = try self.makeRequest(.POST, path, payload);

        if (result.status != .ok and result.status != .created and result.status != .accepted)
            return try json_helpers.parseLeft(DiscordError, T, self.allocator, try self.body.toOwnedSlice(self.allocator));

        return try json_helpers.parseRight(DiscordError, T, self.allocator, try self.body.toOwnedSlice(self.allocator));
    }

    pub fn post2(self: *FetchReq, comptime T: type, path: []const u8) !Result(T) {
        const result = try self.makeRequest(.POST, path, null);

        if (result.status != .ok)
            return try json_helpers.parseLeft(DiscordError, T, self.allocator, try self.body.toOwnedSlice(self.allocator));

        return try json_helpers.parseRight(DiscordError, T, self.allocator, try self.body.toOwnedSlice(self.allocator));
    }

    pub fn post3(
        self: *FetchReq,
        comptime T: type,
        path: []const u8,
        object: anytype,
        files: []const FileData,
    ) !Result(T) {
        var buf: [4096]u8 = undefined;
        const payload = try std.fmt.bufPrint(&buf, "{f}", .{json.fmt(object, .{ .emit_null_optional_fields = true })});
        const result = try self.makeRequestWithFiles(.POST, path, payload, files);

        if (result.status != .ok)
            return try json_helpers.parseLeft(DiscordError, T, self.allocator, try self.body.toOwnedSlice(self.allocator));

        return try json_helpers.parseRight(DiscordError, T, self.allocator, try self.body.toOwnedSlice(self.allocator));
    }

    pub fn post4(self: *FetchReq, path: []const u8, object: anytype) !Result(void) {
        var buf: [4096]u8 = undefined;
        const payload = try std.fmt.bufPrint(&buf, "{f}", .{json.fmt(object, .{ .emit_null_optional_fields = true })});
        const result = try self.makeRequest(.POST, path, payload);

        if (result.status != .no_content)
            return try json_helpers.parseLeft(DiscordError, void, self.allocator, try self.body.toOwnedSlice(self.allocator));

        return .ok({});
    }

    pub fn post5(self: *FetchReq, path: []const u8) !Result(void) {
        const result = try self.makeRequest(.POST, path, null);

        if (result.status != .no_content)
            return try json_helpers.parseLeft(DiscordError, void, self.allocator, try self.body.toOwnedSlice(self.allocator));

        return .ok({});
    }

    pub fn makeRequest(
        self: *FetchReq,
        method: http.Method,
        path: []const u8,
        to_post: ?[]const u8,
    ) MakeRequestError!http.Client.FetchResult {
        var buf: [256]u8 = undefined;
        const constructed = try std.fmt.bufPrint(&buf, "{s}{s}{s}", .{ BASE_URL, path, try self.formatQueryParams() });

        try self.extra_headers.append(self.allocator, http.Header{ .name = "Accept", .value = "application/json" });
        try self.extra_headers.append(self.allocator, http.Header{ .name = "Content-Type", .value = "application/json" });
        try self.extra_headers.append(self.allocator, http.Header{ .name = "Authorization", .value = self.token });

        var response_writer: Io.Writer.Allocating = .fromArrayList(self.allocator, &self.body);
        defer self.body = response_writer.toArrayList();

        var fetch_options = http.Client.FetchOptions{
            .location = http.Client.FetchOptions.Location{ .url = constructed },
            .method = method,
            .extra_headers = try self.extra_headers.toOwnedSlice(self.allocator),
            .response_writer = &response_writer.writer,
        };

        if (to_post != null) {
            fetch_options.payload = to_post;
        }

        const res = try self.client.fetch(fetch_options);
        return res;
    }

    pub fn makeRequestWithFiles(
        self: *FetchReq,
        method: http.Method,
        path: []const u8,
        to_post: []const u8,
        files: []const FileData,
    ) !http.Client.FetchResult {
        var form_fields = try std.ArrayList(FormField).initCapacity(self.allocator, files.len + 1);
        defer form_fields.deinit(self.allocator);

        for (files, 0..) |file, i|
            form_fields.appendAssumeCapacity(.{
                .name = try std.fmt.allocPrint(self.allocator, "files[{d}]", .{i}),
                .filename = file.filename,
                .value = file.value,
                .content_type = .{ .override = try file.type.string() },
            });

        form_fields.appendAssumeCapacity(.{
            .name = "payload_json",
            .value = to_post,
            .content_type = .{ .override = "application/json" },
        });

        var boundary: [64 + 3]u8 = undefined;
        std.debug.assert((std.fmt.bufPrint(
            &boundary,
            "{x:0>16}-{x:0>16}-{x:0>16}-{x:0>16}",
            .{ std.crypto.random.int(u64), std.crypto.random.int(u64), std.crypto.random.int(u64), std.crypto.random.int(u64) },
        ) catch unreachable).len == boundary.len);

        const body = try createMultiPartFormDataBody(
            self.allocator,
            &boundary,
            form_fields.items,
        );

        const headers: std.http.Client.Request.Headers = .{
            .content_type = .{ .override = try std.fmt.allocPrint(self.allocator, "multipart/form-data; boundary={s}", .{boundary}) },
            .authorization = .{ .override = self.token },
        };

        var uri_buf: [256]u8 = undefined;
        const uri = try std.Uri.parse(try std.fmt.bufPrint(&uri_buf, "{s}{s}{s}", .{ BASE_URL, path, try self.formatQueryParams() }));

        var server_header_buffer: [16 * 1024]u8 = undefined;
        var request = try self.client.open(method, uri, .{
            .keep_alive = false,
            .server_header_buffer = &server_header_buffer,
            .headers = headers,
            .extra_headers = try self.extra_headers.toOwnedSlice(self.allocator),
        });
        defer request.deinit();
        request.transfer_encoding = .{ .content_length = body.len };

        try request.send();
        try request.writeAll(body);

        try request.finish();
        try request.wait();

        try request.reader().readAllArrayList(&self.body, 2 * 1024 * 1024);

        if (request.response.status.class() == .success)
            return .{ .status = request.response.status };
        return error.FailedRequest; // TODO: make an Either type lol
    }
};

pub const FileData = struct {
    filename: []const u8,
    value: []const u8,
    type: union(enum) {
        jpg,
        jpeg,
        png,
        webp,
        gif,
        pub fn string(self: @This()) ![]const u8 {
            var buf: [256]u8 = undefined;
            return std.fmt.bufPrint(&buf, "image/{s}", .{@tagName(self)});
        }
    },
};

pub const FormField = struct {
    name: []const u8,
    filename: ?[]const u8 = null,
    content_type: std.http.Client.Request.Headers.Value = .default,
    value: []const u8,
};

fn createMultiPartFormDataBody(
    allocator: std.mem.Allocator,
    boundary: []const u8,
    fields: []const FormField,
) error{OutOfMemory}![]const u8 {
    var body: std.ArrayList(u8) = .empty;
    errdefer body.deinit(allocator);

    for (fields) |field| {
        try body.print(allocator, "--{s}\r\n", .{boundary});

        if (field.filename) |filename| {
            try body.print(allocator, "Content-Disposition: form-data; name=\"{s}\"; filename=\"{s}\"\r\n", .{ field.name, filename });
        } else {
            try body.print(allocator, "Content-Disposition: form-data; name=\"{s}\"\r\n", .{field.name});
        }

        switch (field.content_type) {
            .default => {
                if (field.filename != null) {
                    try body.appendSlice(allocator, "Content-Type: application/octet-stream\r\n");
                }
            },
            .omit => {},
            .override => |content_type| {
                try body.print(allocator, "Content-Type: {s}\r\n", .{content_type});
            },
        }

        try body.appendSlice(allocator, "\r\n");
        try body.appendSlice(allocator, field.value);
        try body.appendSlice(allocator, "\r\n");
    }
    try body.print(allocator, "--{s}--\r\n", .{boundary});

    return try body.toOwnedSlice(allocator);
}
