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

const Partial = @import("partial.zig").Partial;
const Snowflake = @import("snowflake.zig").Snowflake;
const Emoji = @import("emoji.zig").Emoji;
const ButtonStyles = @import("shared.zig").ButtonStyles;
const ChannelTypes = @import("shared.zig").ChannelTypes;
const MessageComponentTypes = @import("shared.zig").MessageComponentTypes;
const AttachmentFlags = @import("shared.zig").AttachmentFlags;

const std = @import("std");

/// https://docs.discord.food/resources/components#button
pub const Button = struct {
    /// 2 for a button
    type: MessageComponentTypes,
    /// An optional identifier for the component
    id: ?i64 = null,
    /// A button style
    style: ButtonStyles,
    /// Text that appears on the button; max 80 characters
    label: ?[]const u8 = null,
    /// name, id, and animated
    emoji: ?Partial(Emoji) = null,
    /// Developer-defined identifier for the button; max 100 characters
    custom_id: []const u8,
    /// Identifier for a purchasable SKU, only available when using premium-style buttons
    sku_id: ?Snowflake = null,
    /// URL for link-style buttons
    url: ?[]const u8 = null,
    /// Whether the button is disabled (defaults to false)
    disabled: ?bool = null,
};

/// https://docs.discord.food/resources/components#select-option-structure
pub const SelectOption = struct {
    /// User-facing name of the option; max 100 characters
    label: []const u8,
    /// Dev-defined value of the option; max 100 characters
    value: []const u8,
    /// Additional description of the option; max 100 characters
    description: ?[]const u8 = null,
    /// id, name, and animated
    emoji: ?Partial(Emoji) = null,
    /// Will show this option as selected by default
    default: ?bool = null,
};

/// https://docs.discord.food/resources/components#select-default-value-structure
pub const DefaultValue = struct {
    /// ID of a user, role, or channel
    id: Snowflake,
    /// Type of value that id represents. Either "user", "role", or "channel"
    type: union(enum) { user, role, channel },
};

/// https://docs.discord.com/developers/components/reference#string-select
pub const SelectMenuString = struct {
    /// Type of select menu component (text: 3, user: 5, role: 6, mentionable: 7, channels: 8)
    type: MessageComponentTypes,
    /// ID for the select menu; max 100 characters
    custom_id: []const u8,
    /// Specified choices in a select menu (only required and available for string selects (type 3); max 25
    /// * options is required for string select menus (component type 3), and unavailable for all other select menu components.
    options: ?[]SelectOption = null,
    /// Placeholder text if nothing is selected; max 150 characters
    placeholder: ?[]const u8 = null,
    /// Minimum number of items that must be chosen (defaults to 1); min 0, max 25
    min_values: ?usize = null,
    /// Maximum number of items that can be chosen (defaults to 1); max 25
    max_values: ?usize = null,
    /// Whether select menu is disabled (defaults to false)
    disabled: ?bool = null,
};

/// https://discord.com/developers/docs/interactions/message-components#select-menus
pub const SelectMenuUsers = struct {
    /// Type of select menu component (text: 3, user: 5, role: 6, mentionable: 7, channels: 8)
    type: MessageComponentTypes,
    /// ID for the select menu; max 100 characters
    custom_id: []const u8,
    /// Placeholder text if nothing is selected; max 150 characters
    placeholder: ?[]const u8 = null,
    /// List of default values for auto-populated select menu components; number of default values must be in the range defined by min_values and max_values
    /// *** default_values is only available for auto-populated select menu components, which include user (5), role (6), mentionable (7), and channel (8) components.
    default_values: ?[]DefaultValue = null,
    /// Minimum number of items that must be chosen (defaults to 1); min 0, max 25
    min_values: ?usize = null,
    /// Maximum number of items that can be chosen (defaults to 1); max 25
    max_values: ?usize = null,
    /// Whether select menu is disabled (defaults to false)
    disabled: ?bool = null,
};

