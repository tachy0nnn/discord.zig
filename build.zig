const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const install_tests = b.option(bool, "marin", "Install test executable") orelse false;

    const websocket = b.dependency("websocket", .{
        .target = target,
        .optimize = optimize,
    });

    const zlib = b.dependency("zlib", .{
        .target = target,
        .optimize = optimize,
    });

    const dzig = b.addModule("discord.zig", .{
        .root_source_file = b.path("src/root.zig"),
        .link_libc = true,
    });

    dzig.addImport("ws", websocket.module("websocket"));
    dzig.addIncludePath(zlib.path("."));
    dzig.linkLibrary(zlib.artifact("z"));

    const marin = b.addExecutable(.{
        .name = "marin",
        .root_module = b.createModule(.{
            .root_source_file = b.path("test/test.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
        .use_llvm = true,
    });

    marin.root_module.addImport("discord", dzig);
    marin.root_module.addImport("ws", websocket.module("websocket"));
    marin.root_module.addIncludePath(zlib.path("."));
    marin.root_module.linkLibrary(zlib.artifact("z"));

    if (install_tests) b.installArtifact(marin);

    // test
    const run_cmd = b.addRunArtifact(marin);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const lib = b.addLibrary(.{
        .name = "discord.zig",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
        .use_llvm = true,
    });

    lib.root_module.addImport("ws", websocket.module("websocket"));
    lib.root_module.addIncludePath(zlib.path("."));
    lib.root_module.linkLibrary(zlib.artifact("z"));

    const unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/shard/zlib_stream.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
        .use_llvm = true,
    });
    unit_tests.root_module.addIncludePath(zlib.path("."));
    unit_tests.root_module.linkLibrary(zlib.artifact("z"));

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    // docs
    const docs_step = b.step("docs", "Generate documentation");
    const docs_install = b.addInstallDirectory(.{
        .source_dir = lib.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });

    docs_step.dependOn(&docs_install.step);
}
