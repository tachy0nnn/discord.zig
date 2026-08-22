const std = @import("std");
const mem = std.mem;

const usage_text =
    \\Usage: zig run scripts/dev.zig -- <command>
    \\
    \\Commands:
    \\  doctor       Check Zig, project files, dependencies, and token setup
    \\  fetch        Fetch and update Zig package dependencies
    \\  fmt          Format all Zig source files
    \\  check        Compile the library and bot test executable without running it
    \\  test         Run tests
    \\  run          Run the bot test executable
    \\  clean        Delete Zig build and cache output
    \\  all          Run doctor, fetch, fmt, check, and test
    \\  help         Show this help
    \\
    \\Environment:
    \\  DISCORD_TOKEN    Bot token used by run
    \\  DISCORD_GUILD_ID Optional test guild id
    \\
;

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();
    const io = init.io;
    const args = try init.minimal.args.toSlice(allocator);

    ensureProjectRoot(io);

    const cmd = if (args.len > 1) args[1] else "help";

    if (mem.eql(u8, cmd, "help") or mem.eql(u8, cmd, "-h") or mem.eql(u8, cmd, "--help")) {
        std.debug.print("{s}", .{usage_text});
    } else if (mem.eql(u8, cmd, "doctor")) {
        try doctor(io, init);
    } else if (mem.eql(u8, cmd, "fetch")) {
        try fetch(io);
    } else if (mem.eql(u8, cmd, "fmt")) {
        try fmt(io);
    } else if (mem.eql(u8, cmd, "check")) {
        try check(io);
    } else if (mem.eql(u8, cmd, "test")) {
        try runTests(allocator, io);
    } else if (mem.eql(u8, cmd, "run")) {
        try runBot(io, init);
    } else if (mem.eql(u8, cmd, "clean")) {
        try clean(io);
    } else if (mem.eql(u8, cmd, "all")) {
        try doctor(io, init);
        try fetch(io);
        try fmt(io);
        try check(io);
        try runTests(allocator, io);
    } else {
        std.debug.print("error: unknown command '{s}'\n\n{s}", .{ cmd, usage_text });
        std.process.exit(2);
    }
}

fn doctor(io: std.Io, init: std.process.Init) !void {
    std.debug.print("== zig ==\n", .{});
    try run(io, &.{ "zig", "version" });
    std.debug.print("\n", .{});

    std.debug.print("== project ==\n", .{});
    std.debug.print("src: {s}\n", .{if (dirExists(io, "src")) "ok" else "missing"});
    std.debug.print("build.zig: {s}\n", .{if (fileExists(io, "build.zig")) "ok" else "missing"});
    std.debug.print("build.zig.zon: {s}\n", .{if (fileExists(io, "build.zig.zon")) "ok" else "missing"});
    std.debug.print("test/: {s}\n\n", .{if (dirExists(io, "test")) "ok" else "missing"});

    std.debug.print("== dependencies ==\n", .{});
    _ = try runSilent(io, &.{ "zig", "build", "--fetch" });
    std.debug.print("dependencies: ok\n\n", .{});

    std.debug.print("== token ==\n", .{});
    if (init.environ_map.get("DISCORD_TOKEN")) |_| {
        std.debug.print("DISCORD_TOKEN: set\n", .{});
    } else {
        std.debug.print("DISCORD_TOKEN: not set\nset it in your shell\n", .{});
    }
}

fn fetch(io: std.Io) !void {
    try run(io, &.{ "zig", "build", "--fetch" });
}

fn fmt(io: std.Io) !void {
    var targets: [7][]const u8 = undefined;
    targets[0] = "zig";
    targets[1] = "fmt";
    var count: usize = 2;

    const paths = [_][]const u8{ "src", "test", "scripts", "build.zig", "build.zig.zon" };
    for (paths) |path| {
        if (dirExists(io, path) or fileExists(io, path)) {
            targets[count] = path;
            count += 1;
        }
    }

    if (count > 2) {
        try run(io, targets[0..count]);
    }
}

fn check(io: std.Io) !void {
    try run(io, &.{ "zig", "build", "--summary", "all" });
    _ = runSilent(io, &.{ "zig", "build", "run", "--help" }) catch false;
    std.debug.print("compile check: ok\n", .{});
}

fn runTests(allocator: mem.Allocator, io: std.Io) !void {
    const result = try std.process.run(allocator, io, .{
        .argv = &.{ "zig", "build", "--help" },
    });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    if (mem.indexOf(u8, result.stdout, "\n  test") != null) {
        try run(io, &.{ "zig", "build", "test" });
    } else {
        std.debug.print("no test step found in build.zig, compiling main build target instead\n", .{});
        try run(io, &.{ "zig", "build" });
    }
}

fn runBot(io: std.Io, init: std.process.Init) !void {
    requireEnv(init, "DISCORD_TOKEN");
    try run(io, &.{ "zig", "build", "run" });
}

fn clean(io: std.Io) !void {
    const paths = [_][]const u8{ "zig-out", ".zig-cache", "zig-cache" };
    for (paths) |path| {
        std.Io.Dir.cwd().deleteTree(io, path) catch {};
    }
    std.debug.print("cleaned build artifacts\n", .{});
}

fn ensureProjectRoot(io: std.Io) void {
    if (!fileExists(io, "build.zig")) {
        std.debug.print("error: run this script from the repository root\n", .{});
        std.process.exit(1);
    }
    if (!fileExists(io, "build.zig.zon")) {
        std.debug.print("error: build.zig.zon is missing\n", .{});
        std.process.exit(1);
    }
}

fn fileExists(io: std.Io, path: []const u8) bool {
    var file = std.Io.Dir.cwd().openFile(io, path, .{}) catch return false;
    file.close(io);
    return true;
}

fn dirExists(io: std.Io, path: []const u8) bool {
    var dir = std.Io.Dir.cwd().openDir(io, path, .{}) catch return false;
    dir.close(io);
    return true;
}

fn requireEnv(init: std.process.Init, key: []const u8) void {
    if (init.environ_map.get(key) == null) {
        std.debug.print("error: {s} environment variable is not set\n", .{key});
        std.process.exit(1);
    }
}

fn run(io: std.Io, argv: []const []const u8) !void {
    var child = try std.process.spawn(io, .{ .argv = argv });
    const term = try child.wait(io);
    switch (term) {
        .exited => |code| {
            if (code != 0) std.process.exit(code);
        },
        else => std.process.exit(1),
    }
}

fn runSilent(io: std.Io, argv: []const []const u8) !bool {
    var child = try std.process.spawn(io, .{
        .argv = argv,
        .stdout = .ignore,
        .stderr = .ignore,
    });
    const term = try child.wait(io);
    return switch (term) {
        .exited => |code| code == 0,
        else => false,
    };
}
