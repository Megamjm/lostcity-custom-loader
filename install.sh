#!/bin/bash
# Copy loader + provided packages onto the Unraid custom tree.
set -euo pipefail
ROOT="${CUSTOM_ROOT:-/mnt/user/Data/runescape_custom/custom}"
REPO="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$ROOT/_loader"
cp -a "$REPO/loader/." "$ROOT/_loader/"
chmod +x "$ROOT/_loader/"*.sh 2>/dev/null || true

if [[ -d "$REPO/packages" ]]; then
  for pack in "$REPO/packages"/*; do
    [[ -d "$pack" ]] || continue
    name="$(basename "$pack")"
    rm -rf "$ROOT/$name"
    mkdir -p "$ROOT/$name"
    cp -a "$pack/." "$ROOT/$name/"
    echo "installed pack $name -> $ROOT/$name"
  done
fi

echo "custom tree: $ROOT"
echo "restart: docker restart lostcity"
echo "logs:    docker logs -f --tail 80 lostcity"
