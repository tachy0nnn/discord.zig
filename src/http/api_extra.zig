//! ISC License
//!
//! Copyright (c) 2024-2025 Yuzu
//! Copyright (c) 2026 Yon
//!
//! Permission to use, copy, modify, and/or distribute this software for any
//! purpose with or without fee is hereby granted, provided that the above
//! copyright notice and this permission notice appear in all copies.

const std = @import("std");
const mem = std.mem;
const io = std.Io;
const json = std.json;
const Types = @import("../structures/types.zig");
const Snowflake = Types.Snowflake;
const Partial = Types.Partial;
const Result = @import("../errors.zig").Result;
const MakeRequestError = @import("http.zig").MakeRequestError;
const FetchReq = @import("http.zig").FetchReq;
const FileData = @import("http.zig").FileData;

allocator: mem.Allocator,
authorization: []const u8,
const Self = @This();

pub const RequestFailedError = MakeRequestError || error{FailedRequest} || json.ParseError(json.Scanner) || io.Writer.Error;

pub fn init(allocator: mem.Allocator, authorization: []const u8) Self {
    return .{ .allocator = allocator, .authorization = authorization };
}

pub const AuditLogQuery = struct {
    before: ?Snowflake = null,
    after: ?Snowflake = null,
    limit: ?u8 = 50,
    user_id: ?Snowflake = null,
    target_id: ?Snowflake = null,
    action_type: ?Types.AuditLogEvents = null,
};

/// Returns the audit log for a guild.
pub fn fetchAuditLog(self: *Self, guild_id: Snowflake, query: AuditLogQuery) RequestFailedError!Result(Types.AuditLog) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/audit-logs", .{guild_id.into()});
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    try req.addQueryParam("before", query.before);
    try req.addQueryParam("after", query.after);
    try req.addQueryParam("limit", query.limit);
    try req.addQueryParam("user_id", query.user_id);
    try req.addQueryParam("target_id", query.target_id);
    try req.addQueryParam("action_type", query.action_type);
    return req.get(Types.AuditLog, path);
}

pub const CreateAutoModerationRule = struct {
    name: []const u8,
    event_type: Types.AutoModerationEventTypes,
    trigger_type: Types.AutoModerationTriggerTypes,
    trigger_metadata: ?Types.AutoModerationRuleTriggerMetadata = null,
    actions: []Types.AutoModerationAction,
    enabled: ?bool = null,
    exempt_roles: ?[][]const u8 = null,
    exempt_channels: ?[][]const u8 = null,
};

pub const ModifyAutoModerationRule = struct {
    name: ?[]const u8 = null,
    event_type: ?Types.AutoModerationEventTypes = null,
    trigger_metadata: ?Types.AutoModerationRuleTriggerMetadata = null,
    actions: ?[]Types.AutoModerationAction = null,
    enabled: ?bool = null,
    exempt_roles: ?[][]const u8 = null,
    exempt_channels: ?[][]const u8 = null,
};

pub fn fetchAutoModerationRules(self: *Self, guild_id: Snowflake) RequestFailedError!Result([]Types.AutoModerationRule) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/auto-moderation/rules", .{guild_id.into()});
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    return req.get([]Types.AutoModerationRule, path);
}

pub fn fetchAutoModerationRule(self: *Self, guild_id: Snowflake, rule_id: Snowflake) RequestFailedError!Result(Types.AutoModerationRule) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/auto-moderation/rules/{d}", .{ guild_id.into(), rule_id.into() });
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    return req.get(Types.AutoModerationRule, path);
}

pub fn createAutoModerationRule(self: *Self, guild_id: Snowflake, rule: CreateAutoModerationRule, reason: ?[]const u8) RequestFailedError!Result(Types.AutoModerationRule) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/auto-moderation/rules", .{guild_id.into()});
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    try req.addHeader("X-Audit-Log-Reason", reason);
    return req.post(Types.AutoModerationRule, path, rule);
}

pub fn editAutoModerationRule(self: *Self, guild_id: Snowflake, rule_id: Snowflake, rule: ModifyAutoModerationRule, reason: ?[]const u8) RequestFailedError!Result(Types.AutoModerationRule) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/auto-moderation/rules/{d}", .{ guild_id.into(), rule_id.into() });
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    try req.addHeader("X-Audit-Log-Reason", reason);
    return req.patch(Types.AutoModerationRule, path, rule);
}

