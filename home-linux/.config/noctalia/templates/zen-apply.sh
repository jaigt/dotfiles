#!/usr/bin/env bash
# Feed the wallpaper primary into Zen's native accent (zen.theme.accent-color)
# via user.js, and strip the @imports the retired full-restyle template once
# added. Native theming means no fights with Zen's own appearance settings;
# user.js re-pins the accent on every browser start.
set -euo pipefail

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
accent_file="$cache_dir/noctalia/zen-browser/accent"

if [ ! -f "$accent_file" ]; then
    echo "Error: accent file not found at $accent_file" >&2
    exit 1
fi
accent=$(tr -d '[:space:]' <"$accent_file")

replace_if_changed() {
    local target="$1" tmp="$2"
    if ! cmp -s "$target" "$tmp"; then
        cat "$tmp" >"$target" # write through symlinks, never mv over them
    fi
    rm -f "$tmp"
}

# Missing roots (~/.zen here) make find exit nonzero after streaming results;
# don't let pipefail turn that into a hook failure.
{ find "${XDG_CONFIG_HOME:-$HOME/.config}/zen" "$HOME/.zen" \
    -mindepth 2 -maxdepth 2 -type f -name "prefs.js" -print0 2>/dev/null || true; } |
    while IFS= read -r -d '' prefs_file; do
        profile_dir=$(dirname "$prefs_file")
        user_js="$profile_dir/user.js"

        # Retire the old wiring: drop our @import lines; empty leftovers vanish.
        for css in "$profile_dir/chrome/userChrome.css" "$profile_dir/chrome/userContent.css"; do
            [ -f "$css" ] || continue
            tmp="$(mktemp "${css}.tmp.XXXXXX")"
            sed '/noctalia\/zen-browser\/zen-user/d' "$css" >"$tmp"
            if [ ! -s "$tmp" ]; then
                rm -f "$tmp" "$css"
            else
                replace_if_changed "$css" "$tmp"
            fi
        done

        touch "$user_js"
        tmp="$(mktemp "${user_js}.tmp.XXXXXX")"
        sed \
            -e '/zen\.theme\.accent-color/d' \
            -e '/devtools\.chrome\.enabled/d' \
            -e '/toolkit\.legacyUserProfileCustomizations\.stylesheets/d' \
            "$user_js" >"$tmp"
        [ -s "$tmp" ] && [ -n "$(tail -c1 "$tmp")" ] && echo >>"$tmp"
        printf 'user_pref("zen.theme.accent-color", "%s");\n' "$accent" >>"$tmp"
        replace_if_changed "$user_js" "$tmp"
    done
