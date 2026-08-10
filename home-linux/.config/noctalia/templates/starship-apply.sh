#!/usr/bin/env bash
# Merge the repo starship.toml with the Noctalia palette into a machine-local
# config. The repo file is only ever read.
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
