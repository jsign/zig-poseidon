# poseidon

A Zig implementation of the Poseidon hash function, using the [Neptune optimizations](https://github.com/lurk-lab/neptune/blob/ef14a61b1aa7f8e92e6ace2190723c155e613a4a/spec/poseidon_spec.pdf).

## Supported finite fields

This implementation is currently targeting BN254 scalar field (i.e: BabyJubJub base field), to be compatible with:
- [CircomLib](https://github.com/iden3/circomlib) repository.
- [go-iden3-crypto](https://github.com/iden3/go-iden3-crypto/tree/master/poseidon) implementation.
- [poseidon-rs](https://github.com/arnaucube/poseidon-rs) implementation.

See the [compatibility tests](https://github.com/jsign/poseidon/blob/main/src/bn254/tests.zig).

The parameters for BN254 were [pulled from CircomLib](https://github.com/iden3/circomlibjs/blob/4f094c5be05c1f0210924a3ab204d8fd8da69f49/src/poseidon_constants.json) which can be generated with the [official Sage script](https://extgit.iaik.tugraz.at/krypto/hadeshash) and transformed using a [CircomLibJS tool](https://github.com/iden3/circomlibjs/blob/main/tools/poseidon_optimize_constants.js) created by @jbaylina.

Supporting other fields (e.g: BLS12-381 scalar field) would only involve generating the parameters.

## Benchmarks

This implementation doesn't use assembly (e.g: AVX2) or SIMD instructions for finite field operations.

Run on _AMD Ryzen 7 3800XT_:
```
$ zig build run -Doptimize=ReleaseFast 
Poseidon(width=1) took 13µs
Poseidon(width=2) took 20µs
Poseidon(width=3) took 26µs
Poseidon(width=4) took 35µs
Poseidon(width=5) took 44µs
Poseidon(width=6) took 55µs
Poseidon(width=7) took 64µs
Poseidon(width=8) took 73µs
Poseidon(width=9) took 81µs
Poseidon(width=10) took 97µs
```

## Future work

Due to some limitations of JSON at `comptime`, the parameter parsing is dynamic for now. Whenever this gets fixed, we can avoid this (init) runtime overhead and strip down the binary size.

## License

MIT