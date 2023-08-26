# poseidon

A Zig implementation of the Poseidon hash function, using the [Neptune optimizations](https://github.com/lurk-lab/neptune/blob/ef14a61b1aa7f8e92e6ace2190723c155e613a4a/spec/poseidon_spec.pdf).

## Supported finite fields

This implementation is currently targeting BN254 scalar field (i.e: BabyJubJub base field), to be compatible with:
- [CircomLib](https://github.com/iden3/circomlib) repository.
- [go-iden3-crypto](https://github.com/iden3/go-iden3-crypto/tree/master/poseidon) implementation.
- [poseidon-rs](https://github.com/arnaucube/poseidon-rs) implementation.

The parameters for BN254 were [pulled from CircomLib](https://github.com/iden3/circomlibjs/blob/4f094c5be05c1f0210924a3ab204d8fd8da69f49/src/poseidon_constants.json) which can be generated with the [official Sage script](https://extgit.iaik.tugraz.at/krypto/hadeshash) and transformed using a [CircomLibJS tool](https://github.com/iden3/circomlibjs/blob/main/tools/poseidon_optimize_constants.js) created by @jbaylina.

Supporting other fields (e.g: BLS12-381 scalar field) would only involve generating the parameters.

## Benchmarks

To be included soon.

## Future work

Due to some limitations of JSON at `comptime`, the parameter parsing is dynamic for now. Whenever this gets fixed, we can avoid this (init) runtime overhead and strip down the binary size.

## License

MIT