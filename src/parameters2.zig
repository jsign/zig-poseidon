const std = @import("std");
const BN254Fr = @import("bn254/fr.zig");

const BN254W2 = PoseidonParameters(
    BN254Fr,
    2,
    4,
    56,
    @embedFile("bn254/optimized_poseidon_constants.json"),
);

fn PoseidonParameters(
    comptime ScalarField: type,
    comptime w: u8,
    comptime partial_rounds: u8,
    comptime half_full_rounds: u8,
    comptime json_spec: []const u8,
) type {
    _ = half_full_rounds;
    _ = partial_rounds;
    _ = w;
    _ = ScalarField;
    var alloc_buf: [10 * (1 << 20)]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&alloc_buf);
    var allocator = fba.allocator();

    const ParametersJSON = struct {
        C: [][][]const u8,
        M: [][][][]const u8,
        P: [][][][]const u8,
        S: [][][]const u8,
    };
    var parameters = try std.json.parseFromSliceLeaky(
        ParametersJSON,
        allocator,
        json_spec,
        .{},
    );
    defer parameters.deinit();

    // if (w - 2 >= parameters.C.len) {
    //     @compileError("width isn't supported");
    // }
    // const _Fr = ScalarField;

    // const Parameters = struct {
    //     C: [w * (half_full_rounds + 1) + partial_rounds + (half_full_rounds - 1) * w]_Fr.MontgomeryDomainFieldElement,
    //     M: [w][w]_Fr.MontgomeryDomainFieldElement,
    //     P: [w][w]_Fr.MontgomeryDomainFieldElement,
    //     S: [(w + (w - 1)) * partial_rounds]_Fr.MontgomeryDomainFieldElement,
    // };
    // const ret: Parameters = undefined;

    // const i = w;
    // for (0..parameters.value.C[i].len) |j| {
    //     var fe = try std.fmt.parseInt(u256, parameters.value.C[i][j], 0);
    //     var buf: [32]u8 = undefined;
    //     std.mem.writeIntLittle(@TypeOf(fe), &buf, fe);
    //     _Fr.fromBytes(&ret.C[i][j], buf);
    //     _Fr.toMontgomery(&ret.C[i][j], ret.C[i][j]);
    // }

    // for (0..parameters.value.M[i].len) |j| {
    //     for (0..parameters.value.M[i][j].len) |k| {
    //         var fe = try std.fmt.parseInt(u256, parameters.value.M[i][j][k], 0);
    //         var buf: [32]u8 = undefined;
    //         std.mem.writeIntLittle(@TypeOf(fe), &buf, fe);
    //         _Fr.fromBytes(&ret.M[i][j][k], buf);
    //         _Fr.toMontgomery(&ret.M[i][j][k], ret.M[i][j][k]);
    //     }
    // }

    // for (0..parameters.value.P[i].len) |j| {
    //     for (0..parameters.value.P[i][j].len) |k| {
    //         var fe = try std.fmt.parseInt(u256, parameters.value.P[i][j][k], 0);
    //         var buf: [32]u8 = undefined;
    //         std.mem.writeIntLittle(@TypeOf(fe), &buf, fe);
    //         _Fr.fromBytes(&ret.P[i][j][k], buf);
    //         _Fr.toMontgomery(&ret.P[i][j][k], ret.P[i][j][k]);
    //     }
    // }

    // for (0..parameters.value.S[i].len) |j| {
    //     var fe = try std.fmt.parseInt(u256, parameters.value.S[i][j], 0);
    //     var buf: [32]u8 = undefined;
    //     std.mem.writeIntLittle(@TypeOf(fe), &buf, fe);
    //     _Fr.fromBytes(&ret.S[i][j], buf);
    //     _Fr.toMontgomery(&ret.S[i][j], ret.S[i][j]);
    // }

    // return struct {
    //     const Fr = _Fr;
    //     const MontFr = Fr.MontgomeryDomainFieldElement;
    //     const NonMontFr = Fr.NonMontgomeryDomainFieldElement;

    //     const width = w;
    //     const F_r: u8 = partial_rounds;
    //     const F_P: u8 = half_full_rounds;

    //     const C: [w * (half_full_rounds + 1) + partial_rounds + (half_full_rounds - 1) * w]MontFr = ret.C;
    //     const M: [w][w]MontFr = ret.M;
    //     const P: [w][w]MontFr = ret.P;
    //     const S: [(w + (w - 1)) * partial_rounds]MontFr = ret.S;
    // };
    return struct {};
}

test "l" {
    comptime {
        var alloc_buf: [10 * (1 << 20)]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&alloc_buf);
        const Test = struct {
            C: [][]const u8,
        };
        const foo = try std.json.parseFromSliceLeaky(
            Test,
            fba.allocator(),
            "{ \"C\": [[1, 2, 3]] }",
            .{},
        );
        _ = foo;
    }

    // _ = BN254W2;
}
