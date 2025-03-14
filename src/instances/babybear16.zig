const std = @import("std");
const poseidon2 = @import("../poseidon2/poseidon2.zig");
const babybear = @import("../fields/babybear/montgomery.zig").MontgomeryField;

const WIDTH = 16;
const EXTERNAL_ROUNDS = 8;
const INTERNAL_ROUNDS = 13;
const SBOX_DEGREE = 7;

const DIAGONAL = [WIDTH]u32{
    parseHex("0a632d94"),
    parseHex("6db657b7"),
    parseHex("56fbdc9e"),
    parseHex("052b3d8a"),
    parseHex("33745201"),
    parseHex("5c03108c"),
    parseHex("0beba37b"),
    parseHex("258c2e8b"),
    parseHex("12029f39"),
    parseHex("694909ce"),
    parseHex("6d231724"),
    parseHex("21c3b222"),
    parseHex("3c0904a5"),
    parseHex("01d6acda"),
    parseHex("27705c83"),
    parseHex("5231c802"),
};

const Poseidon2BabyBear = poseidon2.Poseidon2(
    babybear,
    WIDTH,
    INTERNAL_ROUNDS,
    EXTERNAL_ROUNDS,
    SBOX_DEGREE,
    DIAGONAL,
    EXTERNAL_RCS,
    INTERNAL_RCS,
);

const EXTERNAL_RCS = [EXTERNAL_ROUNDS][WIDTH]u32{
    .{
        parseHex("69cbb6af"),
        parseHex("46ad93f9"),
        parseHex("60a00f4e"),
        parseHex("6b1297cd"),
        parseHex("23189afe"),
        parseHex("732e7bef"),
        parseHex("72c246de"),
        parseHex("2c941900"),
        parseHex("0557eede"),
        parseHex("1580496f"),
        parseHex("3a3ea77b"),
        parseHex("54f3f271"),
        parseHex("0f49b029"),
        parseHex("47872fe1"),
        parseHex("221e2e36"),
        parseHex("1ab7202e"),
    },
    .{
        parseHex("487779a6"),
        parseHex("3851c9d8"),
        parseHex("38dc17c0"),
        parseHex("209f8849"),
        parseHex("268dcee8"),
        parseHex("350c48da"),
        parseHex("5b9ad32e"),
        parseHex("0523272b"),
        parseHex("3f89055b"),
        parseHex("01e894b2"),
        parseHex("13ddedde"),
        parseHex("1b2ef334"),
        parseHex("7507d8b4"),
        parseHex("6ceeb94e"),
        parseHex("52eb6ba2"),
        parseHex("50642905"),
    },
    .{
        parseHex("05453f3f"),
        parseHex("06349efc"),
        parseHex("6922787c"),
        parseHex("04bfff9c"),
        parseHex("768c714a"),
        parseHex("3e9ff21a"),
        parseHex("15737c9c"),
        parseHex("2229c807"),
        parseHex("0d47f88c"),
        parseHex("097e0ecc"),
        parseHex("27eadba0"),
        parseHex("2d7d29e4"),
        parseHex("3502aaa0"),
        parseHex("0f475fd7"),
        parseHex("29fbda49"),
        parseHex("018afffd"),
    },
    .{
        parseHex("0315b618"),
        parseHex("6d4497d1"),
        parseHex("1b171d9e"),
        parseHex("52861abd"),
        parseHex("2e5d0501"),
        parseHex("3ec8646c"),
        parseHex("6e5f250a"),
        parseHex("148ae8e6"),
        parseHex("17f5fa4a"),
        parseHex("3e66d284"),
        parseHex("0051aa3b"),
        parseHex("483f7913"),
        parseHex("2cfe5f15"),
        parseHex("023427ca"),
        parseHex("2cc78315"),
        parseHex("1e36ea47"),
    },
    .{
        parseHex("7290a80d"),
        parseHex("6f7e5329"),
        parseHex("598ec8a8"),
        parseHex("76a859a0"),
        parseHex("6559e868"),
        parseHex("657b83af"),
        parseHex("13271d3f"),
        parseHex("1f876063"),
        parseHex("0aeeae37"),
        parseHex("706e9ca6"),
        parseHex("46400cee"),
        parseHex("72a05c26"),
        parseHex("2c589c9e"),
        parseHex("20bd37a7"),
        parseHex("6a2d3d10"),
        parseHex("20523767"),
    },
    .{
        parseHex("5b8fe9c4"),
        parseHex("2aa501d6"),
        parseHex("1e01ac3e"),
        parseHex("1448bc54"),
        parseHex("5ce5ad1c"),
        parseHex("4918a14d"),
        parseHex("2c46a83f"),
        parseHex("4fcf6876"),
        parseHex("61d8d5c8"),
        parseHex("6ddf4ff9"),
        parseHex("11fda4d3"),
        parseHex("02933a8f"),
        parseHex("170eaf81"),
        parseHex("5a9c314f"),
        parseHex("49a12590"),
        parseHex("35ec52a1"),
    },
    .{
        parseHex("58eb1611"),
        parseHex("5e481e65"),
        parseHex("367125c9"),
        parseHex("0eba33ba"),
        parseHex("1fc28ded"),
        parseHex("066399ad"),
        parseHex("0cbec0ea"),
        parseHex("75fd1af0"),
        parseHex("50f5bf4e"),
        parseHex("643d5f41"),
        parseHex("6f4fe718"),
        parseHex("5b3cbbde"),
        parseHex("1e3afb3e"),
        parseHex("296fb027"),
        parseHex("45e1547b"),
        parseHex("4a8db2ab"),
    },
    .{
        parseHex("59986d19"),
        parseHex("30bcdfa3"),
        parseHex("1db63932"),
        parseHex("1d7c2824"),
        parseHex("53b33681"),
        parseHex("0673b747"),
        parseHex("038a98a3"),
        parseHex("2c5bce60"),
        parseHex("351979cd"),
        parseHex("5008fb73"),
        parseHex("547bca78"),
        parseHex("711af481"),
        parseHex("3f93bf64"),
        parseHex("644d987b"),
        parseHex("3c8bcd87"),
        parseHex("608758b8"),
    },
};

