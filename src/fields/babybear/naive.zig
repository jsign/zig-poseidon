const std = @import("std");

const modulus = 15 * (1 << 27) + 1;
pub const MontgomeryDomainFieldElement = u32;
pub const NonMontgomeryDomainFieldElement = u32;

pub fn toMontgomery(out1: *MontgomeryDomainFieldElement, arg1: NonMontgomeryDomainFieldElement) void {
    out1.* = arg1;
}

pub fn square(out1: *MontgomeryDomainFieldElement, arg1: MontgomeryDomainFieldElement) void {
    mul(out1, arg1, arg1);
}

pub fn add(out1: *MontgomeryDomainFieldElement, arg1: MontgomeryDomainFieldElement, arg2: MontgomeryDomainFieldElement) void {
    var tmp: u64 = arg1;
    tmp += arg2;
    tmp %= modulus;
    out1.* = @intCast(tmp);
}

pub fn mul(out1: *MontgomeryDomainFieldElement, arg1: MontgomeryDomainFieldElement, arg2: MontgomeryDomainFieldElement) void {
    var tmp: u64 = arg1;
    tmp *= arg2;
    tmp %= modulus;
    out1.* = @intCast(tmp);
}
