#!/usr/bin/env python3
# Copyright 2026 The Archie Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
"""Renames the product from "Chromium" to "Archie" in user-visible strings.

Chromium keeps every product-specific UI string in chrome/app/chromium_strings.grd
(plus the .grdp parts it includes). Translations live in .xtb files keyed by a
fingerprint of the English text, so changing the English text changes the key.
This script rewrites the English strings, asks grit itself for the old and new
fingerprints of every message, and re-keys the translations to match. That
keeps all locales translated instead of silently falling back to English.

Usage: rebrand.py /path/to/chromium/src
"""

import pathlib
import re
import sys

PRODUCT = 'Archie'

# "Chromium" as a product name. Leaves "The Chromium Authors" (copyright
# lines), "Chromium OS"/"ChromiumOS" and lowercase URLs (chromium.org) alone.
PRODUCT_RE = re.compile(r'\bChromium\b(?! Authors)(?!\s?OS\b)')

GRD = 'chrome/app/chromium_strings.grd'
XTB_GLOB = 'chrome/app/resources/chromium_strings_*.xtb'


def message_ids(grd_path):
  """Returns the translation id of every message in the .grd, in file order.

  Names are not unique (platform variants share one), so callers pair up two
  parses of the same file by position."""
  from grit import grd_reader
  from grit.node import message

  root = grd_reader.Parse(str(grd_path), debug=False,
                          skip_validation_checks=True)
  return [node.GetCliques()[0].GetId()
          for node in root.Preorder()
          if isinstance(node, message.MessageNode)]


def rebrand_text(text):
  return PRODUCT_RE.sub(PRODUCT, text)


def main(src):
  src = pathlib.Path(src).resolve()
  sys.path.insert(0, str(src / 'tools' / 'grit'))
  grd = src / GRD

  sources = [grd] + sorted(grd.parent.glob('*chromium_strings.grdp'))
  if PRODUCT_RE.search(grd.read_text(encoding='utf-8')) is None:
    print('rebrand: already applied, nothing to do')
    return 0

  old_ids = message_ids(grd)
  for path in sources:
    path.write_text(rebrand_text(path.read_text(encoding='utf-8')),
                    encoding='utf-8')
  new_ids = message_ids(grd)

  assert len(old_ids) == len(new_ids), 'rebranding changed the message count'
  remap = {old: new for old, new in zip(old_ids, new_ids) if old != new}

  def rekey(match):
    return 'id="%s"' % remap.get(match.group(1), match.group(1))

  xtbs = sorted(src.glob(XTB_GLOB))
  for xtb in xtbs:
    text = xtb.read_text(encoding='utf-8')
    text = re.sub(r'id="(\d+)"', rekey, text)
    xtb.write_text(rebrand_text(text), encoding='utf-8')

  print('rebrand: %d strings renamed, %d translation files re-keyed' %
        (len(remap), len(xtbs)))
  return 0


if __name__ == '__main__':
  if len(sys.argv) != 2:
    sys.exit(__doc__)
  sys.exit(main(sys.argv[1]))
