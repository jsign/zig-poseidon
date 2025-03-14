const std = @import("std");

const modulus = 15 * (1 << 27) + 1;
pub const FieldElem = u32;
pub const MontFieldElem = u32;

pub fn toMontgomery(out1: *MontFieldElem, value: FieldElem) void {
    out1.* = value;
}

pub fn toNormal(out1: MontFieldElem) FieldElem {
    return out1;
}

pub fn square(out1: *MontFieldElem, value: MontFieldElem) void {
    mul(out1, value, value);
}

pub fn add(out1: *MontFieldElem, elem1: MontFieldElem, elem2: MontFieldElem) void {
    var tmp: u64 = elem1;
    tmp += elem2;
    tmp %= modulus;
    out1.* = @intCast(tmp);
}

pub fn mul(out1: *MontFieldElem, elem1: MontFieldElem, elem2: MontFieldElem) void {
    var tmp: u64 = elem1;
    tmp *= elem2;
    tmp %= modulus;
    out1.* = @intCast(tmp);
}
