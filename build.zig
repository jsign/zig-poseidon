const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("poseidon", .{
        .root_source_file = .{
            .cwd_relative = "src/poseidon2/poseidon2.zig",
        },
    });

    const exe = b.addExecutable(.{
        .name = "zig-poseidon",
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    const lib = b.addStaticLibrary(.{
        .name = "zig-poseidon",
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(lib);

    const main_tests = b.addTest(.{
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_main_tests = b.addRunArtifact(main_tests);
    run_main_tests.has_side_effects = true;

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}