pub fn deleteAutoModerationRule(self: *Self, guild_id: Snowflake, rule_id: Snowflake, reason: ?[]const u8) RequestFailedError!Result(void) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/auto-moderation/rules/{d}", .{ guild_id.into(), rule_id.into() });
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    try req.addHeader("X-Audit-Log-Reason", reason);
    return req.delete(path);
}

pub const CreateScheduledEvent = struct {
    channel_id: ?Snowflake = null,
    name: []const u8,
    privacy_level: Types.ScheduledEventPrivacyLevel,
    scheduled_start_time: []const u8,
    scheduled_end_time: ?[]const u8 = null,
    description: ?[]const u8 = null,
    entity_type: Types.ScheduledEventEntityType,
    entity_metadata: ?Types.ScheduledEventEntityMetadata = null,
    image: ?[]const u8 = null,
    recurrence_rule: ?Types.ScheduledEventRecurrenceRule = null,
};

pub const ModifyScheduledEvent = struct {
    channel_id: ?Snowflake = null,
    name: ?[]const u8 = null,
    privacy_level: ?Types.ScheduledEventPrivacyLevel = null,
    scheduled_start_time: ?[]const u8 = null,
    scheduled_end_time: ?[]const u8 = null,
    description: ?[]const u8 = null,
    entity_type: ?Types.ScheduledEventEntityType = null,
    entity_metadata: ?Types.ScheduledEventEntityMetadata = null,
    status: ?Types.ScheduledEventStatus = null,
    image: ?[]const u8 = null,
    recurrence_rule: ?Types.ScheduledEventRecurrenceRule = null,
};

pub fn fetchScheduledEvents(self: *Self, guild_id: Snowflake, with_user_count: ?bool) RequestFailedError!Result([]Types.ScheduledEvent) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/scheduled-events", .{guild_id.into()});
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    try req.addQueryParam("with_user_count", with_user_count);
    return req.get([]Types.ScheduledEvent, path);
}

pub fn fetchScheduledEvent(self: *Self, guild_id: Snowflake, event_id: Snowflake, with_user_count: ?bool) RequestFailedError!Result(Types.ScheduledEvent) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/scheduled-events/{d}", .{ guild_id.into(), event_id.into() });
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    try req.addQueryParam("with_user_count", with_user_count);
    return req.get(Types.ScheduledEvent, path);
}

pub fn createScheduledEvent(self: *Self, guild_id: Snowflake, event: CreateScheduledEvent, reason: ?[]const u8) RequestFailedError!Result(Types.ScheduledEvent) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/scheduled-events", .{guild_id.into()});
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    try req.addHeader("X-Audit-Log-Reason", reason);
    return req.post(Types.ScheduledEvent, path, event);
}

pub fn editScheduledEvent(self: *Self, guild_id: Snowflake, event_id: Snowflake, event: ModifyScheduledEvent, reason: ?[]const u8) RequestFailedError!Result(Types.ScheduledEvent) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/scheduled-events/{d}", .{ guild_id.into(), event_id.into() });
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    try req.addHeader("X-Audit-Log-Reason", reason);
    return req.patch(Types.ScheduledEvent, path, event);
}

pub fn deleteScheduledEvent(self: *Self, guild_id: Snowflake, event_id: Snowflake, reason: ?[]const u8) RequestFailedError!Result(void) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/scheduled-events/{d}", .{ guild_id.into(), event_id.into() });
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    try req.addHeader("X-Audit-Log-Reason", reason);
    return req.delete(path);
}

pub const GetScheduledEventUsersQuery = struct {
    limit: ?u8 = 100,
    with_member: ?bool = null,
    with_user: ?bool = null,
    before: ?Snowflake = null,
    after: ?Snowflake = null,
};

pub fn fetchScheduledEventUsers(self: *Self, guild_id: Snowflake, event_id: Snowflake, query: GetScheduledEventUsersQuery) RequestFailedError!Result([]Types.ScheduledEventUser) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/scheduled-events/{d}/users", .{ guild_id.into(), event_id.into() });
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    try req.addQueryParam("limit", query.limit);
    try req.addQueryParam("with_member", query.with_member);
    try req.addQueryParam("with_user", query.with_user);
    try req.addQueryParam("before", query.before);
    try req.addQueryParam("after", query.after);
    return req.get([]Types.ScheduledEventUser, path);
}

pub const CreateGuildTemplate = struct {
    name: []const u8,
    description: ?[]const u8 = null,
};

