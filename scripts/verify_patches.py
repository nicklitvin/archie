#!/usr/bin/env python3
# Copyright 2026 The Archie Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
"""Checks that every patch in patches/series applies to upstream Chromium.

Needs no Chromium checkout: it downloads just the files the patches touch
from chromium.googlesource.com at the tag in CHROMIUM_VERSION, then runs
`git apply --check` on the series in order. Used by CI and handy before
bumping CHROMIUM_VERSION.

Usage: verify_patches.py [--keep DIR]
"""

import base64
import pathlib
import re
import subprocess
import sys
import tempfile
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parent.parent
GITILES = 'https://chromium.googlesource.com/chromium/src/+/refs/tags/%s/%s?format=TEXT'


def series():
  for line in (ROOT / 'patches' / 'series').read_text().splitlines():
    line = line.strip()
    if line and not line.startswith('#'):
      yield ROOT / 'patches' / line


def fetch(version, path, dest):
  url = GITILES % (version, path)
  for attempt in range(4):
    try:
      with urllib.request.urlopen(url, timeout=60) as response:
        data = base64.b64decode(response.read())
      break
    except OSError:
      if attempt == 3:
        raise
  dest.parent.mkdir(parents=True, exist_ok=True)
  dest.write_bytes(data)


def main(argv):
  version = (ROOT / 'CHROMIUM_VERSION').read_text().strip()
  keep = pathlib.Path(argv[argv.index('--keep') + 1]) if '--keep' in argv else None
  work = keep or pathlib.Path(tempfile.mkdtemp(prefix='archie-verify-'))
  work.mkdir(parents=True, exist_ok=True)

  patches = list(series())
  files = sorted({m for p in patches
                  for m in re.findall(r'^\+\+\+ b/(\S+)', p.read_text(), re.M)})
  print('Chromium %s: fetching %d files' % (version, len(files)))
  for path in files:
    fetch(version, path, work / path)

  subprocess.run(['git', 'init', '-q'], cwd=work, check=True)
  failed = 0
  for patch in patches:
    name = patch.relative_to(ROOT / 'patches')
    result = subprocess.run(['git', 'apply', '--check', str(patch)], cwd=work,
                            capture_output=True, text=True)
    if result.returncode == 0:
      # Apply for real so later patches see earlier ones, like prepare.sh.
      subprocess.run(['git', 'apply', str(patch)], cwd=work, check=True)
      print('  ok    %s' % name)
    else:
      failed += 1
      print('  FAIL  %s\n%s' % (name, result.stderr.rstrip()))

  print('%d/%d patches apply cleanly' % (len(patches) - failed, len(patches)))
  return 1 if failed else 0


if __name__ == '__main__':
  sys.exit(main(sys.argv[1:]))