const INTERNAL_RCS = [INTERNAL_ROUNDS]u32{
    parseHex("5a8053c0"),
    parseHex("693be639"),
    parseHex("3858867d"),
    parseHex("19334f6b"),
    parseHex("128f0fd8"),
    parseHex("4e2b1ccb"),
    parseHex("61210ce0"),
    parseHex("3c318939"),
    parseHex("0b5b2f22"),
    parseHex("2edb11d5"),
    parseHex("213effdf"),
    parseHex("0cac4606"),
    parseHex("241af16d"),
};

fn parseHex(s: []const u8) u32 {
    @setEvalBranchQuota(100_000);
    return std.fmt.parseInt(u32, s, 16) catch @compileError("OOM");
}

// Tests vectors were generated from the Poseidon2 reference repository: github.com/HorizenLabs/poseidon2
const testVector = struct {
    input_state: [WIDTH]u32,
    output_state: [WIDTH]u32,
};
test "reference repo" {
    @setEvalBranchQuota(100_000);

    const finite_fields = [_]type{
        @import("../fields/babybear/montgomery.zig").MontgomeryField,
        @import("../fields/babybear/naive.zig"),
    };
    inline for (finite_fields) |F| {
        const TestPoseidon2BabyBear = poseidon2.Poseidon2(
            F,
            WIDTH,
            INTERNAL_ROUNDS,
            EXTERNAL_ROUNDS,
            SBOX_DEGREE,
            DIAGONAL,
            EXTERNAL_RCS,
            INTERNAL_RCS,
        );
        const tests_vectors = [_]testVector{
            .{
                .input_state = std.mem.zeroes([WIDTH]u32),
                .output_state = .{ 1337856655, 1843094405, 328115114, 964209316, 1365212758, 1431554563, 210126733, 1214932203, 1929553766, 1647595522, 1496863878, 324695999, 1569728319, 1634598391, 597968641, 679989771 },
            },
            .{
                .input_state = [_]F.FieldElem{42} ** 16,
                .output_state = .{ 1000818763, 32822117, 1516162362, 1002505990, 932515653, 770559770, 350012663, 846936440, 1676802609, 1007988059, 883957027, 738985594, 6104526, 338187715, 611171673, 414573522 },
            },
        };
        for (tests_vectors) |test_vector| {
            try std.testing.expectEqual(test_vector.output_state, testPermutation(TestPoseidon2BabyBear, test_vector.input_state));
        }
    }
}

test "finite field implementation coherency" {
    const Poseidon2BabyBearNaive = poseidon2.Poseidon2(
        @import("../fields/babybear/naive.zig"),
        WIDTH,
        INTERNAL_ROUNDS,
        EXTERNAL_ROUNDS,
        SBOX_DEGREE,
        DIAGONAL,
        EXTERNAL_RCS,
        INTERNAL_RCS,
    );
    const Poseidon2BabyBearOptimized = poseidon2.Poseidon2(
        @import("../fields/babybear/montgomery.zig").MontgomeryField,
        WIDTH,
        INTERNAL_ROUNDS,
        EXTERNAL_ROUNDS,
        SBOX_DEGREE,
        DIAGONAL,
        EXTERNAL_RCS,
        INTERNAL_RCS,
    );
    var rand = std.Random.DefaultPrng.init(42);
    for (0..10_000) |_| {
        var input_state: [WIDTH]u32 = undefined;
        for (0..WIDTH) |index| {
            input_state[index] = @truncate(rand.next());
        }

        try std.testing.expectEqual(testPermutation(Poseidon2BabyBearNaive, input_state), testPermutation(Poseidon2BabyBearOptimized, input_state));
    }
}

fn testPermutation(comptime Poseidon2: type, state: [WIDTH]u32) [WIDTH]u32 {
    const F = Poseidon2.Field;
    var mont_state: [WIDTH]F.MontFieldElem = undefined;
    inline for (0..WIDTH) |j| {
        F.toMontgomery(&mont_state[j], state[j]);
    }
    Poseidon2.permutation(&mont_state);
    var ret: [WIDTH]u32 = undefined;
    inline for (0..WIDTH) |j| {
        ret[j] = F.toNormal(mont_state[j]);
    }
    return ret;
}
