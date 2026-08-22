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
const Snowflake = @import("snowflake.zig").Snowflake;

pub const PresenceStatus = enum(u8) {
    online,
    dnd,
    idle,
    offline,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("\"{s}\"", .{@tagName(self)});
    }
};

/// https://discord.com/developers/docs/resources/user#user-object-premium-types
pub const PremiumTypes = enum(u8) {
    None = 0,
    NitroClassic = 1,
    Nitro = 2,
    NitroBasic = 3,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/resources/user#user-object-user-flags
pub const UserFlags = packed struct(u64) {
    pub fn toRaw(self: UserFlags) u64 {
        return @bitCast(self);
    }

    pub fn fromRaw(raw: u64) UserFlags {
        return @bitCast(raw);
    }

    pub fn jsonParse(allocator: std.mem.Allocator, src: anytype, _: std.json.ParseOptions) !@This() {
        const value = try std.json.innerParse(std.json.Value, allocator, src, .{
            .ignore_unknown_fields = true,
            .max_value_len = 0x1000,
        });
        if (value != .integer) return fromRaw(0);
        return fromRaw(@intCast(value.integer));
    }

    pub fn jsonParseFromValue(_: std.mem.Allocator, src: std.json.Value, _: std.json.ParseOptions) @This() {
        if (src != .integer) return fromRaw(0);
        return fromRaw(@intCast(src.integer));
    }

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{self.toRaw()});
    }

    DiscordEmployee: bool = false, // 1 << 0
    PartneredServerOwner: bool = false, // 1 << 1
    HypeSquadEventsMember: bool = false, // 1 << 2
    BugHunterLevel1: bool = false, // 1 << 3
    MfaSms: bool = false, // 1 << 4
    PremiumPromoDismissed: bool = false, // 1 << 5
    HouseBravery: bool = false, // 1 << 6
    HouseBrilliance: bool = false, // 1 << 7
    HouseBalance: bool = false, // 1 << 8
    EarlySupporter: bool = false, // 1 << 9
    TeamUser: bool = false, // 1 << 10
    IsHubspotContact: bool = false, // 1 << 11
    System: bool = false, // 1 << 12
    HasUnreadUrgentMessages: bool = false, // 1 << 13
    BugHunterLevel2: bool = false, // 1 << 14
    UnderageDeleted: bool = false, // 1 << 15
    VerifiedBot: bool = false, // 1 << 16
    EarlyVerifiedBotDeveloper: bool = false, // 1 << 17
    DiscordCertifiedModerator: bool = false, // 1 << 18
    BotHttpInteractions: bool = false, // 1 << 19
    Spammer: bool = false, // 1 << 20
    DisablePremium: bool = false, // 1 << 21
    ActiveDeveloper: bool = false, // 1 << 22
    ProvisionalAccount: bool = false, // 1 << 23
    _pad0: u9 = 0, // 24..32
    HighGlobalRateLimit: bool = false, // 1 << 33
    Deleted: bool = false, // 1 << 34
    DisabledSuspiciousActivity: bool = false, // 1 << 35
    SelfDeleted: bool = false, // 1 << 36
    PremiumDiscriminator: bool = false, // 1 << 37
    UsedDesktopClient: bool = false, // 1 << 38
    UsedWebClient: bool = false, // 1 << 39
    UsedMobileClient: bool = false, // 1 << 40
    Disabled: bool = false, // 1 << 41
    _pad1: u1 = 0, // 42
    HasSessionStarted: bool = false, // 1 << 43
    Quarantined: bool = false, // 1 << 44
    _pad2: u2 = 0, // 45..46
    PremiumEligibleForUniqueUsername: bool = false, // 1 << 47
    _pad3: u2 = 0, // 48..49
    Collaborator: bool = false, // 1 << 50
    RestrictedCollaborator: bool = false, // 1 << 51
    _pad4: u12 = 0, // 52..63
};

pub const PremiumUsageFlags = packed struct(u8) {
    pub fn toRaw(self: PremiumUsageFlags) u8 {
        return @bitCast(self);
    }

    pub fn fromRaw(raw: u8) PremiumUsageFlags {
        return @bitCast(raw);
    }

    pub fn jsonParse(allocator: std.mem.Allocator, src: anytype, _: std.json.ParseOptions) !@This() {
        const value = try std.json.innerParse(std.json.Value, allocator, src, .{
            .ignore_unknown_fields = true,
            .max_value_len = 0x1000,
        });
        if (value != .integer) return fromRaw(0);
        return fromRaw(@intCast(value.integer));
    }

    pub fn jsonParseFromValue(_: std.mem.Allocator, src: std.json.Value, _: std.json.ParseOptions) @This() {
        if (src != .integer) return fromRaw(0);
        return fromRaw(@intCast(src.integer));
    }

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{self.toRaw()});
    }

    PremiumDiscriminator: bool = false,
    AnimatedAvatar: bool = false,
    ProfileBanner: bool = false,
    _pad: u5 = 0,
};

pub const PurchasedFlags = packed struct(u8) {
    pub fn toRaw(self: PurchasedFlags) u8 {
        return @bitCast(self);
    }

    pub fn fromRaw(raw: u8) PurchasedFlags {
        return @bitCast(raw);
    }

    pub fn jsonParse(allocator: std.mem.Allocator, src: anytype, _: std.json.ParseOptions) !@This() {
        const value = try std.json.innerParse(std.json.Value, allocator, src, .{
            .ignore_unknown_fields = true,
            .max_value_len = 0x1000,
        });
        if (value != .integer) return fromRaw(0);
        return fromRaw(@intCast(value.integer));
    }

    pub fn jsonParseFromValue(_: std.mem.Allocator, src: std.json.Value, _: std.json.ParseOptions) @This() {
        if (src != .integer) return fromRaw(0);
        return fromRaw(@intCast(src.integer));
    }

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{self.toRaw()});
    }

    NitroClassic: bool = false,
    Nitro: bool = false,
    GuildBoost: bool = false,
    NitroBasic: bool = false,
    OnReverseTrial: bool = false,
    _pad: u3 = 0,
};

