#!/usr/bin/env bash
# Merge the repo starship.toml (prompt structure + default Kanagawa palette)
# with the Noctalia-rendered palette into a machine-local config. The repo
# file is only ever read; starship rereads STARSHIP_CONFIG every prompt, so
# running shells recolor live.
set -euo pipefail

base="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
palette="${XDG_CACHE_HOME:-$HOME/.cache}/noctalia/starship-palette.toml"
out="${XDG_CONFIG_HOME:-$HOME/.config}/starship-noctalia.toml"
begin="# >>> NOCTALIA PALETTE"
end="# <<< NOCTALIA PALETTE"

if [ ! -f "$base" ] || [ ! -f "$palette" ]; then
    echo "Error: missing $base or $palette" >&2
    exit 1
fi

tmp="$(mktemp "${out}.tmp.XXXXXX")"
{
    awk -v b="$begin" -v e="$end" '
        index($0, b) == 1 { skip = 1; next }
        skip { if (index($0, e) == 1) skip = 0; next }
        { print }
    ' "$base"
    cat "$palette"
} >"$tmp"
mv "$tmp" "$out" # out is machine-local by design, never a symlink
