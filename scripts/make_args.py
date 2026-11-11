#!/usr/bin/env python3
# Copyright 2026 The Archie Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
"""Writes OUT_DIR/args.gn from config/args.gn, with the low-memory overrides
merged in when asked. GN rejects a variable set twice, so overrides replace
lines instead of being appended.

Usage: make_args.py OUT_DIR [--low-memory]
"""

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
ASSIGN = re.compile(r'^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=')


def assignments(path):
  out = {}
  for line in path.read_text().splitlines():
    m = ASSIGN.match(line)
    if m:
      out[m.group(1)] = line.strip()
  return out


def main(argv):
  if not argv:
    sys.exit(__doc__)
  out_dir = pathlib.Path(argv[0])
  lines = (ROOT / 'config' / 'args.gn').read_text().splitlines()
  if '--low-memory' in argv:
    overrides = assignments(ROOT / 'config' / 'args-low-memory.gn')
    merged = []
    for line in lines:
      m = ASSIGN.match(line)
      if m and m.group(1) in overrides:
        merged.append(overrides.pop(m.group(1)) + '  # low-memory override')
      else:
        merged.append(line)
    if overrides:
      merged += ['', '# Low-memory overrides'] + list(overrides.values())
    lines = merged
  out_dir.mkdir(parents=True, exist_ok=True)
  (out_dir / 'args.gn').write_text('\n'.join(lines) + '\n', newline='\n')
  print('wrote %s%s' % (out_dir / 'args.gn', ' (low memory)' if '--low-memory' in argv else ''))


if __name__ == '__main__':
  main(sys.argv[1:])