pub const ModifyGuildTemplate = struct {
    name: ?[]const u8 = null,
    description: ?[]const u8 = null,
};

pub const UseGuildTemplate = struct {
    name: []const u8,
    icon: ?[]const u8 = null,
};

pub fn fetchGuildTemplate(self: *Self, code: []const u8) RequestFailedError!Result(Types.Template) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/templates/{s}", .{code});
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    return req.get(Types.Template, path);
}

pub fn useGuildTemplate(self: *Self, code: []const u8, params: UseGuildTemplate) RequestFailedError!Result(Types.Guild) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/templates/{s}", .{code});
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    return req.post(Types.Guild, path, params);
}

pub fn fetchGuildTemplates(self: *Self, guild_id: Snowflake) RequestFailedError!Result([]Types.Template) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/templates", .{guild_id.into()});
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    return req.get([]Types.Template, path);
}

pub fn createGuildTemplate(self: *Self, guild_id: Snowflake, template: CreateGuildTemplate) RequestFailedError!Result(Types.Template) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/templates", .{guild_id.into()});
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    return req.post(Types.Template, path, template);
}

pub fn syncGuildTemplate(self: *Self, guild_id: Snowflake, code: []const u8) RequestFailedError!Result(Types.Template) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/templates/{s}", .{ guild_id.into(), code });
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    return req.put(Types.Template, path, .{});
}

pub fn editGuildTemplate(self: *Self, guild_id: Snowflake, code: []const u8, template: ModifyGuildTemplate) RequestFailedError!Result(Types.Template) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/templates/{s}", .{ guild_id.into(), code });
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    return req.patch(Types.Template, path, template);
}

pub fn deleteGuildTemplate(self: *Self, guild_id: Snowflake, code: []const u8) RequestFailedError!Result(void) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/templates/{s}", .{ guild_id.into(), code });
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    return req.delete(path);
}

pub const CreateStageInstance = struct {
    channel_id: Snowflake,
    topic: []const u8,
    privacy_level: ?Types.ScheduledEventPrivacyLevel = null,
    guild_scheduled_event_id: ?Snowflake = null,
    send_start_notification: ?bool = null,
};

pub const ModifyStageInstance = struct {
    topic: ?[]const u8 = null,
    privacy_level: ?Types.ScheduledEventPrivacyLevel = null,
};

pub fn createStageInstance(self: *Self, stage: CreateStageInstance, reason: ?[]const u8) RequestFailedError!Result(Types.StageInstance) {
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    try req.addHeader("X-Audit-Log-Reason", reason);
    return req.post(Types.StageInstance, "/stage-instances", stage);
}

pub fn fetchStageInstance(self: *Self, channel_id: Snowflake) RequestFailedError!Result(Types.StageInstance) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/stage-instances/{d}", .{channel_id.into()});
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    return req.get(Types.StageInstance, path);
}

pub fn editStageInstance(self: *Self, channel_id: Snowflake, stage: ModifyStageInstance, reason: ?[]const u8) RequestFailedError!Result(Types.StageInstance) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/stage-instances/{d}", .{channel_id.into()});
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    try req.addHeader("X-Audit-Log-Reason", reason);
    return req.patch(Types.StageInstance, path, stage);
}

pub fn deleteStageInstance(self: *Self, channel_id: Snowflake, reason: ?[]const u8) RequestFailedError!Result(void) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/stage-instances/{d}", .{channel_id.into()});
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    try req.addHeader("X-Audit-Log-Reason", reason);
    return req.delete(path);
}

pub fn fetchDefaultSoundboardSounds(self: *Self) RequestFailedError!Result([]Types.SoundboardSound) {
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    return req.get([]Types.SoundboardSound, "/soundboard-default-sounds");
}

pub fn fetchGuildSoundboardSounds(self: *Self, guild_id: Snowflake) RequestFailedError!Result(Types.GuildSoundboardSounds) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/soundboard-sounds", .{guild_id.into()});
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    return req.get(Types.GuildSoundboardSounds, path);
}

pub fn fetchGuildSoundboardSound(self: *Self, guild_id: Snowflake, sound_id: Snowflake) RequestFailedError!Result(Types.SoundboardSound) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/soundboard-sounds/{d}", .{ guild_id.into(), sound_id.into() });
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    return req.get(Types.SoundboardSound, path);
}

pub const CreateSoundboardSound = struct {
    name: []const u8,
    volume: ?f32 = null,
    emoji_id: ?Snowflake = null,
    emoji_name: ?[]const u8 = null,
};

