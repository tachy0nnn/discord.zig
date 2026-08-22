//! ISC License
//!
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
//! OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE
//! OF THIS SOFTWARE.

const std = @import("std");
const Snowflake = @import("snowflake.zig").Snowflake;
const MessageComponentTypes = @import("shared.zig").MessageComponentTypes;

pub const UnfurledMediaItem = struct {
    url: []const u8,
    proxy_url: ?[]const u8 = null,
    height: ?u32 = null,
    width: ?u32 = null,
    content_type: ?[]const u8 = null,
    ephemeral: ?bool = null,
    attachment_id: ?Snowflake = null,
};

pub const Section = struct {
    id: ?i32 = null,
    components: []TextDisplay,
    accessory: SectionAccessory,
};

pub const SectionAccessory = union(enum) {
    button: @import("component.zig").Button,
    thumbnail: Thumbnail,
};

pub const TextDisplay = struct {
    id: ?i32 = null,
    content: []const u8,
};

pub const Thumbnail = struct {
    id: ?i32 = null,
    media: UnfurledMediaItem,
    description: ?[]const u8 = null,
    spoiler: ?bool = null,
};

pub const MediaGalleryItem = struct {
    media: UnfurledMediaItem,
    description: ?[]const u8 = null,
    spoiler: ?bool = null,
};

pub const MediaGallery = struct {
    id: ?i32 = null,
    items: []MediaGalleryItem,
};

pub const File = struct {
    id: ?i32 = null,
    file: UnfurledMediaItem,
    spoiler: ?bool = null,
    name: ?[]const u8 = null,
    size: ?u64 = null,
};

pub const SeparatorSpacing = enum(u8) {
    Small = 1,
    Large = 2,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

pub const Separator = struct {
    id: ?i32 = null,
    divider: ?bool = null,
    spacing: ?SeparatorSpacing = null,
};

pub const Container = struct {
    id: ?i32 = null,
    components: []MessageComponentV2,
    accent_color: ?u32 = null,
    spoiler: ?bool = null,
};

pub const Label = struct {
    id: ?i32 = null,
    label: []const u8,
    description: ?[]const u8 = null,
    component: @import("component.zig").MessageComponent,
};

pub const FileUpload = struct {
    id: ?i32 = null,
    custom_id: []const u8,
    min_values: ?u8 = null,
    max_values: ?u8 = null,
    required: ?bool = null,
    file_types: ?[][]const u8 = null,
};

pub const RadioGroupOption = struct {
    value: []const u8,
    label: []const u8,
    description: ?[]const u8 = null,
    default: ?bool = null,
};

pub const RadioGroup = struct {
    id: ?i32 = null,
    custom_id: []const u8,
    options: []RadioGroupOption,
    required: ?bool = null,
};

pub const CheckboxGroupOption = struct {
    value: []const u8,
    label: []const u8,
    description: ?[]const u8 = null,
    default: ?bool = null,
};

pub const CheckboxGroup = struct {
    id: ?i32 = null,
    custom_id: []const u8,
    options: []CheckboxGroupOption,
    min_values: ?u8 = null,
    max_values: ?u8 = null,
    required: ?bool = null,
};

pub const Checkbox = struct {
    id: ?i32 = null,
    custom_id: []const u8,
    required: ?bool = null,
};

/// Components V2 are represented separately from legacy message components so
/// callers cannot accidentally mix incompatible payload shapes.
pub const MessageComponentV2 = struct {
    type: MessageComponentTypes,
    data: Data,

    pub const Data = union(enum) {
        section: Section,
        text_display: TextDisplay,
        thumbnail: Thumbnail,
        media_gallery: MediaGallery,
        file: File,
        separator: Separator,
        container: Container,
        label: Label,
        file_upload: FileUpload,
        radio_group: RadioGroup,
        checkbox_group: CheckboxGroup,
        checkbox: Checkbox,
    };
};
