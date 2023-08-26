const std = @import("std");
const testing = std.testing;
const parameters = @import("parameters.zig");
const poseidon = @import("poseidon.zig");
const Fr = @import("bn254/fr.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var bn254_params = try parameters.get_babyjubjub_parameters(gpa.allocator());
    defer bn254_params.deinit();

    const widths = [_]usize{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };

    inline for (widths) |w| {
        var instance = poseidon.Poseidon(Fr, w + 1).init(bn254_params);
        var buf: [32]u8 = undefined;

        var frs: [w]Fr.NonMontgomeryDomainFieldElement = undefined;
        for (0..w, 0..) |v, i| {
            std.mem.writeIntLittle(u256, &buf, v);
            var nonMont: Fr.NonMontgomeryDomainFieldElement = undefined;
            Fr.fromBytes(&nonMont, buf);
            Fr.toMontgomery(&frs[i], nonMont);
        }

        const now = std.time.microTimestamp();
        const n: i64 = 10_000;
        for (0..n) |_| {
            _ = instance.hash(frs);
        }
        std.debug.print("Poseidon(width={}) took {}µs\n", .{ w, @divTrunc(std.time.microTimestamp() - now, n) });
    }
}

test "tests" {
    std.testing.log_level = .debug;

    _ = @import("poseidon.zig");
    _ = @import("bn254/tests.zig");
}
