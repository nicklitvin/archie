#!/usr/bin/env bash
# Packages a Linux build into dist/archie-<version>-linux-x64.tar.xz with an
# `archie` launcher and a .desktop entry.
source "$(dirname "$0")/common.sh"

out="$SRC/$OUT_DIR"
[[ -x "$out/chrome" ]] || die "No build at $out. Run scripts/build.sh first."

name="archie-$CHROMIUM_VERSION-linux-x64"
stage="$ARCHIE_ROOT/dist/$name"
rm -rf "$stage" && mkdir -p "$stage"

cd "$out"
for f in chrome chrome_crashpad_handler chrome_100_percent.pak chrome_200_percent.pak \
         resources.pak icudtl.dat v8_context_snapshot.bin snapshot_blob.bin \
         libEGL.so libGLESv2.so libvk_swiftshader.so libvulkan.so.1 \
         vk_swiftshader_icd.json libqt5_shim.so libqt6_shim.so locales; do
  [[ -e "$f" ]] && cp -r "$f" "$stage/"
done
[[ -e chrome_sandbox ]] && cp chrome_sandbox "$stage/chrome-sandbox"
cp "$ARCHIE_ROOT/packaging/linux/archie" "$stage/archie"
cp "$ARCHIE_ROOT/packaging/linux/archie.desktop" "$stage/archie.desktop"
[[ -e "$SRC/chrome/app/theme/chromium/product_logo_256.png" ]] &&
  cp "$SRC/chrome/app/theme/chromium/product_logo_256.png" "$stage/archie.png"

cd "$ARCHIE_ROOT/dist"
tar -cJf "$name.tar.xz" "$name"
log "Wrote dist/$name.tar.xz"
log "The sandbox helper needs root: sudo chown root:root chrome-sandbox && sudo chmod 4755 chrome-sandbox"