/// https://discord.com/developers/docs/interactions/message-components#select-menus
pub const SelectMenuRoles = struct {
    /// Type of select menu component (text: 3, user: 5, role: 6, mentionable: 7, channels: 8)
    type: MessageComponentTypes,
    /// ID for the select menu; max 100 characters
    custom_id: []const u8,
    /// Placeholder text if nothing is selected; max 150 characters
    placeholder: ?[]const u8 = null,
    /// List of default values for auto-populated select menu components; number of default values must be in the range defined by min_values and max_values
    /// *** default_values is only available for auto-populated select menu components, which include user (5), role (6), mentionable (7), and channel (8) components.
    default_values: ?[]DefaultValue = null,
    /// Minimum number of items that must be chosen (defaults to 1); min 0, max 25
    min_values: ?usize = null,
    /// Maximum number of items that can be chosen (defaults to 1); max 25
    max_values: ?usize = null,
    /// Whether select menu is disabled (defaults to false)
    disabled: ?bool = null,
};

/// https://discord.com/developers/docs/interactions/message-components#select-menus
pub const SelectMenuUsersAndRoles = struct {
    /// Type of select menu component (text: 3, user: 5, role: 6, mentionable: 7, channels: 8)
    type: MessageComponentTypes,
    /// ID for the select menu; max 100 characters
    custom_id: []const u8,
    /// Placeholder text if nothing is selected; max 150 characters
    placeholder: ?[]const u8 = null,
    /// List of default values for auto-populated select menu components; number of default values must be in the range defined by min_values and max_values
    /// *** default_values is only available for auto-populated select menu components, which include user (5), role (6), mentionable (7), and channel (8) components.
    default_values: ?[]DefaultValue = null,
    /// Minimum number of items that must be chosen (defaults to 1); min 0, max 25
    min_values: ?usize = null,
    /// Maximum number of items that can be chosen (defaults to 1); max 25
    max_values: ?usize = null,
    /// Whether select menu is disabled (defaults to false)
    disabled: ?bool = null,
};

/// https://discord.com/developers/docs/interactions/message-components#select-menus
pub const SelectMenuChannels = struct {
    /// Type of select menu component (text: 3, user: 5, role: 6, mentionable: 7, channels: 8)
    type: MessageComponentTypes,
    /// ID for the select menu; max 100 characters
    custom_id: []const u8,
    /// List of channel types to include in the channel select component (type 8)
    /// ** channel_types can only be used for channel select menu components.
    channel_types: ?[]ChannelTypes = null,
    /// Placeholder text if nothing is selected; max 150 characters
    placeholder: ?[]const u8 = null,
    /// List of default values for auto-populated select menu components; number of default values must be in the range defined by min_values and max_values
    /// *** default_values is only available for auto-populated select menu components, which include user (5), role (6), mentionable (7), and channel (8) components.
    default_values: ?[]DefaultValue = null,
    /// Minimum number of items that must be chosen (defaults to 1); min 0, max 25
    min_values: ?usize = null,
    /// Maximum number of items that can be chosen (defaults to 1); max 25
    max_values: ?usize = null,
    /// Whether select menu is disabled (defaults to false)
    disabled: ?bool = null,
};

pub const SelectMenu = union(enum) {
    StringSelect: SelectMenuString,
    UserSelect: SelectMenuUsers,
    RoleSelect: SelectMenuRoles,
    MentionableSelect: SelectMenuUsersAndRoles,
    ChannelSelect: SelectMenuChannels,

    pub fn jsonParse(allocator: std.mem.Allocator, src: anytype, _: std.json.ParseOptions) !@This() {
        const value = try std.json.innerParse(std.json.Value, allocator, src, .{
            .ignore_unknown_fields = true,
            .max_value_len = 0x1000,
        });

        if (value != .object) @panic("coulnd't match against non-object type");

        switch (value.object.get("type") orelse @panic("couldn't find property `type`")) {
            .integer => |num| return switch (@as(MessageComponentTypes, @enumFromInt(num))) {
                .StringSelect => .{ .StringSelect = try std.json.parseFromValueLeaky(SelectMenuString, allocator, value, .{
                    .ignore_unknown_fields = true,
                    .max_value_len = 0x1000,
                }) },
                .UserSelect => .{ .UserSelect = try std.json.parseFromValueLeaky(SelectMenuUsers, allocator, value, .{
                    .ignore_unknown_fields = true,
                    .max_value_len = 0x1000,
                }) },
                .RoleSelect => .{ .RoleSelect = try std.json.parseFromValueLeaky(SelectMenuRoles, allocator, value, .{
                    .ignore_unknown_fields = true,
                    .max_value_len = 0x1000,
                }) },
                .MentionableSelect => .{ .MentionableSelect = try std.json.parseFromValueLeaky(SelectMenuUsersAndRoles, allocator, value, .{
                    .ignore_unknown_fields = true,
                    .max_value_len = 0x1000,
                }) },
                .ChannelSelect => .{ .ChannelSelect = try std.json.parseFromValueLeaky(SelectMenuChannels, allocator, value, .{
                    .ignore_unknown_fields = true,
                    .max_value_len = 0x1000,
                }) },
            },
            else => @panic("got type but couldn't match against non enum member `type`"),
        }

        return try MessageComponent.json(allocator, value);
    }

    // legacy
    pub fn json(_: std.mem.Allocator) !SelectMenu {
        @compileError("Deprecated, use std.json instead.");
    }
};

