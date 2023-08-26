const std = @import("std");
const Fr = @import("fr.zig");
const parameters = @import("../parameters.zig");
const poseidon = @import("../poseidon.zig");

test "babyjubjub" {
    var allocator = std.testing.allocator;
    var babyjubjub_parameters = try parameters.get_babyjubjub_parameters(allocator);
    defer babyjubjub_parameters.deinit();

    var instance = poseidon.Poseidon(Fr, 2).init(babyjubjub_parameters);

    var one: u256 = 1;
    var buf: [32]u8 = undefined;
    std.mem.writeIntLittle(u256, &buf, one);
    var nonMontB1: Fr.NonMontgomeryDomainFieldElement = undefined;
    Fr.fromBytes(&nonMontB1, buf);
    var b1: Fr.MontgomeryDomainFieldElement = undefined;
    Fr.toMontgomery(&b1, nonMontB1);

    var res = instance.hash(.{b1});

    Fr.toBytes(&buf, res);
    const A = std.mem.readInt(u256, &buf, std.builtin.Endian.Little);

    try std.testing.expect(18586133768512220936620570745912940619677854269274689475585506675881198879027 == A);
}