pub fn createGuildSoundboardSound(self: *Self, guild_id: Snowflake, sound: CreateSoundboardSound, file: FileData, reason: ?[]const u8) RequestFailedError!Result(Types.SoundboardSound) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/soundboard-sounds", .{guild_id.into()});
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    try req.addHeader("X-Audit-Log-Reason", reason);
    var files = .{file};
    return req.post3(Types.SoundboardSound, path, sound, &files);
}

pub fn editGuildSoundboardSound(self: *Self, guild_id: Snowflake, sound_id: Snowflake, sound: Types.ModifySoundboardSound, reason: ?[]const u8) RequestFailedError!Result(Types.SoundboardSound) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/soundboard-sounds/{d}", .{ guild_id.into(), sound_id.into() });
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    try req.addHeader("X-Audit-Log-Reason", reason);
    return req.patch(Types.SoundboardSound, path, sound);
}

pub fn deleteGuildSoundboardSound(self: *Self, guild_id: Snowflake, sound_id: Snowflake, reason: ?[]const u8) RequestFailedError!Result(void) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/soundboard-sounds/{d}", .{ guild_id.into(), sound_id.into() });
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    try req.addHeader("X-Audit-Log-Reason", reason);
    return req.delete(path);
}

pub fn fetchSoundboardSoundGuild(self: *Self, sound_id: Snowflake, guild_id: Snowflake) RequestFailedError!Result(Types.Guild) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/soundboard-sounds/{d}/guild/{d}", .{ sound_id.into(), guild_id.into() });
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    return req.get(Types.Guild, path);
}

pub fn sendSoundboardSound(self: *Self, channel_id: Snowflake, sound: Types.SendSoundboardSound) RequestFailedError!Result(void) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/channels/{d}/send-soundboard-sound", .{channel_id.into()});
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    return req.post4(path, sound);
}

pub const VoiceRegions = struct {
    pub fn get(self: *Self) RequestFailedError!Result([]Types.VoiceRegion) {
        return self.getVoiceRegions();
    }
};

pub fn getVoiceRegions(self: *Self) RequestFailedError!Result([]Types.VoiceRegion) {
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    return req.get([]Types.VoiceRegion, "/voice/regions");
}

pub fn fetchChannelWebhooks(self: *Self, channel_id: Snowflake) RequestFailedError!Result([]Types.Webhook) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/channels/{d}/webhooks", .{channel_id.into()});
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    return req.get([]Types.Webhook, path);
}

pub fn fetchGuildWebhooks(self: *Self, guild_id: Snowflake) RequestFailedError!Result([]Types.Webhook) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/guilds/{d}/webhooks", .{guild_id.into()});
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    return req.get([]Types.Webhook, path);
}

pub const CreateWebhook = struct {
    name: []const u8,
    avatar: ?[]const u8 = null,
};

pub fn createWebhook(self: *Self, channel_id: Snowflake, webhook: CreateWebhook, reason: ?[]const u8) RequestFailedError!Result(Types.Webhook) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/channels/{d}/webhooks", .{channel_id.into()});
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    try req.addHeader("X-Audit-Log-Reason", reason);
    return req.post(Types.Webhook, path, webhook);
}

pub fn fetchWebhook(self: *Self, webhook_id: Snowflake) RequestFailedError!Result(Types.Webhook) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/webhooks/{d}", .{webhook_id.into()});
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    return req.get(Types.Webhook, path);
}

pub const ModifyWebhook = struct {
    name: ?[]const u8 = null,
    avatar: ?[]const u8 = null,
    channel_id: ?Snowflake = null,
};

pub fn editWebhook(self: *Self, webhook_id: Snowflake, webhook: ModifyWebhook, reason: ?[]const u8) RequestFailedError!Result(Types.Webhook) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/webhooks/{d}", .{webhook_id.into()});
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    try req.addHeader("X-Audit-Log-Reason", reason);
    return req.patch(Types.Webhook, path, webhook);
}

pub fn deleteWebhook(self: *Self, webhook_id: Snowflake, reason: ?[]const u8) RequestFailedError!Result(void) {
    var buf: [256]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "/webhooks/{d}", .{webhook_id.into()});
    var req = FetchReq.init(self.allocator, self.authorization);
    defer req.deinit();
    try req.addHeader("X-Audit-Log-Reason", reason);
    return req.delete(path);
}
