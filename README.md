# poseidon

A Zig implementation of the Poseidon2 cryptographic hash function.

## Supported Configurations

Currently, this implementation provides:

- BabyBear finite field with a width of 16 elements
- Generic Montgomery form implementation for finite fields of 31 bits or less
- Compression mode, since it's the recommended mode for Merkle Trees compared to the sponge construction.

The generic implementation makes it straightforward to add support for additional 31-bit fields.

## Project Motivation

This repository was created primarily to support the upcoming Ethereum Beam chain. The implementation will be updated to match the required configuration once the specifications are finalized.

With time this repository can keep expaning on features:

- Add support for more finite fields.
- Add support for the sponge construction.
- Add benchmarks and optimizations.

## Compatibility

This implementation has been cross-validated against the [reference repository](https://github.com/HorizenLabs/poseidon2) cited in the Poseidon2 paper to ensure correctness.

## License

MIT
