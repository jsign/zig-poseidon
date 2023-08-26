const std = @import("std");
const Allocator = std.mem.Allocator;
const BabyJubJubFr = @import("bn254/fr.zig");

// PoseidonParameters describes a set of configuration parameters for Poseidon setups for different `WIDTH`s.
pub fn PoseidonFamilyParameters(comptime Fr: type) type {
    return struct {
        const Parameters = struct {
            C: [][]Fr.MontgomeryDomainFieldElement,
            M: [][][]Fr.MontgomeryDomainFieldElement,
            P: [][][]Fr.MontgomeryDomainFieldElement,
            S: [][]Fr.MontgomeryDomainFieldElement,
        };

        allocator: Allocator,
        parameters: Parameters,

        pub fn init(allocator: Allocator, json_spec: []const u8) !@This() {
            const ParametersJSON = struct {
                C: [][][]const u8,
                M: [][][][]const u8,
                P: [][][][]const u8,
                S: [][][]const u8,
            };
            var parameters = try std.json.parseFromSlice(
                ParametersJSON,
                allocator,
                json_spec,
                .{ .allocate = std.json.AllocWhen.alloc_always },
            );
            defer parameters.deinit();

            var ret = Parameters{
                .C = try allocator.alloc([]Fr.MontgomeryDomainFieldElement, parameters.value.C.len),
                .M = try allocator.alloc([][]Fr.MontgomeryDomainFieldElement, parameters.value.M.len),
                .P = try allocator.alloc([][]Fr.MontgomeryDomainFieldElement, parameters.value.P.len),
                .S = try allocator.alloc([]Fr.MontgomeryDomainFieldElement, parameters.value.S.len),
            };

            for (0..parameters.value.C.len) |i| {
                ret.C[i] = try allocator.alloc(Fr.MontgomeryDomainFieldElement, parameters.value.C[i].len);
                for (0..parameters.value.C[i].len) |j| {
                    var fe = try std.fmt.parseInt(u256, parameters.value.C[i][j], 0);
                    var buf: [32]u8 = undefined;
                    std.mem.writeIntLittle(@TypeOf(fe), &buf, fe);
                    Fr.fromBytes(&ret.C[i][j], buf);
                    Fr.toMontgomery(&ret.C[i][j], ret.C[i][j]);
                }
            }

            for (0..parameters.value.M.len) |i| {
                ret.M[i] = try allocator.alloc([]Fr.MontgomeryDomainFieldElement, parameters.value.M[i].len);
                for (0..parameters.value.M[i].len) |j| {
                    ret.M[i][j] = try allocator.alloc(Fr.MontgomeryDomainFieldElement, parameters.value.M[i][j].len);
                    for (0..parameters.value.M[i][j].len) |k| {
                        var fe = try std.fmt.parseInt(u256, parameters.value.M[i][j][k], 0);
                        var buf: [32]u8 = undefined;
                        std.mem.writeIntLittle(@TypeOf(fe), &buf, fe);
                        Fr.fromBytes(&ret.M[i][j][k], buf);
                        Fr.toMontgomery(&ret.M[i][j][k], ret.M[i][j][k]);
                    }
                }
            }

            for (0..parameters.value.P.len) |i| {
                ret.P[i] = try allocator.alloc([]Fr.MontgomeryDomainFieldElement, parameters.value.P[i].len);
                for (0..parameters.value.P[i].len) |j| {
                    ret.P[i][j] = try allocator.alloc(Fr.MontgomeryDomainFieldElement, parameters.value.P[i][j].len);
                    for (0..parameters.value.P[i][j].len) |k| {
                        var fe = try std.fmt.parseInt(u256, parameters.value.P[i][j][k], 0);
                        var buf: [32]u8 = undefined;
                        std.mem.writeIntLittle(@TypeOf(fe), &buf, fe);
                        Fr.fromBytes(&ret.P[i][j][k], buf);
                        Fr.toMontgomery(&ret.P[i][j][k], ret.P[i][j][k]);
                    }
                }
            }

            for (0..parameters.value.S.len) |i| {
                ret.S[i] = try allocator.alloc(Fr.MontgomeryDomainFieldElement, parameters.value.S[i].len);
                for (0..parameters.value.S[i].len) |j| {
                    var fe = try std.fmt.parseInt(u256, parameters.value.S[i][j], 0);
                    var buf: [32]u8 = undefined;
                    std.mem.writeIntLittle(@TypeOf(fe), &buf, fe);
                    Fr.fromBytes(&ret.S[i][j], buf);
                    Fr.toMontgomery(&ret.S[i][j], ret.S[i][j]);
                }
            }

            return .{
                .allocator = allocator,
                .parameters = ret,
            };
        }

        pub fn deinit(self: *@This()) void {
            for (self.parameters.C) |c| {
                self.allocator.free(c);
            }
            self.allocator.free(self.parameters.C);

            for (self.parameters.M) |m1| {
                for (m1) |m2| {
                    self.allocator.free(m2);
                }
                self.allocator.free(m1);
            }
            self.allocator.free(self.parameters.M);

            for (self.parameters.P) |p1| {
                for (p1) |p2| {
                    self.allocator.free(p2);
                }
                self.allocator.free(p1);
            }
            self.allocator.free(self.parameters.P);

            for (self.parameters.S) |s| {
                self.allocator.free(s);
            }
            self.allocator.free(self.parameters.S);
        }

        pub fn get_params_for_width(self: *@This(), w: u8) struct {
            C: []Fr.MontgomeryDomainFieldElement,
            M: [][]Fr.MontgomeryDomainFieldElement,
            P: [][]Fr.MontgomeryDomainFieldElement,
            S: []Fr.MontgomeryDomainFieldElement,
            R_f: u8,
            R_P: u8,
        } {
            return .{
                .C = self.parameters.C[w - 2],
                .M = self.parameters.M[w - 2],
                .P = self.parameters.P[w - 2],
                .S = self.parameters.S[w - 2],
                .R_f = 8 / 2,
                .R_P = switch (w) {
                    2 => 56,
                    3 => 57,
                    4 => 56,
                    5 => 60,
                    6 => 60,
                    7 => 63,
                    8 => 64,
                    9 => 63,
                    10 => 60,
                    11 => 66,
                    12 => 60,
                    13 => 65,
                    14 => 70,
                    15 => 60,
                    16 => 64,
                    17 => 68,
                    else => unreachable,
                },
            };
        }
    };
}

// get_babyjubjub_parameters returns the parameters for the BabyJubJub curve.
// The caller is responsible for calling `deinit` on the returned parameters.
pub fn get_babyjubjub_parameters(allocator: Allocator) !PoseidonFamilyParameters(BabyJubJubFr) {
    return try PoseidonFamilyParameters(BabyJubJubFr).init(
        allocator,
        @embedFile("bn254/optimized_poseidon_constants.json"),
    );
}
