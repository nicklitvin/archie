#!/usr/bin/env bash
# Downloads depot_tools and the Chromium source at the version in
# CHROMIUM_VERSION. Needs ~100 GB of disk and a few hours the first time.
source "$(dirname "$0")/common.sh"

if [[ ! -x "$DEPOT_TOOLS/gclient" ]]; then
  log "Cloning depot_tools into $DEPOT_TOOLS"
  git clone --depth 1 https://chromium.googlesource.com/chromium/tools/depot_tools.git "$DEPOT_TOOLS"
fi

mkdir -p "$CHROMIUM_DIR"
cat > "$CHROMIUM_DIR/.gclient" <<GCLIENT
solutions = [{
  "name": "src",
  "url": "https://chromium.googlesource.com/chromium/src.git@refs/tags/$CHROMIUM_VERSION",
  "managed": False,
  "custom_deps": {},
  "custom_vars": {"checkout_pgo_profiles": False},
}]
GCLIENT

log "Syncing Chromium $CHROMIUM_VERSION (this takes a while)"
cd "$CHROMIUM_DIR"
gclient sync --nohooks --no-history --shallow -D --force \
  --revision "src@refs/tags/$CHROMIUM_VERSION"

if [[ "$(uname -s)" == Linux && "${SKIP_BUILD_DEPS:-0}" != 1 ]]; then
  log "Installing build dependencies (needs sudo; set SKIP_BUILD_DEPS=1 to skip)"
  "$SRC/build/install-build-deps.sh" --no-prompt
fi

log "Running hooks"
gclient runhooks
log "Done. Next: scripts/prepare.sh"
