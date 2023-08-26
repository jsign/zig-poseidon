const std = @import("std");
const testing = std.testing;

test "tests" {
    std.testing.log_level = .debug;

    _ = @import("poseidon.zig");
    _ = @import("bn254/tests.zig");
}
