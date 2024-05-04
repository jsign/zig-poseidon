const std = @import("std");
const Fr = @import("fr.zig");
const parameters = @import("../parameters.zig");
const poseidon = @import("../poseidon.zig");

const test_case = struct { v: []const u256, exp_hash: u256 };

test "go-iden3-crypto compatibility" {
    const test_cases = [_]test_case{
        .{ .v = &[_]u256{1}, .exp_hash = 18586133768512220936620570745912940619677854269274689475585506675881198879027 },
        .{ .v = &[_]u256{ 1, 2 }, .exp_hash = 7853200120776062878684798364095072458815029376092732009249414926327459813530 },
        .{ .v = &[_]u256{ 1, 2, 0, 0, 0 }, .exp_hash = 1018317224307729531995786483840663576608797660851238720571059489595066344487 },
        .{ .v = &[_]u256{ 1, 2, 0, 0, 0, 0 }, .exp_hash = 15336558801450556532856248569924170992202208561737609669134139141992924267169 },
        .{ .v = &[_]u256{ 3, 4, 0, 0, 0 }, .exp_hash = 5811595552068139067952687508729883632420015185677766880877743348592482390548 },
        .{ .v = &[_]u256{ 3, 4, 0, 0, 0, 0 }, .exp_hash = 12263118664590987767234828103155242843640892839966517009184493198782366909018 },
        .{ .v = &[_]u256{ 1, 2, 3, 4, 5, 6 }, .exp_hash = 20400040500897583745843009878988256314335038853985262692600694741116813247201 },
        .{ .v = &[_]u256{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 }, .exp_hash = 8354478399926161176778659061636406690034081872658507739535256090879947077494 },
        .{ .v = &[_]u256{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 0, 0, 0, 0 }, .exp_hash = 5540388656744764564518487011617040650780060800286365721923524861648744699539 },
        .{ .v = &[_]u256{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 0, 0, 0, 0, 0, 0 }, .exp_hash = 11882816200654282475720830292386643970958445617880627439994635298904836126497 },
        .{ .v = &[_]u256{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 }, .exp_hash = 9989051620750914585850546081941653841776809718687451684622678807385399211877 },
    };
    try test_run(&test_cases);
}

test "circomlib compatibility" {
    const test_cases = [_]test_case{
        .{ .v = &[_]u256{ 1, 2, 0, 0, 0 }, .exp_hash = 1018317224307729531995786483840663576608797660851238720571059489595066344487 },
        .{ .v = &[_]u256{ 3, 4, 5, 10, 23 }, .exp_hash = 13034429309846638789535561449942021891039729847501137143363028890275222221409 },
        .{ .v = &[_]u256{ 1, 2 }, .exp_hash = 7853200120776062878684798364095072458815029376092732009249414926327459813530 },
        .{ .v = &[_]u256{ 3, 4 }, .exp_hash = 14763215145315200506921711489642608356394854266165572616578112107564877678998 },
        .{ .v = &[_]u256{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 }, .exp_hash = 9989051620750914585850546081941653841776809718687451684622678807385399211877 },
    };
    try test_run(&test_cases);
}

fn test_run(comptime test_cases: []const test_case) !void {
    const allocator = std.testing.allocator;
    var bn254_params = try parameters.get_babyjubjub_parameters(allocator);
    defer bn254_params.deinit();

    inline for (test_cases) |tc| {
        var instance = poseidon.Poseidon(Fr, tc.v.len + 1).init(bn254_params);
        var buf: [32]u8 = undefined;

        var frs: [tc.v.len]Fr.NonMontgomeryDomainFieldElement = undefined;
        for (tc.v, 0..) |v, i| {
            std.mem.writeInt(u256, &buf, v, .little);
            var nonMont: Fr.NonMontgomeryDomainFieldElement = undefined;
            Fr.fromBytes(&nonMont, buf);
            Fr.toMontgomery(&frs[i], nonMont);
        }

        const hash = instance.hash(frs);

        Fr.toBytes(&buf, hash);
        const res = std.mem.readInt(u256, &buf, .little);

        try std.testing.expect(tc.exp_hash == res);
    }
}