pub const InputTextStyles = enum(u4) {
    Short = 1,
    Paragraph,
};

pub const InputText = struct {
    /// 4 for a text input
    type: MessageComponentTypes,
    /// Developer-defined identifier for the input; max 100 characters
    custom_id: []const u8,
    /// The Text Input Style
    style: InputTextStyles,
    /// Label for this component; max 45 characters
    label: []const u8,
    /// Minimum input length for a text input; min 0, max 4000
    min_length: ?usize = null,
    /// Maximum input length for a text input; min 1, max 4000
    max_length: ?usize = null,
    /// Whether this component is required to be filled (defaults to true)
    required: ?bool = null,
    /// Pre-filled value for this component; max 4000 characters
    value: ?[]const u8 = null,
    /// Custom placeholder text if the input is empty; max 100 characters
    placeholder: ?[]const u8 = null,
};

pub const MessageComponent = union(enum) {
    ActionRow: []MessageComponent,
    Button: Button,
    StringSelect: SelectMenuString,
    InputText: InputText,
    UserSelect: SelectMenuUsers,
    RoleSelect: SelectMenuRoles,
    MentionableSelect: SelectMenuUsersAndRoles,
    ChannelSelect: SelectMenuChannels,

    /// zjson parse
    /// legacy
    pub fn json(_: std.mem.Allocator) void {
        @compileError("Deprecated, use std.json instead.");
    }

    pub fn jsonParse(allocator: std.mem.Allocator, src: anytype, _: std.json.ParseOptions) !@This() {
        const value = try std.json.innerParse(std.json.Value, allocator, src, .{
            .ignore_unknown_fields = true,
            .max_value_len = 0x1000,
        });

        if (value != .object) @panic("coulnd't match against non-object type");

        switch (value.object.get("type") orelse @panic("couldn't find property `type`")) {
            .integer => |num| return switch (@as(MessageComponentTypes, @enumFromInt(num))) {
                .ActionRow => .{ .ActionRow = try std.json.parseFromValueLeaky([]MessageComponent, allocator, value, .{
                    .ignore_unknown_fields = true,
                    .max_value_len = 0x1000,
                }) },
                .Button => .{ .Button = try std.json.parseFromValueLeaky(Button, allocator, value, .{
                    .ignore_unknown_fields = true,
                    .max_value_len = 0x1000,
                }) },
                .StringSelect => .{ .StringSelect = try std.json.parseFromValueLeaky(SelectMenuString, allocator, value, .{
                    .ignore_unknown_fields = true,
                    .max_value_len = 0x1000,
                }) },
                .InputText => .{ .InputText = try std.json.parseFromValueLeaky(InputText, allocator, value, .{ .max_value_len = 0x1000 }) },
                .UserSelect => .{ .UserSelect = try std.json.parseFromValueLeaky(SelectMenuUsers, allocator, value, .{
                    .ignore_unknown_fields = true,
                    .max_value_len = 0x1000,
                }) },
                .RoleSelect => .{ .RoleSelect = try std.json.parseFromValueLeaky(SelectMenuRoles, allocator, value, .{
                    .ignore_unknown_fields = true,
                    .max_value_len = 0x1000,
                }) },
                .MentionableSelect => .{ .MentionableSelect = try std.json.parseFromValueLeaky(SelectMenuUsersAndRoles, allocator, value, .{
                    .ignore_unknown_fields = true,
                    .max_value_len = 0x1000,
                }) },
                .ChannelSelect => .{ .ChannelSelect = try std.json.parseFromValueLeaky(SelectMenuChannels, allocator, value, .{
                    .ignore_unknown_fields = true,
                    .max_value_len = 0x1000,
                }) },
            },
            else => @panic("got type but couldn't match against non enum member `type`"),
        }

        return try MessageComponent.jsonParse(allocator, value);
    }
};
