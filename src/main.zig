const std = @import("std");

test "babyBear16" {
    std.testing.log_level = .debug;
    _ = @import("instances/babybear16.zig");
}