// https://docs.discord.food/resources/guild#guild-member-flags
pub const MemberFlags = packed struct(u16) {
    pub fn toRaw(self: MemberFlags) u16 {
        return @bitCast(self);
    }

    pub fn fromRaw(raw: u16) MemberFlags {
        return @bitCast(raw);
    }

    pub fn jsonParse(allocator: std.mem.Allocator, src: anytype, _: std.json.ParseOptions) !@This() {
        const value = try std.json.innerParse(std.json.Value, allocator, src, .{
            .ignore_unknown_fields = true,
            .max_value_len = 0x1000,
        });
        if (value != .integer) return fromRaw(0);
        return fromRaw(@intCast(value.integer));
    }

    pub fn jsonParseFromValue(_: std.mem.Allocator, src: std.json.Value, _: std.json.ParseOptions) @This() {
        if (src != .integer) return fromRaw(0);
        return fromRaw(@intCast(src.integer));
    }

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{self.toRaw()});
    }

    ///
    /// Member has left and rejoined the guild
    ///
    /// @remarks
    /// This value is not editable
    DidRejoin: bool = false,
    ///
    /// Member has completed onboarding
    ///
    /// @remarks
    /// This value is not editable
    ////
    CompletedOnboarding: bool = false,
    /// Member is exempt from guild verification requirements
    BypassesVerification: bool = false,
    ///
    /// Member has started onboarding
    ///
    /// @remarks
    /// This value is not editable
    ////
    StartedOnboarding: bool = false,
    ///
    /// Member is a guest and can only access the voice channel they were invited to
    ///
    /// @remarks
    /// This value is not editable
    ////
    IsGuest: bool = false,
    ///
    /// Member has started Server Guide new member actions
    ///
    /// @remarks
    /// This value is not editable
    ////
    StartedHomeActions: bool = false,
    ///
    /// Member has completed Server Guide new member actions
    ///
    /// @remarks
    /// This value is not editable
    ////
    CompletedHomeActions: bool = false,
    ///
    /// Member's username, display name, or nickname is blocked by AutoMod
    ///
    /// @remarks
    /// This value is not editable
    ////
    AutomodQuarantinedUsername: bool = false,
    _pad8: u1 = 0,
    ///
    /// Member has dismissed the DM settings upsell
    ///
    /// @remarks
    /// This value is not editable
    ////
    DmSettingsUpsellAcknowledged: bool = false,
    AutomodQuarantinedGuildTag: bool = false,
    _pad11_15: u5 = 0,
};

/// https://discord.com/developers/docs/resources/channel#channels-resource
pub const ChannelFlags = packed struct(u32) {
    pub fn toRaw(self: ChannelFlags) u32 {
        return @bitCast(self);
    }

    pub fn fromRaw(raw: u32) ChannelFlags {
        return @bitCast(raw);
    }

    pub fn jsonParse(allocator: std.mem.Allocator, src: anytype, _: std.json.ParseOptions) !@This() {
        const value = try std.json.innerParse(std.json.Value, allocator, src, .{
            .ignore_unknown_fields = true,
            .max_value_len = 0x1000,
        });
        if (value != .integer) return fromRaw(0);
        return fromRaw(@intCast(value.integer));
    }

    pub fn jsonParseFromValue(_: std.mem.Allocator, src: std.json.Value, _: std.json.ParseOptions) @This() {
        if (src != .integer) return fromRaw(0);
        return fromRaw(@intCast(src.integer));
    }

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{self.toRaw()});
    }

    GuildFeedRemoved: bool = false, // 1 << 0
    Pinned: bool = false, // 1 << 1
    ActiveChannelsRemoved: bool = false, // 1 << 2
    _pad0: u1 = 0,
    RequireTag: bool = false, // 1 << 4
    IsSpam: bool = false, // 1 << 5
    _pad1: u1 = 0,
    IsGuildResourceChannel: bool = false, // 1 << 7
    ClydeAi: bool = false, // 1 << 8
    IsScheduledForDeletion: bool = false, // 1 << 9
    IsMediaChannel: bool = false, // 1 << 10
    SummariesDisabled: bool = false, // 1 << 11
    ApplicationShelfConsent: bool = false, // 1 << 12
    IsRoleSubscriptionTemplatePreviewChannel: bool = false, // 1 << 13
    IsBroadcasting: bool = false, // 1 << 14
    HideMediaDownloadOptions: bool = false, // 1 << 15
    IsJoinRequestInterviewChannel: bool = false, // 1 << 16
    Obfuscated: bool = false, // 1 << 17
    _pad2: u1 = 0,
    IsModeratorReportChannel: bool = false, // 1 << 19
    _pad3: u1 = 0,
    IsSpoilerChannel: bool = false, // 1 << 21
    _pad4: u10 = 0,
};

/// https://discord.com/developers/docs/topics/permissions#role-object-role-flags
pub const RoleFlags = packed struct(u32) {
    pub fn toRaw(self: RoleFlags) u32 {
        return @bitCast(self);
    }

    pub fn fromRaw(raw: u32) RoleFlags {
        return @bitCast(raw);
    }

    pub fn jsonParse(allocator: std.mem.Allocator, src: anytype, _: std.json.ParseOptions) !@This() {
        const value = try std.json.innerParse(std.json.Value, allocator, src, .{
            .ignore_unknown_fields = true,
            .max_value_len = 0x1000,
        });
        if (value != .integer) return fromRaw(0);
        return fromRaw(@intCast(value.integer));
    }

    pub fn jsonParseFromValue(_: std.mem.Allocator, src: std.json.Value, _: std.json.ParseOptions) @This() {
        if (src != .integer) return fromRaw(0);
        return fromRaw(@intCast(src.integer));
    }

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{self.toRaw()});
    }

    InPrompt: bool = false, // 1 << 0
    _pad: u31 = 0,
};

pub const AttachmentFlags = packed struct(u8) {
    pub fn toRaw(self: AttachmentFlags) u8 {
        return @bitCast(self);
    }

    pub fn fromRaw(raw: u8) AttachmentFlags {
        return @bitCast(raw);
    }

    pub fn jsonParse(allocator: std.mem.Allocator, src: anytype, _: std.json.ParseOptions) !@This() {
        const value = try std.json.innerParse(std.json.Value, allocator, src, .{
            .ignore_unknown_fields = true,
            .max_value_len = 0x1000,
        });
        if (value != .integer) return fromRaw(0);
        return fromRaw(@intCast(value.integer));
    }

    pub fn jsonParseFromValue(_: std.mem.Allocator, src: std.json.Value, _: std.json.ParseOptions) @This() {
        if (src != .integer) return fromRaw(0);
        return fromRaw(@intCast(src.integer));
    }

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{self.toRaw()});
    }

    IsClip: bool = false,
    IsThumbnail: bool = false,
    IsRemix: bool = false,
    IsSpoiler: bool = false,
    ContainsExplicitMedia: bool = false,
    IsAnimated: bool = false,
    ContainsGoreContent: bool = false,
    ContainsSelfHarmContent: bool = false,
};

