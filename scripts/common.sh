# Shared settings for Archie scripts. Source this, don't run it.
set -euo pipefail

ARCHIE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHROMIUM_VERSION="$(tr -d '[:space:]' < "$ARCHIE_ROOT/CHROMIUM_VERSION")"
ARCHIE_VERSION="$(tr -d '[:space:]' < "$ARCHIE_ROOT/ARCHIE_VERSION")"

# GitHub repository whose releases Archie checks for updates and patch notes.
ARCHIE_UPDATE_REPO="${ARCHIE_UPDATE_REPO:-nicklitvin/archie}"

# Where the Chromium checkout lives (~100 GB). Override to put it elsewhere.
CHROMIUM_DIR="${CHROMIUM_DIR:-$ARCHIE_ROOT/build/chromium}"
SRC="$CHROMIUM_DIR/src"
OUT_DIR="${OUT_DIR:-out/Archie}"
DEPOT_TOOLS="${DEPOT_TOOLS:-$ARCHIE_ROOT/build/depot_tools}"

export PATH="$DEPOT_TOOLS:$PATH"
# Use the system toolchain on Linux; avoids downloading Google-internal ones.
export DEPOT_TOOLS_WIN_TOOLCHAIN=0

log() { printf '\033[1;35m[archie]\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m[archie]\033[0m %s\n' "$*" >&2; exit 1; }

# Prints the patch files listed in patches/series, one absolute path per line.
series() {
  grep -v -e '^\s*#' -e '^\s*$' "$ARCHIE_ROOT/patches/series" |
    sed "s|^|$ARCHIE_ROOT/patches/|"
}
