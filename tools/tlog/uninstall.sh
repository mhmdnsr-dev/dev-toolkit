#!/usr/bin/env bash
# Removes the links made by install.sh. Only removes links that point into this folder.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"

unlink_if_ours() {
  local link="$1"
  if [ -L "$link" ] && [[ "$(readlink "$link")" == "$here"/* ]]; then
    rm "$link"
    echo "removed $link"
  elif [ -e "$link" ] || [ -L "$link" ]; then
    echo "skipped $link (not a link to $here)"
  fi
}

if [ -e "$HOME/.config/systemd/user/tlog-remind.timer" ]; then
  "$here/tlog" remind stop
fi

unlink_if_ours "$HOME/.local/bin/tlog"
for skill in "$here"/skills/*/; do
  unlink_if_ours "$HOME/.claude/skills/$(basename "$skill")"
done
echo "Done. The tool files in $here were left in place."
