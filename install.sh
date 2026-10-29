#!/usr/bin/env bash
# Installs every tool under tools/, or only the ones named: ./install.sh [tool ...]
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"

if [ $# -gt 0 ]; then tools=("$@"); else mapfile -t tools < <(ls "$here/tools"); fi
for tool in "${tools[@]}"; do
  script="$here/tools/$tool/install.sh"
  if [ ! -x "$script" ]; then
    echo "✗ no install.sh for '$tool' (tools: $(ls "$here/tools" | paste -sd' '))" >&2
    exit 1
  fi
  echo "== $tool"
  "$script"
done
