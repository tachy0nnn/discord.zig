//! ISC License
//!
//! Copyright (c) 2024-2025 Yuzu
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

const Snowflake = @import("snowflake.zig").Snowflake;
const WebhookTypes = @import("shared.zig").WebhookTypes;
const User = @import("user.zig").User;
const Guild = @import("guild.zig").Guild;
const Channel = @import("channel.zig").Channel;
const Partial = @import("partial.zig").Partial;
const IntegrationGuild = @import("integration.zig").IntegrationGuild;

/// https://discord.com/developers/docs/topics/gateway#webhooks-update-webhook-update-event-fields
pub const WebhookUpdate = struct {
    /// id of the guild
    guild_id: Snowflake,
    /// id of the channel
    channel_id: Snowflake,
};

pub const WebhookChannel = struct {
    /// The ID of the channel
    id: Snowflake,
    /// The name of the channel (1-100 characters)
    name: []const u8,
};

/// https://discord.com/developers/docs/resources/webhook#webhook-object-webhook-structure
pub const Webhook = struct {
    /// The ID of the webhook
    id: Snowflake,
    /// The type of webhook
    type: WebhookTypes,
    /// The guild ID this webhook is for, if any
    guild_id: ?Snowflake = null,
    /// The channel ID this webhook is for, if any
    channel_id: ?Snowflake = null,
    /// The user this webhook was created by
    user: ?Partial(User) = null,
    /// The default name of the webhook (1-80 characters)
    name: ?[]const u8,
    /// The default avatar hash of the webhook
    avatar: ?[]const u8,
    /// The secure token of the webhook (returned for INCOMING webhooks)
    token: ?[]const u8 = null,
    /// The application that created this webhook
    application_id: ?Snowflake = null,
    /// The guild of the channel that this webhook is following (returned for CHANNEL_FOLLOWER webhooks)
    source_guild: ?IntegrationGuild = null,
    /// The channel that this webhook is following (returned for CHANNEL_FOLLOWER webhooks)
    source_channel: ?WebhookChannel = null,
    /// The URL used for executing the webhook (returned for INCOMING webhooks)
    url: ?[]const u8 = null,
};

pub const IncomingWebhook = struct {
    /// The type of the webhook
    type: WebhookTypes,
    /// The secure token of the webhook (returned for Incoming Webhooks)
    token: ?[]const u8 = null,
    /// The url used for executing the webhook (returned by the webhooks OAuth2 flow)
    url: ?[]const u8 = null,

    /// The id of the webhook
    id: Snowflake,
    /// The guild id this webhook is for
    guild_id: ?Snowflake = null,
    /// The channel id this webhook is for
    channel_id: Snowflake,
    /// The user this webhook was created by (not returned when getting a webhook with its token)
    user: ?User = null,
    /// The default name of the webhook
    name: ?[]const u8 = null,
    /// The default user avatar hash of the webhook
    avatar: ?[]const u8 = null,
    /// The bot/OAuth2 application that created this webhook
    application_id: ?Snowflake = null,
    /// The guild of the channel that this webhook is following (returned for Channel Follower Webhooks)
    source_guild: ?IntegrationGuild = null,
    /// The channel that this webhook is following (returned for Channel Follower Webhooks)
    source_channel: ?Partial(Channel) = null,
};

pub const ApplicationWebhook = struct {
    /// The type of the webhook
    type: WebhookTypes.Application,
    /// The secure token of the webhook (returned for Incoming Webhooks)
    token: ?[]const u8 = null,
    /// The url used for executing the webhook (returned by the webhooks OAuth2 flow)
    url: ?[]const u8 = null,
    /// The id of the webhook
    id: Snowflake,
    /// The guild id this webhook is for
    guild_id: ?Snowflake = null,
    /// The channel id this webhook is for
    channel_id: ?Snowflake = null,
    /// The user this webhook was created by (not returned when getting a webhook with its token)
    user: ?User = null,
    /// The default name of the webhook
    name: ?[]const u8 = null,
    /// The default user avatar hash of the webhook
    avatar: ?[]const u8 = null,
    /// The bot/OAuth2 application that created this webhook
    application_id: ?Snowflake = null,
    /// The guild of the channel that this webhook is following (returned for Channel Follower Webhooks), field will be absent if the webhook creator has since lost access to the guild where the followed channel resides
    source_guild: ?IntegrationGuild = null,
    /// The channel that this webhook is following (returned for Channel Follower Webhooks), field will be absent if the webhook creator has since lost access to the guild where the followed channel resides
    source_channel: ?Partial(Channel) = null,
};
