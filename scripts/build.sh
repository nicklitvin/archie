#!/usr/bin/env bash
# Builds Archie into $SRC/out/Archie. Extra arguments go to autoninja (e.g. -j8).
source "$(dirname "$0")/common.sh"

cd "$SRC"
# ARCHIE_LOW_MEMORY=1 for machines with ~8 GB of RAM to spare (see config/args-low-memory.gn).
python3 "$ARCHIE_ROOT/scripts/make_args.py" "$OUT_DIR" ${ARCHIE_LOW_MEMORY:+--low-memory}
log "Generating build files in $OUT_DIR"
gn gen "$OUT_DIR"

targets=(chrome)
[[ "$(uname -s)" == Linux ]] && targets+=(chrome_sandbox)
log "Building ${targets[*]}"
autoninja -C "$OUT_DIR" ${ARCHIE_JOBS:+-j "$ARCHIE_JOBS"} "${targets[@]}" "$@"
log "Done. Run it with: $SRC/$OUT_DIR/chrome   or package it with scripts/package.sh"
