const std = @import("std");
const assert = std.debug.assert;

pub fn Poseidon2(
    comptime F: type,
    comptime width: comptime_int,
    comptime int_rounds: comptime_int,
    comptime ext_rounds: comptime_int,
    comptime sbox_degree: comptime_int,
    internal_diagonal: [width]u32,
    external_rcs: [ext_rounds][width]u32,
    internal_rcs: [int_rounds]u32,
) type {
    comptime var ext_rcs: [ext_rounds][width]F.MontgomeryDomainFieldElement = undefined;
    for (0..ext_rounds) |i| {
        for (0..width) |j| {
            F.toMontgomery(&ext_rcs[i][j], external_rcs[i][j]);
        }
    }
    comptime var int_rcs: [int_rounds]F.MontgomeryDomainFieldElement = undefined;
    for (0..int_rounds) |i| {
        F.toMontgomery(&int_rcs[i], internal_rcs[i]);
    }
    comptime var int_diagonal: [width]F.MontgomeryDomainFieldElement = undefined;
    for (0..width) |i| {
        F.toMontgomery(&int_diagonal[i], internal_diagonal[i]);
    }
    return struct {
        pub const State = [width]MontFieldElem;
        pub const FieldElem = u32;
        pub const MontFieldElem = F.MontgomeryDomainFieldElement;

        pub fn compress(comptime output_len: comptime_int, input: [width]FieldElem) [output_len]FieldElem {
            assert(output_len <= width, "output_len must be <= width");

            var state: State = undefined;
            inline for (0..width) |i| {
                F.toMontgomery(&state[i], input[i]);
            }
            permutation(&state);
            inline for (0..width) |i| {
                F.add(&state[i], state[i], input[i]);
                F.fromMontgomery(&state[i], state[i]);
            }
            return state[0..output_len];
        }

        pub fn permutation(state: *State) void {
            mulExternal(state);
            inline for (0..ext_rounds / 2) |r| {
                addRCs(state, r);
                inline for (0..width) |i| {
                    state[i] = sbox(state[i]);
                }
                mulExternal(state);
            }

            const start = ext_rounds / 2;
            const end = start + int_rounds;
            for (start..end) |r| {
                F.add(&state[0], state[0], int_rcs[r - start]);
                state[0] = sbox(state[0]);
                mulInternal(state);
            }

            inline for (end..end + ext_rounds / 2) |r| {
                addRCs(state, r - int_rounds);
                inline for (0..width) |i| {
                    state[i] = sbox(state[i]);
                }
                mulExternal(state);
            }
        }

        inline fn mulExternal(state: *State) void {
            if (width < 8) {
                @compileError("only widths >= 8 are supported");
            }
            if (width % 4 != 0) {
                @compileError("only widths multiple of 4 are supported");
            }
            mulM4(state);

            // Calculate the "base" result as if we're doing
            // circ(M4, M4, ...) * state.
            var base = std.mem.zeroes([4]MontFieldElem);
            inline for (0..4) |i| {
                inline for (0..width / 4) |j| {
                    F.add(&base[i], base[i], state[(j << 2) + i]);
                }
            }
            // base has circ(M4, M4, ...)*state, add state now
            // to add the corresponding extra M4 "through the diagonal".
            for (0..width) |i| {
                F.add(&state[i], state[i], base[i & 0b11]);
            }
        }

        // mulM4 calculates 'M4*state' in a way we can later can calculate
        // circ(2*M4, M4, ...)*state from it.
        inline fn mulM4(input: *State) void {
            // Use HorizenLabs minimal multiplication algorithm to perform
            // the least amount of operations for it. Similar to an
            // addition/multiplication chain.
            const t4 = width / 4;
            inline for (0..t4) |i| {
                const start_index = i * 4;
                var t_0: MontFieldElem = undefined;
                F.add(&t_0, input[start_index], input[start_index + 1]);
                var t_1: MontFieldElem = undefined;
                F.add(&t_1, input[start_index + 2], input[start_index + 3]);
                var t_2: MontFieldElem = undefined;
                F.add(&t_2, input[start_index + 1], input[start_index + 1]);
                F.add(&t_2, t_2, t_1);
                var t_3: MontFieldElem = undefined;
                F.add(&t_3, input[start_index + 3], input[start_index + 3]);
                F.add(&t_3, t_3, t_0);
                var t_4 = t_1;
                F.add(&t_4, t_4, t_4);
                F.add(&t_4, t_4, t_4);
                F.add(&t_4, t_4, t_3);
                var t_5 = t_0;
                F.add(&t_5, t_5, t_5);
                F.add(&t_5, t_5, t_5);
                F.add(&t_5, t_5, t_2);
                var t_6 = t_3;
                F.add(&t_6, t_6, t_5);
                var t_7 = t_2;
                F.add(&t_7, t_7, t_4);
                input[start_index] = t_6;
                input[start_index + 1] = t_5;
                input[start_index + 2] = t_7;
                input[start_index + 3] = t_4;
            }
        }

        inline fn mulInternal(state: *State) void {
            // Calculate (1, ...) * state.
            var state_sum = state[0];
            inline for (1..width) |i| {
                F.add(&state_sum, state_sum, state[i]);
            }
            // Add corresponding diagonal factor.
            inline for (0..state.len) |i| {
                F.mul(&state[i], state[i], int_diagonal[i]);
                F.add(&state[i], state[i], state_sum);
            }
        }

        inline fn sbox(e: MontFieldElem) MontFieldElem {
            return switch (sbox_degree) {
                7 => blk: {
                    var e_squared: MontFieldElem = undefined;
                    F.square(&e_squared, e);
                    var e_forth: MontFieldElem = undefined;
                    F.square(&e_forth, e_squared);
                    var res: MontFieldElem = undefined;
                    F.mul(&res, e_forth, e_squared);
                    F.mul(&res, res, e);
                    break :blk res;
                },
                else => @compileError("sbox degree not supported"),
            };
        }

        inline fn addRCs(state: *State, round: u8) void {
            inline for (0..width) |i| {
                F.add(&state[i], state[i], ext_rcs[round][i]);
            }
        }
    };
}
