#!/usr/bin/env bash
# Builds Archie into $SRC/out/Archie. Extra arguments go to autoninja (e.g. -j8).
source "$(dirname "$0")/common.sh"

cd "$SRC"
mkdir -p "$OUT_DIR"
cp "$ARCHIE_ROOT/config/args.gn" "$OUT_DIR/args.gn"
log "Generating build files in $OUT_DIR"
gn gen "$OUT_DIR"

targets=(chrome)
[[ "$(uname -s)" == Linux ]] && targets+=(chrome_sandbox)
log "Building ${targets[*]}"
autoninja -C "$OUT_DIR" "${targets[@]}" "$@"
log "Done. Run it with: $SRC/$OUT_DIR/chrome   or package it with scripts/package.sh"
