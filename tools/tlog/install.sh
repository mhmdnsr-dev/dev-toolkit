#!/usr/bin/env bash
# Links tlog onto PATH and the skills into Claude Code's user skills folder.
# Creates ~/.config/tlog/config.env from the example if you don't have one yet.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
config="$HOME/.config/tlog/config.env"

mkdir -p "$HOME/.local/bin" "$HOME/.claude/skills"
ln -sfn "$here/tlog" "$HOME/.local/bin/tlog"
for skill in "$here"/skills/*/; do
  ln -sfn "${skill%/}" "$HOME/.claude/skills/$(basename "$skill")"
done
echo "tlog   -> $HOME/.local/bin/tlog"
echo "skills -> $HOME/.claude/skills/{$(ls "$here/skills" | paste -sd,)}"

if [ ! -e "$config" ]; then
  mkdir -p "$(dirname "$config")"
  cp "$here/config.example.env" "$config"
  echo "config -> $config (created from the example: edit it before using tlog)"
else
  echo "config -> $config (kept)"
fi
