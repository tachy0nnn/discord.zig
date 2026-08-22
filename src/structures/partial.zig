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
const builtin = std.builtin;

pub fn Partial(comptime T: type) type {
    const info = @typeInfo(T);
    switch (info) {
        .@"struct" => |s| {
            comptime var field_names: [s.fields.len][]const u8 = undefined;
            comptime var field_types: [s.fields.len]type = undefined;
            comptime var field_attrs: [s.fields.len]builtin.Type.StructField.Attributes = undefined;
            inline for (s.fields, 0..) |field, i| {
                if (field.is_comptime) {
                    @compileError("Cannot make Partial of " ++ @typeName(T) ++ ", it has a comptime field " ++ field.name);
                }
                const optional_type = switch (@typeInfo(field.type)) {
                    .optional => field.type,
                    else => ?field.type,
                };
                const default_value: optional_type = null;
                field_names[i] = field.name;
                field_types[i] = optional_type;
                field_attrs[i] = .{
                    .@"comptime" = false,
                    .@"align" = field.alignment,
                    .default_value_ptr = @ptrCast(&default_value),
                };
            }
            return @Struct(s.layout, s.backing_integer, &field_names, &field_types, &field_attrs);
        },
        else => @compileError("Cannot make Partial of " ++ @typeName(T) ++
            ", the type must be a struct"),
    }
}
