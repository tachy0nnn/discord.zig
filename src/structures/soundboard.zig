//! ISC License
//!
//! Copyright (c) 2026 Yon
//!
//! Permission to use, copy, modify, and/or distribute this software for any
//! purpose with or without fee is hereby granted, provided that the above
//! copyright notice and this permission notice appear in all copies.

const Snowflake = @import("snowflake.zig").Snowflake;
const User = @import("user.zig").User;

pub const SoundboardSound = struct {
    sound_id: Snowflake,
    name: []const u8,
    volume: f32,
    emoji_id: ?Snowflake = null,
    emoji_name: ?[]const u8 = null,
    guild_id: ?Snowflake = null,
    available: bool,
    user: ?User = null,
    user_id: ?Snowflake = null,
};

pub const GuildSoundboardSounds = struct {
    items: []SoundboardSound,
};

pub const SoundboardSounds = struct {
    sounds: []SoundboardSound,
};

pub const ModifySoundboardSound = struct {
    name: ?[]const u8 = null,
    volume: ?f32 = null,
    emoji_id: ?Snowflake = null,
    emoji_name: ?[]const u8 = null,
};

pub const SendSoundboardSound = struct {
    sound_id: Snowflake,
    source_guild_id: ?Snowflake = null,
};

pub const SoundboardSoundDelete = struct {
    guild_id: Snowflake,
    sound_id: Snowflake,
};

pub const SoundboardSoundsUpdate = struct {
    guild_id: Snowflake,
    soundboard_sounds: []SoundboardSound,
};

pub const SoundboardSoundsEvent = struct {
    guild_id: Snowflake,
    soundboard_sounds: []SoundboardSound,
};
