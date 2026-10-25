#!/usr/bin/env bash
# Turns a Chromium checkout into Archie: applies patches/series, installs the
# branding and renames the product in UI strings. Safe to re-run.
#   --reset   discard all local changes in the checkout first
source "$(dirname "$0")/common.sh"

[[ -d "$SRC/.git" ]] || die "No Chromium checkout at $SRC. Run scripts/fetch.sh first."

if [[ "${1:-}" == --reset ]]; then
  log "Resetting $SRC to a clean $CHROMIUM_VERSION"
  git -C "$SRC" reset --hard --quiet
  git -C "$SRC" clean -fdq
fi

while read -r patch; do
  name="${patch#"$ARCHIE_ROOT"/patches/}"
  if git -C "$SRC" apply --reverse --check "$patch" 2>/dev/null; then
    log "already applied: $name"
  else
    git -C "$SRC" apply "$patch" || die "failed to apply $name (try --reset)"
    log "applied: $name"
  fi
done < <(series)

cp "$ARCHIE_ROOT/branding/BRANDING" "$SRC/chrome/app/theme/chromium/BRANDING"
log "installed branding"

python3 "$ARCHIE_ROOT/scripts/rebrand.py" "$SRC"
log "Done. Next: scripts/build.sh"