/// https://discord.com/developers/docs/monetization/skus#sku-object-sku-flags
pub const SkuFlags = packed struct(u16) {
    pub fn toRaw(self: SkuFlags) u16 {
        return @bitCast(self);
    }

    pub fn fromRaw(raw: u16) SkuFlags {
        return @bitCast(raw);
    }

    pub fn jsonParse(allocator: std.mem.Allocator, src: anytype, _: std.json.ParseOptions) !@This() {
        const value = try std.json.innerParse(std.json.Value, allocator, src, .{
            .ignore_unknown_fields = true,
            .max_value_len = 0x1000,
        });
        if (value != .integer) return fromRaw(0);
        return fromRaw(@intCast(value.integer));
    }

    pub fn jsonParseFromValue(_: std.mem.Allocator, src: std.json.Value, _: std.json.ParseOptions) @This() {
        if (src != .integer) return fromRaw(0);
        return fromRaw(@intCast(src.integer));
    }

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{self.toRaw()});
    }

    PremiumPurchase: bool = false,
    HasFreePremiumContent: bool = false,
    Available: bool = false,
    PremiumAndDistribution: bool = false,
    Sticker: bool = false,
    GuildRole: bool = false,
    AvailableForSubscriptionGifting: bool = false,
    ApplicationGuildSubscription: bool = false,
    ApplicationUserSubscription: bool = false,
    CreatorMonetization: bool = false,
    GuildProduct: bool = false,
    AvailableForApplicationGifting: bool = false,
    _pad: u4 = 0,
};

/// https://discord.com/developers/docs/resources/channel#message-object-message-flags
pub const MessageFlags = packed struct(u32) {
    pub fn toRaw(self: MessageFlags) u32 {
        return @bitCast(self);
    }

    pub fn fromRaw(raw: u32) MessageFlags {
        return @bitCast(raw);
    }

    pub fn jsonParse(allocator: std.mem.Allocator, src: anytype, _: std.json.ParseOptions) !@This() {
        const value = try std.json.innerParse(std.json.Value, allocator, src, .{
            .ignore_unknown_fields = true,
            .max_value_len = 0x1000,
        });
        if (value != .integer) return fromRaw(0);
        return fromRaw(@intCast(value.integer));
    }

    pub fn jsonParseFromValue(_: std.mem.Allocator, src: std.json.Value, _: std.json.ParseOptions) @This() {
        if (src != .integer) return fromRaw(0);
        return fromRaw(@intCast(src.integer));
    }

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{self.toRaw()});
    }

    Crossposted: bool = false, // 1 << 0
    IsCrosspost: bool = false, // 1 << 1
    SuppressEmbeds: bool = false, // 1 << 2
    SourceMessageDeleted: bool = false, // 1 << 3
    Urgent: bool = false, // 1 << 4
    HasThread: bool = false, // 1 << 5
    Ephemeral: bool = false, // 1 << 6
    Loading: bool = false, // 1 << 7
    FailedToMentionSomeRolesInThread: bool = false, // 1 << 8
    GuildFeedHidden: bool = false, // 1 << 9
    ShouldShowLinkNotDiscordWarning: bool = false, // 1 << 10
    _pad0: u1 = 0, // 1 << 11
    SuppressNotifications: bool = false, // 1 << 12
    IsVoiceMessage: bool = false, // 1 << 13
    HasSnapshot: bool = false, // 1 << 14
    IsComponentsV2: bool = false, // 1 << 15
    SentBySocialLayerIntegration: bool = false, // 1 << 16
    HiddenSuspendedUser: bool = false, // 1 << 17
    IsFirstBooster: bool = false, // 1 << 18
    IsGuildOfficial: bool = false, // 1 << 19
    _pad1: u12 = 0,
};

/// https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-flags
pub const ActivityFlags = packed struct(u16) {
    pub fn toRaw(self: ActivityFlags) u16 {
        return @bitCast(self);
    }

    pub fn fromRaw(raw: u16) ActivityFlags {
        return @bitCast(raw);
    }

    pub fn jsonParse(allocator: std.mem.Allocator, src: anytype, _: std.json.ParseOptions) !@This() {
        const value = try std.json.innerParse(std.json.Value, allocator, src, .{
            .ignore_unknown_fields = true,
            .max_value_len = 0x1000,
        });
        if (value != .integer) return fromRaw(0);
        return fromRaw(@intCast(value.integer));
    }

    pub fn jsonParseFromValue(_: std.mem.Allocator, src: std.json.Value, _: std.json.ParseOptions) @This() {
        if (src != .integer) return fromRaw(0);
        return fromRaw(@intCast(src.integer));
    }

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{self.toRaw()});
    }

    Instance: bool = false,
    Join: bool = false,
    Spectate: bool = false,
    JoinRequest: bool = false,
    Sync: bool = false,
    Play: bool = false,
    PartyPrivacyFriends: bool = false,
    PartyPrivacyVoiceChannel: bool = false,
    Embedded: bool = false,
    Contextless: bool = false,
    _pad: u6 = 0,
};

/// https://discord.com/developers/docs/resources/guild#integration-object-integration-expire-behaviors
pub const IntegrationExpireBehaviors = enum(u8) {
    RemoveRole = 0,
    Kick = 1,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/topics/teams#data-models-membership-state-enum
pub const TeamMembershipStates = enum(u8) {
    Invited = 1,
    Accepted = 2,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/topics/oauth2#application-application-flags
pub const ApplicationFlags = packed struct(u64) {
    pub fn toRaw(self: ApplicationFlags) u64 {
        return @bitCast(self);
    }

    pub fn fromRaw(raw: u64) ApplicationFlags {
        return @bitCast(raw);
    }

    pub fn jsonParse(allocator: std.mem.Allocator, src: anytype, _: std.json.ParseOptions) !@This() {
        const value = try std.json.innerParse(std.json.Value, allocator, src, .{
            .ignore_unknown_fields = true,
            .max_value_len = 0x1000,
        });
        if (value != .integer) return fromRaw(0);
        return fromRaw(@intCast(value.integer));
    }

    pub fn jsonParseFromValue(_: std.mem.Allocator, src: std.json.Value, _: std.json.ParseOptions) @This() {
        if (src != .integer) return fromRaw(0);
        return fromRaw(@intCast(src.integer));
    }

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{self.toRaw()});
    }

    _pad0: u1 = 0, // 0
    EmbeddedReleased: bool = false, // 1 << 1
    ManagedEmoji: bool = false, // 1 << 2
    EmbeddedIap: bool = false, // 1 << 3
    GroupDmCreate: bool = false, // 1 << 4
    RpcPrivateBeta: bool = false, // 1 << 5
    ApplicationAutoModerationRuleCreateBadge: bool = false, // 1 << 6
    GameProfileDisabled: bool = false, // 1 << 7
    PublicOauth2Client: bool = false, // 1 << 8
    ContextlessActivity: bool = false, // 1 << 9
    SocialLayerIntegrationLimited: bool = false, // 1 << 10
    CloudGamingDemo: bool = false, // 1 << 11
    GatewayPresence: bool = false, // 1 << 12
    GatewayPresenceLimited: bool = false, // 1 << 13
    GatewayGuildMembers: bool = false, // 1 << 14
    GatewayGuildMembersLimited: bool = false, // 1 << 15
    VerificationPendingGuildLimit: bool = false, // 1 << 16
    Embedded: bool = false, // 1 << 17
    GatewayMessageContent: bool = false, // 1 << 18
    GatewayMessageContentLimited: bool = false, // 1 << 19
    EmbeddedFirstParty: bool = false, // 1 << 20
    ApplicationCommandMigrated: bool = false, // 1 << 21
    _pad1: u1 = 0, // 22
    ApplicationCommandBadge: bool = false, // 1 << 23
    Active: bool = false, // 1 << 24
    ActiveGracePeriod: bool = false, // 1 << 25
    IFrameModal: bool = false, // 1 << 26
    SocialLayerIntegration: bool = false, // 1 << 27
    _pad2: u1 = 0, // 28
    Promoted: bool = false, // 1 << 29
    Partner: bool = false, // 1 << 30
    _pad3: u2 = 0, // 31..32
    Parent: bool = false, // 1 << 33
    DisableRelationshipAccess: bool = false, // 1 << 34
    StorefrontEligible: bool = false, // 1 << 35
    _pad4: u28 = 0, // 36..63
};

