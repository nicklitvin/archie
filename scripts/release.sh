#!/usr/bin/env bash
# Publishes the packaged build as a GitHub release, which is what running
# Archie copies check for updates and show as patch notes.
#
#   scripts/release.sh NOTES.md
#
# NOTES.md becomes the release notes shown in Archie's Patch notes window.
# Before running: bump ARCHIE_VERSION, then run prepare.sh, build.sh and
# package.sh. Needs the GitHub CLI (gh), logged in to $ARCHIE_UPDATE_REPO.
source "$(dirname "$0")/common.sh"

notes="${1:-}"
[[ -n "$notes" && -f "$notes" ]] || die "Usage: scripts/release.sh NOTES.md"
command -v gh >/dev/null || die "Install the GitHub CLI (gh) first."

tarball="$ARCHIE_ROOT/dist/archie-$ARCHIE_VERSION-linux-x64.tar.xz"
[[ -f "$tarball" ]] || die "No $tarball. Run scripts/package.sh first."

tag="v$ARCHIE_VERSION"
log "Publishing Archie $ARCHIE_VERSION as $tag on $ARCHIE_UPDATE_REPO"
gh release create "$tag" "$tarball" \
  --repo "$ARCHIE_UPDATE_REPO" \
  --title "Archie $ARCHIE_VERSION" \
  --notes-file "$notes"
log "Done. Older Archie builds show 'Update available' when a window opens, or within six hours."
