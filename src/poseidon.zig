const std = @import("std");
const parameters = @import("parameters.zig");

pub fn Poseidon(comptime Fr: type, comptime w: u8) type {
    return struct {
        config: parameters.PoseidonFamilyParameters(Fr),

        pub fn init(config: parameters.PoseidonFamilyParameters(Fr)) @This() {
            return .{
                .config = config,
            };
        }

        pub fn hash(
            self: *@This(),
            input: [w - 1]Fr.MontgomeryDomainFieldElement,
        ) Fr.NonMontgomeryDomainFieldElement {
            // State initialization
            var state: [w]Fr.MontgomeryDomainFieldElement = undefined;
            state[0] = std.mem.zeroes(Fr.MontgomeryDomainFieldElement);
            inline for (1..w) |i| {
                state[i] = input[i - 1];
            }

            const wp = self.config.get_params_for_width(w);

            // Adds the pre-r=0 round constants
            ark(&state, wp.C);

            // Performs all but the last first-half of full rounds r in [R_f-1].
            for (0..wp.R_f - 1) |r| {
                full_round(&state, wp.C[w + r * w ..], wp.M);
            }

            // Performs the last first-half full round r=R_f-1.
            full_round(&state, wp.C[w * wp.R_f ..], wp.P);

            // Perform the partial-rounds r in [R_f, R_f+R_p].
            // TODO: inline.
            for (0..wp.R_P) |r| {
                partial_round(&state, wp.C[w * (wp.R_f + 1) + r], wp.S[(w + (w - 1)) * r ..]);
            }

            // Performs all but the last second-half full rounds r in [R_f+R_p, R-1] .
            // TODO: inline.
            for (0..wp.R_f - 1) |r| {
                full_round(&state, wp.C[w * (wp.R_f + 1) + (wp.R_P) + r * w ..], wp.M);
            }

            // Performs the last second-half rull round r=R-1.
            inline for (0..w) |i| {
                state[i] = exp5(state[i]);
            }
            mds_mixing(&state, wp.M);

            var non_mont_result: Fr.NonMontgomeryDomainFieldElement = undefined;
            Fr.fromMontgomery(&non_mont_result, state[0]);

            return non_mont_result;
        }

        inline fn ark(
            state: *[w]Fr.MontgomeryDomainFieldElement,
            C: []Fr.MontgomeryDomainFieldElement,
        ) void {
            inline for (0..w) |i| {
                Fr.add(&state[i], state[i], C[i]);
            }
        }

        inline fn full_round(
            state: *[w]Fr.MontgomeryDomainFieldElement,
            C: []Fr.MontgomeryDomainFieldElement,
            M: [][]Fr.MontgomeryDomainFieldElement,
        ) void {
            inline for (0..w) |i| {
                state[i] = exp5(state[i]);
            }
            ark(state, C);
            mds_mixing(state, M);
        }

        inline fn partial_round(
            state: *[w]Fr.MontgomeryDomainFieldElement,
            C_r: Fr.MontgomeryDomainFieldElement,
            S: []Fr.MontgomeryDomainFieldElement,
        ) void {
            // Note that the way this code works is dependant on how the parameters are generated.
            // In particular, since S is a sparse-matrix, there're some assumptions in the encoding of parameters.
            // As in, the paper describes the steps as:
            // 1. state[0] = state[0]^alpha + RoundConstants
            // 2. state = state * S
            //
            // The last step is a matrix multiplication, but since S is sparse with a defined structure (see the paper),
            // the logic is simplified. i.e: the first row and column have non-zero elements. The rest of the matrix is
            // the identity matrix.

            // Do the expected ark(..) as described in step 1. above.
            Fr.add(&state[0], exp5(state[0]), C_r);

            // We do the matrix multiplication in two steps.

            // First, we calculate the first element where S has all non-zero element in the first row.
            var state0: Fr.MontgomeryDomainFieldElement = std.mem.zeroes(Fr.MontgomeryDomainFieldElement);
            for (0..w) |i| {
                var tmp: Fr.MontgomeryDomainFieldElement = undefined;
                Fr.mul(&tmp, S[i], state[i]);
                Fr.add(&state0, state0, tmp);
            }

            // Second, we calculate the new state results that contain internal identity submatrix.
            for (1..w) |i| {
                var tmp: Fr.MontgomeryDomainFieldElement = undefined;
                Fr.mul(&tmp, S[w + i - 1], state[0]); // First non-zero column cell in IPA.
                Fr.add(&state[i], state[i], tmp); // i-th column having a value of 1 (identity sub-matrix).
            }
            state[0] = state0;
        }

        inline fn mds_mixing(
            state: *[w]Fr.MontgomeryDomainFieldElement,
            M: [][]Fr.MontgomeryDomainFieldElement,
        ) void {
            var new_state: [w]Fr.MontgomeryDomainFieldElement = undefined;
            for (0..M.len) |i| {
                var res: Fr.MontgomeryDomainFieldElement = std.mem.zeroes(Fr.MontgomeryDomainFieldElement);
                inline for (0..w) |j| {
                    var tmp: Fr.MontgomeryDomainFieldElement = undefined;
                    Fr.mul(&tmp, state[j], M[j][i]);
                    Fr.add(&res, res, tmp);
                }
                new_state[i] = res;
            }
            for (0..state.len) |i| {
                state[i] = new_state[i];
            }
        }

        inline fn exp5(
            e: Fr.MontgomeryDomainFieldElement,
        ) Fr.MontgomeryDomainFieldElement {
            var r: Fr.MontgomeryDomainFieldElement = undefined;
            Fr.square(&r, e);
            Fr.square(&r, r);
            Fr.mul(&r, r, e);
            return r;
        }

        fn nonMont(a: Fr.MontgomeryDomainFieldElement) Fr.MontgomeryDomainFieldElement {
            var j: Fr.NonMontgomeryDomainFieldElement = undefined;
            Fr.fromMontgomery(&j, a);
            return j;
        }
    };
}