/// https://discord.com/developers/docs/interactions/message-components#component-types
pub const MessageComponentTypes = enum(u8) {
    ActionRow = 1,
    Button = 2,
    StringSelect = 3,
    InputText = 4,
    UserSelect = 5,
    RoleSelect = 6,
    MentionableSelect = 7,
    ChannelSelect = 8,
    Section = 9,
    TextDisplay = 10,
    Thumbnail = 11,
    MediaGallery = 12,
    File = 13,
    Separator = 14,
    ContentInventoryEntry = 16,
    Container = 17,
    Label = 18,
    FileUpload = 19,
    CheckpointCard = 20,
    RadioGroup = 21,
    CheckboxGroup = 22,
    Checkbox = 23,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

pub const TextStyles = enum(u8) {
    Short = 1,
    Paragraph = 2,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/interactions/message-components#buttons-button-styles
pub const ButtonStyles = enum(u8) {
    Primary = 1,
    Secondary = 2,
    Success = 3,
    Danger = 4,
    Link = 5,
    Premium = 6,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/resources/channel#allowed-mentions-object-allowed-mention-types
pub const AllowedMentionsTypes = enum {
    roles,
    users,
    everyone,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("\"{s}\"", .{@tagName(self)});
    }
};

/// https://discord.com/developers/docs/resources/webhook#webhook-object-webhook-types
pub const WebhookTypes = enum(u8) {
    Incoming = 1,
    ChannelFollower = 2,
    Application = 3,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/resources/channel#embed-object-embed-types
pub const EmbedTypes = enum {
    rich,
    image,
    video,
    gifv,
    article,
    link,
    poll_result,
    auto_moderation_message,
    auto_moderation_notification,
    safety_policy_notice,
    safety_system_notification,
    age_verification_system_notification,
    post_preview,
    gift,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("\"{s}\"", .{@tagName(self)});
    }
};

/// https://discord.com/developers/docs/resources/guild#guild-object-default-message-notification-level
pub const DefaultMessageNotificationLevels = enum(u8) {
    AllMessages = 0,
    OnlyMentions = 1,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/resources/guild#guild-object-explicit-content-filter-level
pub const ExplicitContentFilterLevels = enum(u8) {
    Disabled = 0,
    MembersWithoutRoles = 1,
    AllMembers = 2,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/resources/guild#guild-object-verification-level
pub const VerificationLevels = enum(u8) {
    None = 0,
    Low = 1,
    Medium = 2,
    High = 3,
    VeryHigh = 4,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/resources/guild#guild-object-guild-features
pub const GuildFeatures = enum {
    INVITE_SPLASH,
    VIP_REGIONS,
    VANITY_URL,
    VERIFIED,
    PARTNERED,
    COMMUNITY,
    COMMUNITY_CANARY,
    DEVELOPER_SUPPORT_SERVER,
    NEWS,
    DISCOVERABLE,
    FEATURABLE,
    ANIMATED_ICON,
    BANNER,
    ANIMATED_BANNER,
    WELCOME_SCREEN_ENABLED,
    MEMBER_VERIFICATION_GATE_ENABLED,
    MEMBER_VERIFICATION_MANUAL_APPROVAL,
    PREVIEW_ENABLED,
    TICKETED_EVENTS_ENABLED,
    MORE_STICKERS,
    MORE_EMOJI,
    MORE_SOUNDBOARD,
    ROLE_ICONS,
    ENHANCED_ROLE_COLORS,
    ROLE_SUBSCRIPTIONS_AVAILABLE_FOR_PURCHASE,
    ROLE_SUBSCRIPTIONS_ENABLED,
    AUTO_MODERATION,
    INVITES_DISABLED,
    RAID_ALERTS_DISABLED,
    NON_COMMUNITY_RAID_ALERTS,
    GUILD_ONBOARDING,
    GUILD_ONBOARDING_EVER_ENABLED,
    GUILD_ONBOARDING_HAS_PROMPTS,
    GUILD_SERVER_GUIDE,
    GUILD_PRODUCTS,
    GUILD_TAGS,
    SOUNDBOARD,
    SUMMARIES_ENABLED_GA,
    SUMMARIES_ENABLED_BY_USER,
    SUMMARIES_DISABLED_BY_USER,
    RELAY_ENABLED,
    TIERLESS_BOOSTING,
    GAME_SERVERS,
    GAME_SERVER_HOSTING,
    APPLICATION_COMMAND_PERMISSIONS_V2,
    CREATOR_MONETIZABLE,
    CREATOR_MONETIZABLE_PROVISIONAL,
    CREATOR_STORE_PAGE,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("\"{s}\"", .{@tagName(self)});
    }
};

/// https://discord.com/developers/docs/resources/guild#guild-object-mfa-level
pub const MfaLevels = enum(u8) {
    None = 0,
    Elevated = 1,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/resources/guild#guild-object-system-channel-flags
pub const SystemChannelFlags = packed struct(u16) {
    pub fn toRaw(self: SystemChannelFlags) u16 {
        return @bitCast(self);
    }

    pub fn fromRaw(raw: u16) SystemChannelFlags {
        return @bitCast(raw);
    }

    pub fn jsonParse(allocator: std.mem.Allocator, src: anytype, _: std.json.ParseOptions) !@This() {
        const value = try std.json.innerParse(std.json.Value, allocator, src, .{
            .ignore_unknown_fields = true,
            .max_value_len = 0x1000,
        });
        if (value != .integer) return fromRaw(0);
        return fromRaw(@intCast(value.integer));
    }

    pub fn jsonParseFromValue(_: std.mem.Allocator, src: std.json.Value, _: std.json.ParseOptions) @This() {
        if (src != .integer) return fromRaw(0);
        return fromRaw(@intCast(src.integer));
    }

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{self.toRaw()});
    }

    SuppressJoinNotifications: bool = false, // 1 << 0
    SuppressPremiumSubscriptions: bool = false, // 1 << 1
    SuppressGuildReminderNotifications: bool = false, // 1 << 2
    SuppressJoinNotificationReplies: bool = false, // 1 << 3
    SuppressRoleSubscriptionPurchaseNotifications: bool = false, // 1 << 4
    SuppressRoleSubscriptionPurchaseNotificationReplies: bool = false, // 1 << 5
    _pad0: u1 = 0, // 1 << 6
    SuppressChannelPromptDeadchat: bool = false, // 1 << 7
    SuppressUgcAddedNotifications: bool = false, // 1 << 8
    _pad1: u7 = 0,
};

/// https://discord.com/developers/docs/resources/guild#guild-object-premium-tier
pub const PremiumTiers = enum(u8) {
    None = 0,
    Tier1 = 1,
    Tier2 = 2,
    Tier3 = 3,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/resources/guild#guild-object-guild-nsfw-level
pub const GuildNsfwLevel = enum(u8) {
    Default = 0,
    Explicit = 1,
    Safe = 2,
    AgeRestricted = 3,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/resources/channel#channel-object-channel-types
pub const ChannelTypes = enum(u8) {
    GuildText = 0,
    DM = 1,
    GuildVoice = 2,
    GroupDm = 3,
    GuildCategory = 4,
    GuildNews = 5,
    GuildStore = 6,
    NewsThread = 10,
    PublicThread = 11,
    PrivateThread = 12,
    GuildStageVoice = 13,
    GuildDirectory = 14,
    GuildForum = 15,
    GuildMedia = 16,
    Lobby = 17,
    EphemeralDm = 18,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

pub const OverwriteTypes = enum(u8) {
    Role = 0,
    Member = 1,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

pub const VideoQualityModes = enum(u8) {
    Auto = 1,
    Full = 2,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-types
pub const ActivityTypes = enum(u8) {
    Playing = 0,
    Streaming = 1,
    Listening = 2,
    Watching = 3,
    Custom = 4,
    Competing = 5,
    Hang = 6,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/resources/channel#message-object-message-types
pub const MessageTypes = enum(u8) {
    Default = 0,
    RecipientAdd = 1,
    RecipientRemove = 2,
    Call = 3,
    ChannelNameChange = 4,
    ChannelIconChange = 5,
    ChannelPinnedMessage = 6,
    UserJoin = 7,
    GuildBoost = 8,
    GuildBoostTier1 = 9,
    GuildBoostTier2 = 10,
    GuildBoostTier3 = 11,
    ChannelFollowAdd = 12,
    GuildDiscoveryDisqualified = 14,
    GuildDiscoveryRequalified = 15,
    GuildDiscoveryGracePeriodInitialWarning = 16,
    GuildDiscoveryGracePeriodFinalWarning = 17,
    ThreadCreated = 18,
    Reply = 19,
    ChatInputCommand = 20,
    ThreadStarterMessage = 21,
    GuildInviteReminder = 22,
    ContextMenuCommand = 23,
    AutoModerationAction = 24,
    RoleSubscriptionPurchase = 25,
    InteractionPremiumUpsell = 26,
    StageStart = 27,
    StageEnd = 28,
    StageSpeaker = 29,
    StageRaiseHand = 30,
    StageTopic = 31,
    GuildApplicationPremiumSubscription = 32,
    PremiumReferral = 35,
    GuildIncidentAlertModeEnabled = 36,
    GuildIncidentAlertModeDisabled = 37,
    GuildIncidentReportRaid = 38,
    GuildIncidentReportFalseAlarm = 39,
    GuildDeadchatRevivePrompt = 40,
    CustomGift = 41,
    GuildGamingStatsPrompt = 42,
    PurchaseNotification = 44,
    PollResult = 46,
    Changelog = 47,
    NitroNotification = 48,
    ChannelLinkedToLobby = 49,
    GiftingPrompt = 50,
    InGameMessageNux = 51,
    GuildJoinRequestAcceptNotification = 52,
    GuildJoinRequestRejectNotification = 53,
    GuildJoinRequestWithdrawnNotification = 54,
    HdStreamingUpgraded = 55,
    ReportToModDeletedMessage = 58,
    ReportToModTimeoutUser = 59,
    ReportToModKickUser = 60,
    ReportToModBanUser = 61,
    ReportToModClosedReport = 62,
    PremiumGroupInvite = 64,
    VoiceSession = 65,
    GuildBoostUpsell = 66,
    FriendRequestAccepted = 67,
    MediaMentionMessage = 68,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/resources/channel#message-object-message-activity-types
pub const MessageActivityTypes = enum(u8) {
    Join = 1,
    Spectate = 2,
    Listen = 3,
    JoinRequest = 5,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/resources/sticker#sticker-object-sticker-types
pub const StickerTypes = enum(u8) {
    Standard = 1,
    Guild = 2,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/resources/sticker#sticker-object-sticker-format-types
pub const StickerFormatTypes = enum(u8) {
    Png = 1,
    APng = 2,
    Lottie = 3,
    Gif = 4,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/interactions/slash-commands#interaction-interactiontype
pub const InteractionTypes = enum(u8) {
    Ping = 1,
    ApplicationCommand = 2,
    MessageComponent = 3,
    ApplicationCommandAutocomplete = 4,
    ModalSubmit = 5,
    SocialLayerSkuPurchaseEligibility = 6,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/interactions/slash-commands#applicationcommandoptiontype
pub const ApplicationCommandOptionTypes = enum(u8) {
    SubCommand = 1,
    SubCommandGroup = 2,
    String = 3,
    Integer = 4,
    Boolean = 5,
    User = 6,
    Channel = 7,
    Role = 8,
    Mentionable = 9,
    Number = 10,
    Attachment = 11,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/resources/audit-log#audit-log-entry-object-audit-log-events
pub const AuditLogEvents = enum(u8) {
    GuildUpdate = 1,
    ChannelCreate = 10,
    ChannelUpdate = 11,
    ChannelDelete = 12,
    ChannelOverwriteCreate = 13,
    ChannelOverwriteUpdate = 14,
    ChannelOverwriteDelete = 15,
    MemberKick = 20,
    MemberPrune = 21,
    MemberBanAdd = 22,
    MemberBanRemove = 23,
    MemberUpdate = 24,
    MemberRoleUpdate = 25,
    MemberMove = 26,
    MemberDisconnect = 27,
    BotAdd = 28,
    RoleCreate = 30,
    RoleUpdate = 31,
    RoleDelete = 32,
    InviteCreate = 40,
    InviteUpdate = 41,
    InviteDelete = 42,
    WebhookCreate = 50,
    WebhookUpdate = 51,
    WebhookDelete = 52,
    EmojiCreate = 60,
    EmojiUpdate = 61,
    EmojiDelete = 62,
    MessageDelete = 72,
    MessageBulkDelete = 73,
    MessagePin = 74,
    MessageUnpin = 75,
    IntegrationCreate = 80,
    IntegrationUpdate = 81,
    IntegrationDelete = 82,
    StageInstanceCreate = 83,
    StageInstanceUpdate = 84,
    StageInstanceDelete = 85,
    StickerCreate = 90,
    StickerUpdate = 91,
    StickerDelete = 92,
    GuildScheduledEventCreate = 100,
    GuildScheduledEventUpdate = 101,
    GuildScheduledEventDelete = 102,
    ThreadCreate = 110,
    ThreadUpdate = 111,
    ThreadDelete = 112,
    ApplicationCommandPermissionUpdate = 121,
    SoundboardSoundCreate = 130,
    SoundboardSoundUpdate = 131,
    SoundboardSoundDelete = 132,
    AutoModerationRuleCreate = 140,
    AutoModerationRuleUpdate = 141,
    AutoModerationRuleDelete = 142,
    AutoModerationBlockMessage = 143,
    AutoModerationFlagToChannel = 144,
    AutoModerationUserCommunicationDisabled = 145,
    AutoModerationQuarantineUser = 146,
    CreatorMonetizationRequestCreated = 150,
    CreatorMonetizationTermsAccepted = 151,
    OnboardingPromptCreate = 163,
    OnboardingPromptUpdate = 164,
    OnboardingPromptDelete = 165,
    OnboardingCreate = 166,
    OnboardingUpdate = 167,
    GuildHomeFeatureItem = 171,
    GuildHomeRemoveItem = 172,
    HomeSettingsCreate = 190,
    HomeSettingsUpdate = 191,
    VoiceChannelStatusCreate = 192,
    VoiceChannelStatusDelete = 193,
    GuildScheduledEventExceptionCreate = 200,
    GuildScheduledEventExceptionUpdate = 201,
    GuildScheduledEventExceptionDelete = 202,
    GuildMemberVerificationUpdate = 210,
    GuildProfileUpdate = 211,
    GuildMigratePinPermission = 212,
    GuildMigrateBypassSlowmodePermission = 213,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

pub const ScheduledEventPrivacyLevel = enum(u8) {
    Public = 1,
    GuildOnly = 2,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

pub const ScheduledEventEntityType = enum(u8) {
    StageInstance = 1,
    Voice = 2,
    External = 3,
    PrimeTime = 4,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

pub const ScheduledEventStatus = enum(u8) {
    Scheduled = 1,
    Active = 2,
    Completed = 3,
    Canceled = 4,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/resources/invite#invite-object-target-user-types
pub const TargetTypes = enum(u8) {
    Stream = 1,
    EmbeddedApplication = 2,
    RoleSubscriptions = 3,
    CreatorPage = 4,
    Lobby = 5,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

pub const ApplicationCommandTypes = enum(u8) {
    ChatInput = 1,
    User = 2,
    Message = 3,
    PrimaryEntryPoint = 4,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

pub const ApplicationCommandPermissionTypes = enum(u8) {
    Role = 1,
    User = 2,
    Channel = 3,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/topics/permissions#permissions-bitwise-permission-flags
pub const BitwisePermissionFlags = packed struct(u64) {
    pub fn toRaw(self: BitwisePermissionFlags) u64 {
        return @bitCast(self);
    }

    pub fn fromRaw(raw: u64) BitwisePermissionFlags {
        return @bitCast(raw);
    }

    pub fn jsonParse(allocator: std.mem.Allocator, src: anytype, _: std.json.ParseOptions) !@This() {
        const value = try std.json.innerParse(std.json.Value, allocator, src, .{
            .ignore_unknown_fields = true,
            .max_value_len = 0x1000,
        });
        if (value == .integer) return fromRaw(@intCast(value.integer));
        if (value == .string) {
            const parsed = std.fmt.parseInt(u64, value.string, 10) catch return fromRaw(0);
            return fromRaw(parsed);
        }
        return fromRaw(0);
    }

    pub fn jsonParseFromValue(_: std.mem.Allocator, src: std.json.Value, _: std.json.ParseOptions) @This() {
        if (src == .integer) return fromRaw(@intCast(src.integer));
        if (src == .string) {
            const parsed = std.fmt.parseInt(u64, src.string, 10) catch return fromRaw(0);
            return fromRaw(parsed);
        }
        return fromRaw(0);
    }

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("\"{d}\"", .{self.toRaw()});
    }

    CREATE_INSTANT_INVITE: bool = false, // 1 << 0
    KICK_MEMBERS: bool = false, // 1 << 1
    BAN_MEMBERS: bool = false, // 1 << 2
    ADMINISTRATOR: bool = false, // 1 << 3
    MANAGE_CHANNELS: bool = false, // 1 << 4
    MANAGE_GUILD: bool = false, // 1 << 5
    ADD_REACTIONS: bool = false, // 1 << 6
    VIEW_AUDIT_LOG: bool = false, // 1 << 7
    PRIORITY_SPEAKER: bool = false, // 1 << 8
    STREAM: bool = false, // 1 << 9
    VIEW_CHANNEL: bool = false, // 1 << 10
    SEND_MESSAGES: bool = false, // 1 << 11
    SEND_TTS_MESSAGES: bool = false, // 1 << 12
    MANAGE_MESSAGES: bool = false, // 1 << 13
    EMBED_LINKS: bool = false, // 1 << 14
    ATTACH_FILES: bool = false, // 1 << 15
    READ_MESSAGE_HISTORY: bool = false, // 1 << 16
    MENTION_EVERYONE: bool = false, // 1 << 17
    USE_EXTERNAL_EMOJIS: bool = false, // 1 << 18
    VIEW_GUILD_INSIGHTS: bool = false, // 1 << 19
    CONNECT: bool = false, // 1 << 20
    SPEAK: bool = false, // 1 << 21
    MUTE_MEMBERS: bool = false, // 1 << 22
    DEAFEN_MEMBERS: bool = false, // 1 << 23
    MOVE_MEMBERS: bool = false, // 1 << 24
    USE_VAD: bool = false, // 1 << 25
    CHANGE_NICKNAME: bool = false, // 1 << 26
    MANAGE_NICKNAMES: bool = false, // 1 << 27
    MANAGE_ROLES: bool = false, // 1 << 28
    MANAGE_WEBHOOKS: bool = false, // 1 << 29
    MANAGE_GUILD_EXPRESSIONS: bool = false, // 1 << 30
    USE_SLASH_COMMANDS: bool = false, // 1 << 31
    REQUEST_TO_SPEAK: bool = false, // 1 << 32
    MANAGE_EVENTS: bool = false, // 1 << 33
    MANAGE_THREADS: bool = false, // 1 << 34
    CREATE_PUBLIC_THREADS: bool = false, // 1 << 35
    CREATE_PRIVATE_THREADS: bool = false, // 1 << 36
    USE_EXTERNAL_STICKERS: bool = false, // 1 << 37
    SEND_MESSAGES_IN_THREADS: bool = false, // 1 << 38
    USE_EMBEDDED_ACTIVITIES: bool = false, // 1 << 39
    MODERATE_MEMBERS: bool = false, // 1 << 40
    VIEW_CREATOR_MONETIZATION_ANALYTICS: bool = false, // 1 << 41
    USE_SOUNDBOARD: bool = false, // 1 << 42
    CREATE_GUILD_EXPRESSIONS: bool = false, // 1 << 43
    CREATE_EVENTS: bool = false, // 1 << 44
    USE_EXTERNAL_SOUNDS: bool = false, // 1 << 45
    SEND_VOICE_MESSAGES: bool = false, // 1 << 46
    _pad0: u1 = 0, // 47
    SET_VOICE_CHANNEL_STATUS: bool = false, // 1 << 48
    SEND_POLLS: bool = false, // 1 << 49
    USE_EXTERNAL_APPS: bool = false, // 1 << 50
    PIN_MESSAGES: bool = false, // 1 << 51
    BYPASS_SLOWMODE: bool = false, // 1 << 52
    MANAGE_OFFICIAL_MESSAGES: bool = false, // 1 << 53
    _pad1: u10 = 0,
};

pub const PermissionStrings = enum {
    CREATE_INSTANT_INVITE,
    KICK_MEMBERS,
    BAN_MEMBERS,
    ADMINISTRATOR,
    MANAGE_CHANNELS,
    MANAGE_GUILD,
    ADD_REACTIONS,
    VIEW_AUDIT_LOG,
    PRIORITY_SPEAKER,
    STREAM,
    VIEW_CHANNEL,
    SEND_MESSAGES,
    SEND_TTS_MESSAGES,
    MANAGE_MESSAGES,
    EMBED_LINKS,
    ATTACH_FILES,
    READ_MESSAGE_HISTORY,
    MENTION_EVERYONE,
    USE_EXTERNAL_EMOJIS,
    VIEW_GUILD_INSIGHTS,
    CONNECT,
    SPEAK,
    MUTE_MEMBERS,
    DEAFEN_MEMBERS,
    MOVE_MEMBERS,
    USE_VAD,
    CHANGE_NICKNAME,
    MANAGE_NICKNAMES,
    MANAGE_ROLES,
    MANAGE_WEBHOOKS,
    MANAGE_GUILD_EXPRESSIONS,
    USE_SLASH_COMMANDS,
    REQUEST_TO_SPEAK,
    MANAGE_EVENTS,
    MANAGE_THREADS,
    CREATE_PUBLIC_THREADS,
    CREATE_PRIVATE_THREADS,
    USE_EXTERNAL_STICKERS,
    SEND_MESSAGES_IN_THREADS,
    USE_EMBEDDED_ACTIVITIES,
    MODERATE_MEMBERS,
    VIEW_CREATOR_MONETIZATION_ANALYTICS,
    USE_SOUNDBOARD,
    CREATE_GUILD_EXPRESSIONS,
    CREATE_EVENTS,
    USE_EXTERNAL_SOUNDS,
    SEND_VOICE_MESSAGES,
    SET_VOICE_CHANNEL_STATUS,
    SEND_POLLS,
    USE_EXTERNAL_APPS,
    PIN_MESSAGES,
    BYPASS_SLOWMODE,
    MANAGE_OFFICIAL_MESSAGES,
};

/// https://discord.com/developers/docs/topics/opcodes-and-status-codes#opcodes-and-status-codes
pub const GatewayCloseEventCodes = enum(u16) {
    NormalClosure = 1000,
    UnknownError = 4000,
    UnknownOpcode = 4001,
    DecodeError = 4002,
    NotAuthenticated = 4003,
    AuthenticationFailed = 4004,
    AlreadyAuthenticated = 4005,
    InvalidSeq = 4007,
    RateLimited = 4008,
    SessionTimedOut = 4009,
    InvalidShard = 4010,
    ShardingRequired = 4011,
    InvalidApiVersion = 4012,
    InvalidIntents = 4013,
    DisallowedIntents = 4014,
    TooManySessions = 4015,
    ConnectionRequestCanceled = 4016,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

/// https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-opcodes
pub const GatewayOpcodes = enum(u8) {
    Dispatch = 0,
    Heartbeat = 1,
    Identify = 2,
    PresenceUpdate = 3,
    VoiceStateUpdate = 4,
    VoiceServerPing = 5,
    Resume = 6,
    Reconnect = 7,
    RequestGuildMembers = 8,
    InvalidSession = 9,
    Hello = 10,
    HeartbeatACK = 11,
    CallConnect = 13,
    GuildSubscriptions = 14,
    LobbyVoiceStates = 17,
    StreamCreate = 18,
    StreamDelete = 19,
    StreamWatch = 20,
    StreamPing = 21,
    StreamSetPaused = 22,
    RequestForumUnreads = 28,
    RemoteCommand = 29,
    RequestDeletedEntityIds = 30,
    RequestSoundboardSounds = 31,
    SpeedTestCreate = 32,
    SpeedTestDelete = 33,
    RequestLastMessages = 34,
    SearchRecentMembers = 35,
    RequestChannelStatuses = 36,
    GuildSubscriptionsBulk = 37,
    GuildChannelsResync = 38,
    RequestChannelMemberCount = 39,
    QoSHeartbeat = 40,
    UpdateTimeSpentSessionId = 41,
    LobbyVoiceServerPing = 42,
    RequestChannelInfo = 43,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

pub const GatewayDispatchEventNames = enum {
    APPLICATION_COMMAND_PERMISSIONS_UPDATE,
    AUTO_MODERATION_RULE_CREATE,
    AUTO_MODERATION_RULE_UPDATE,
    AUTO_MODERATION_RULE_DELETE,
    AUTO_MODERATION_ACTION_EXECUTION,
    AUTO_MODERATION_MENTION_RAID_DETECTION,
    CHANNEL_CREATE,
    CHANNEL_UPDATE,
    CHANNEL_DELETE,
    CHANNEL_PINS_UPDATE,
    THREAD_CREATE,
    THREAD_UPDATE,
    THREAD_DELETE,
    THREAD_LIST_SYNC,
    THREAD_MEMBER_UPDATE,
    THREAD_MEMBERS_UPDATE,
    GUILD_AUDIT_LOG_ENTRY_CREATE,
    GUILD_CREATE,
    GUILD_UPDATE,
    GUILD_DELETE,
    GUILD_BAN_ADD,
    GUILD_BAN_REMOVE,
    GUILD_EMOJIS_UPDATE,
    GUILD_STICKERS_UPDATE,
    GUILD_INTEGRATIONS_UPDATE,
    GUILD_MEMBER_ADD,
    GUILD_MEMBER_REMOVE,
    GUILD_MEMBER_UPDATE,
    GUILD_MEMBERS_CHUNK,
    GUILD_ROLE_CREATE,
    GUILD_ROLE_UPDATE,
    GUILD_ROLE_DELETE,
    GUILD_SCHEDULED_EVENT_CREATE,
    GUILD_SCHEDULED_EVENT_UPDATE,
    GUILD_SCHEDULED_EVENT_DELETE,
    GUILD_SCHEDULED_EVENT_USER_ADD,
    GUILD_SCHEDULED_EVENT_USER_REMOVE,
    GUILD_SCHEDULED_EVENT_EXCEPTION_CREATE,
    GUILD_SCHEDULED_EVENT_EXCEPTION_UPDATE,
    GUILD_SCHEDULED_EVENT_EXCEPTION_DELETE,
    GUILD_SCHEDULED_EVENT_EXCEPTIONS_DELETE,
    GUILD_SOUNDBOARD_SOUND_CREATE,
    GUILD_SOUNDBOARD_SOUND_UPDATE,
    GUILD_SOUNDBOARD_SOUND_DELETE,
    GUILD_SOUNDBOARD_SOUNDS_UPDATE,
    SOUNDBOARD_SOUNDS,
    INTEGRATION_CREATE,
    INTEGRATION_UPDATE,
    INTEGRATION_DELETE,
    INTERACTION_CREATE,
    INVITE_CREATE,
    INVITE_DELETE,
    MESSAGE_CREATE,
    MESSAGE_UPDATE,
    MESSAGE_DELETE,
    MESSAGE_DELETE_BULK,
    MESSAGE_REACTION_ADD,
    MESSAGE_REACTION_REMOVE,
    MESSAGE_REACTION_REMOVE_ALL,
    MESSAGE_REACTION_REMOVE_EMOJI,
    PRESENCE_UPDATE,
    STAGE_INSTANCE_CREATE,
    STAGE_INSTANCE_UPDATE,
    STAGE_INSTANCE_DELETE,
    TYPING_START,
    USER_UPDATE,
    VOICE_CHANNEL_EFFECT_SEND,
    VOICE_STATE_UPDATE,
    VOICE_SERVER_UPDATE,
    VOICE_CHANNEL_START_TIME_UPDATE,
    VOICE_CHANNEL_STATUS_UPDATE,
    WEBHOOKS_UPDATE,
    ENTITLEMENT_CREATE,
    ENTITLEMENT_UPDATE,
    ENTITLEMENT_DELETE,
    MESSAGE_POLL_VOTE_ADD,
    MESSAGE_POLL_VOTE_REMOVE,
    READY,
    RESUMED,
};

/// https://discord.com/developers/docs/interactions/slash-commands#interaction-response-interactionresponsetype
pub const InteractionResponseTypes = enum(u8) {
    Pong = 1,
    ChannelMessageWithSource = 4,
    DeferredChannelMessageWithSource = 5,
    DeferredUpdateMessage = 6,
    UpdateMessage = 7,
    ApplicationCommandAutocompleteResult = 8,
    Modal = 9,
    PremiumRequired = 10,
    IFrameModal = 11,
    LaunchActivity = 12,
    SocialLayerSkuPurchaseEligibility = 13,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

pub const SortOrderTypes = enum(u8) {
    LatestActivity = 0,
    CreationDate = 1,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

pub const ForumLayout = enum(u8) {
    NotSet = 0,
    ListView = 1,
    GalleryView = 2,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};

pub const ImageFormat = enum {
    jpg,
    jpeg,
    png,
    webp,
    gif,
    json,
};

pub const ImageSize = isize;

pub const Locales = enum {
    id,
    da,
    de,
    @"en-GB",
    @"en-US",
    @"es-ES",
    @"es-419",
    fr,
    hr,
    it,
    lt,
    hu,
    nl,
    no,
    pl,
    @"pt-BR",
    ro,
    fi,
    @"sv-SE",
    vi,
    tr,
    cs,
    el,
    bg,
    ru,
    uk,
    hi,
    th,
    @"zh-CN",
    ja,
    @"zh-TW",
    ko,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("\"{s}\"", .{@tagName(self)});
    }
};

/// https://discord.com/developers/docs/topics/oauth2#shared-resources-oauth2-scopes
pub const OAuth2Scope = enum {
    @"activities.read",
    @"activities.write",
    @"applications.builds.read",
    @"applications.builds.upload",
    @"applications.commands",
    @"applications.commands.update",
    @"applications.commands.permissions.update",
    @"applications.entitlements",
    @"applications.store.update",
    bot,
    connections,
    @"dm_channels.read",
    @"dm_channels.messages.read",
    @"dm_channels.messages.write",
    email,
    @"gdm.join",
    guilds,
    @"guilds.join",
    @"guilds.members.read",
    identify,
    @"messages.read",
    openid,
    @"relationships.read",
    @"relationships.write",
    @"role_connections.write",
    rpc,
    @"rpc.activities.write",
    @"rpc.notifications.read",
    @"rpc.voice.read",
    @"rpc.voice.write",
    voice,
    @"webhook.incoming",

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("\"{s}\"", .{@tagName(self)});
    }
};

/// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-interaction-context-types
pub const InteractionContextType = enum(u8) {
    Guild = 0,
    BotDm = 1,
    PrivateChannel = 2,

    pub fn jsonStringify(self: @This(), writer: anytype) !void {
        try writer.print("{d}", .{@intFromEnum(self)});
    }
};
