# discord.zig
A [Zig](https://ziglang.org/) library for the [Discord](https://discord.com/) API.

## Getting Started
> [!WARNING]
> discord.zig is under active development and currently targets the latest stable version of Zig.

## Example
```zig
const std = @import("std");
const Discord = @import("discord");
const Shard = Discord.Shard;

var session: *Discord.Session = undefined;

fn ready(_: *Shard, payload: Discord.Ready) !void {
    std.debug.print("logged in as {s}\n", .{payload.user.username});
}

fn message_create(_: *Shard, message: Discord.Message) !void {
    if (message.content != null and std.ascii.eqlIgnoreCase(message.content.?, "!hi")) {
        var result = try session.api.sendMessage(message.channel_id, .{ .content = "hi :)" });
        defer result.deinit();

        const m = result.value.unwrap();
        std.debug.print("sent: {?s}\n", .{m.content});
    }
}

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    session = try allocator.create(Discord.Session);
    session.* = Discord.init(allocator);
    defer session.deinit();

    const env_map = try allocator.create(std.process.EnvMap);
    env_map.* = try std.process.getEnvMap(allocator);
    defer env_map.deinit();

    const token = env_map.get("DISCORD_TOKEN") orelse {
        @panic("DISCORD_TOKEN not found in environment variables");
    };

    const intents = comptime blk: {
        var bits: Discord.Intents = .{};
        bits.Guilds = true;
        bits.GuildMessages = true;
        bits.GuildMembers = true;
        // WARNING:
        // YOU MUST SET THIS ON DEV PORTAL
        // OTHERWISE THE LIBRARY WILL CRASH
        bits.MessageContent = true;
        break :blk bits;
    };

    try session.start(.{
        .intents = intents,
        .authorization = token,
        .run = .{ .message_create = &message_create, .ready = &ready },
        .log = .yes,
        .options = .{},
        .cache = .defaults(allocator),
    });
}
```

## Installation
```zig
// In your build.zig file
const exe = b.addExecutable(.{
    .name = "beluga",
    .root_source_file = b.path("src/main.zig"),
    .target = target,
    // just a suggestion, use .ReleaseSafe
    .optimize = optimize,
    // must always be on, hard dependency
    .link_libc = true,
    // self-hosted backed is unstable as of today 2025-05-16, 
    .use_llvm = true,
});

const dzig = b.dependency("discordzig", .{});

exe.root_module.addImport("discord.zig", dzig.module("discord.zig"));
```

## Contributing
Contributions are welcome! Please open an issue or pull request if you'd like to help improve the library.
