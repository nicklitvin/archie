#!/usr/bin/env bash
# Previews Archie's defaults on a Chromium or Chrome you already have
# (version 153 or newer), without building anything. It launches that browser
# with a separate profile seeded with Archie's preferences and switches:
# vertical tab sidebar, no sign-in, no first-run, promo or help popups.
#
#   scripts/preview.sh [path/to/chrome] [extra chrome flags...]
#
# The profile lives in ~/.config/archie-preview (override with ARCHIE_PREVIEW_DIR).
# This is a preview only: nags that need a source patch to remove (for example
# the "Google API keys are missing" bar on some Chromium builds) may still show.
set -euo pipefail

browser="${1:-}"
if [[ -n "$browser" && -x "$browser" ]]; then
  shift
else
  browser=""
  for candidate in chromium chromium-browser google-chrome google-chrome-stable \
                   "/Applications/Chromium.app/Contents/MacOS/Chromium" \
                   "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"; do
    if command -v "$candidate" >/dev/null 2>&1; then browser="$(command -v "$candidate")"; break; fi
    if [[ -x "$candidate" ]]; then browser="$candidate"; break; fi
  done
fi
[[ -n "$browser" ]] || { echo "No Chromium/Chrome found; pass its path as the first argument." >&2; exit 1; }

dir="${ARCHIE_PREVIEW_DIR:-$HOME/.config/archie-preview}"
if [[ ! -e "$dir/Local State" ]]; then
  mkdir -p "$dir/Default"
  # Same defaults the Archie patches set at the source level.
  cat > "$dir/Default/Preferences" <<'JSON'
{
  "vertical_tabs": { "enabled": true },
  "signin": { "allowed": false, "allowed_on_next_startup": false },
  "browser": { "check_default_browser": false, "show_home_button": false },
  "bookmark_bar": { "show_on_all_tabs": false }
}
JSON
  cat > "$dir/Local State" <<'JSON'
{
  "browser": { "promotions_enabled": false },
  "profile": { "show_picker_on_startup": false }
}
JSON
fi

exec "$browser" \
  --user-data-dir="$dir" \
  --no-first-run \
  --no-default-browser-check \
  --propagate-iph-for-testing \
  --disable-search-engine-choice-screen \
  "$@"
