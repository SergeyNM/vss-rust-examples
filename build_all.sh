#!/usr/bin/env sh

# Exit immediately if a command exits with a non-zero status
set -e

echo "--- [1/3] Building vss-rust core (Interop Layer) ---"
alr exec -- cargo build --release --manifest-path ../vss-rust/Cargo.toml

echo "--- [2/3] Building Rust examples (Static Libraries) ---"
alr exec -- cargo build --release

echo "--- [3/3] Building Ada executables (Linking) ---"
alr build --release

echo ""
echo "Build complete! Executables are in the './bin' directory."
