#!/usr/bin/env python3
"""Generate "Rosé Pine Glass" — Rosé Pine's foregrounds on a graphite background
ramp, with Transparent Prism's translucency.

SELF-CONTAINED: the only inputs are `theme-base.json`, committed next to this
script, and the palette below. No installed theme extension is read.

`themes/kanagawa-glass.json` is frozen output of this script's previous Kanagawa
palette: flipping back means selecting it in settings.json, and regenerating it
would mean restoring the old PALETTE from git history.

HOW IT WORKS
------------
`theme-base.json` carries Zed's full style key set with every value written as a
palette TOKEN rather than a colour:

    "editor.background":        "$BG"
    "background":               "$BG+d0"        <- +alpha suffix
    "terminal.ansi.green":      "$GREEN"
    "syntax": { "string": { "color": "$GREEN2", ... } }

main() resolves each `$NAME` against the constants below and applies the glass
structure. Retheming the editor is therefore a matter of editing the palette
here — the template never has to change.

TOKEN NAMES ARE ROLE SLOTS, NOT HUES
------------------------------------
The token names came from Kanagawa, where they happened to be hue names. Rosé
Pine has six hues, not nine, and assigns them to roles differently, so under
this palette a token means "whatever the template uses it for", not its name:
`$GREEN2` is the string slot (gold), `$VIOLET` is the keyword slot (pine),
`$BLUE` is the function slot (rose). The comment on each entry names the role.

One place the hue names really were hues is the terminal ANSI block, and there
the role reading gives nonsense (yellow → grey, blue → pink). So ansi() reasserts
Rosé Pine's own terminal mapping over those keys after resolution.

REFRESHING FOR A NEW ZED VERSION
--------------------------------
If Zed adds style keys, this will still build — it just won't set the new ones,
and Zed falls back to its defaults. To pick them up: install any theme extension,
diff its `style` keys against `theme-base.json`, and add the missing ones with
whichever `$TOKEN` fits. Rare, and a two-minute job.

TRANSLUCENCY
------------
Transparent Prism's translucency isn't a single setting — it's a structure:

  1. `background.appearance = "blurred"` turns on macOS vibrancy. This is the
     part that actually makes the window see-through; without it the alphas
     below just composite against an opaque window.
  2. The big reading surfaces — editor, gutter, panels, tab bar, terminal —
     go to #00000000, fully transparent, so the desktop shows through.
  3. The chrome around them — window bg, title bar, status bar, popovers —
     takes a dark tint at alpha d0 (~82%), so text on it stays legible.
  4. Highlights that used to rely on a solid background (active tab, active
     line) become low-alpha washes.

Regenerating overwrites the output. Run `./install.sh` afterwards to symlink it
into ~/.config/zed/themes/ if it isn't linked yet.
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
TEMPLATE = os.path.join(HERE, "theme-base.json")
OUT = os.path.join(HERE, "themes", "rose-pine-glass.json")

THEME_NAME = "Rosé Pine Glass"

# Alpha suffixes, as Transparent Prism uses them.
CHROME = "d0"  # ~82% — tinted but still clearly translucent
WASH = "14"    # ~8%  — active tab
FAINT = "0d"   # ~5%  — active line, the subtler of the two

# ---------------------------------------------------------------- palette
# Rosé Pine main foregrounds, stock.
TEXT   = "#e0def4"
MUTED  = "#6e6a86"
SUBTLE = "#908caa"
LOVE   = "#eb6f92"
GOLD   = "#f6c177"
ROSE   = "#ebbcba"
PINE   = "#31748f"
FOAM   = "#9ccfd8"
IRIS   = "#c4a7e7"

# Backgrounds are "graphite": the Rosé Pine ramp fully desaturated at equal
# lightness. Stock main is a purple-black (#191724 …), which fights the rest of
# the desktop once the window is translucent.
BASE      = "#1e1e1e"
SURFACE   = "#262626"
OVERLAY   = "#2f2f2f"
HL_LOW    = "#272727"
HL_MED    = "#484848"
HL_HIGH   = "#5b5b5b"
NC        = "#1a1a1a"

# Token -> colour. Names are the template's role slots; see the module docstring.
PALETTE = {
    # Backgrounds — graphite ramp
    "BG":      BASE,     # window, editor, status/title bar
    "BG_M1":   NC,       # one step down: subheaders, inert borders, elements
    "BG_P1":   SURFACE,  # one step up: popovers, elevated surfaces, hover
    "BG_P2":   HL_MED,   # borders, scrollbar thumb
    "BG_P3":   HL_HIGH,  # selected elements
    "INK0":    OVERLAY,  # the ANSI black slot
    # Text
    "FG":      TEXT,
    "FG_DIM":  SUBTLE,
    "GRAY":    MUTED,    # comments, line numbers, everything de-emphasised
    # Role slots
    "RED":     LOVE,     # deleted
    "RED_W":   LOVE,     # preproc, vim replace mode
    "ORANGE":  IRIS,     # constants, booleans, enums, variants, conflict
    "ORANGE2": ROSE,     # string.special
    "YELLOW":  SUBTLE,   # operators, string escapes
    "YELLOW2": FOAM,     # properties, titles, modified
    "GREEN":   PINE,     # conflict marker "ours"
    "GREEN2":  GOLD,     # strings, created, vim insert mode
    "AQUA":    FOAM,     # hints
    "AQUA2":   FOAM,     # types, link URIs
    "BLUE":    ROSE,     # functions, constructors, tags, renamed
    "BLUE2":   FOAM,     # accents, attributes, labels, vim normal mode
    "VIOLET":  PINE,     # keywords, vim visual mode
    "VIOLET2": IRIS,
    "PINK":    IRIS,     # numbers
    "PUNCT":   SUBTLE,   # punctuation, brackets, delimiters
    "PARAM":   LOVE,     # variable.special — self / this / builtins
    # Diagnostics
    "D_ERROR": LOVE,
    "D_WARN":  GOLD,
    "D_INFO":  FOAM,
}

# Rosé Pine's own terminal mapping. Only black brightens; the rest of the bright
# slots repeat their base colour, which is what keeps ANSI output on-palette.
ANSI = {
    "black":   OVERLAY,
    "red":     LOVE,
    "green":   PINE,
    "yellow":  GOLD,
    "blue":    FOAM,
    "magenta": IRIS,
    "cyan":    ROSE,
    "white":   TEXT,
}
ANSI_BRIGHT_BLACK = SUBTLE

TOKEN = re.compile(r"^\$([A-Z0-9_]+)(?:\+([0-9a-fA-F]{2}))?$")

_unresolved = set()


def resolve(value):
    """$NAME or $NAME+aa -> #rrggbb / #rrggbbaa. Non-tokens pass through."""
    if not isinstance(value, str) or not value.startswith("$"):
        return value
    if value == "$transparent":
        return "#00000000"
    m = TOKEN.match(value)
    if not m or m.group(1) not in PALETTE:
        _unresolved.add(value)
        return value
    return PALETTE[m.group(1)] + (m.group(2) or "")


def ansi(s):
    """Reassert Rosé Pine's terminal mapping over the template's hue-named slots."""
    for name, color in ANSI.items():
        for prefix in ("", "bright_", "dim_"):
            k = f"terminal.ansi.{prefix}{name}"
            if k in s:
                s[k] = color
    if "terminal.ansi.bright_black" in s:
        s["terminal.ansi.bright_black"] = ANSI_BRIGHT_BLACK
    return s


def glass(s):
    """Apply Transparent Prism's translucency structure."""
    # (1) macOS vibrancy. Without this the rest is just dark-on-dark.
    s["background.appearance"] = "blurred"

    # (2) Reading surfaces go fully transparent.
    for k in (
        "editor.background", "editor.gutter.background", "panel.background",
        "tab_bar.background", "tab.inactive_background", "toolbar.background",
        "terminal.background", "scrollbar.track.background",
        "scrollbar.track.border",
    ):
        if k in s:
            s[k] = "#00000000"

    # (3) Chrome keeps a tint so text on it stays readable, two-tone: bg for the
    # window, one step up for popovers.
    for k in ("background", "status_bar.background", "title_bar.background",
              "title_bar.inactive_background"):
        if k in s:
            s[k] = PALETTE["BG"] + CHROME
    for k in ("surface.background", "elevated_surface.background"):
        if k in s:
            s[k] = PALETTE["BG_P1"] + CHROME

    # (4) Highlights that assumed a solid backdrop.
    if "tab.active_background" in s:
        s["tab.active_background"] = PALETTE["FG"] + WASH
    if "editor.active_line.background" in s:
        s["editor.active_line.background"] = PALETTE["FG"] + FAINT

    # Borders. The source sets nearly every border one step off the base, which
    # is invisible once the surface behind it is transparent. Lift to bg_p2.
    if "border" in s:
        s["border"] = PALETTE["BG_P2"] + "40"
    if "border.variant" in s:
        s["border.variant"] = PALETTE["BG_P2"] + "20"

    return s


def main():
    if not os.path.exists(TEMPLATE):
        sys.exit(f"missing template: {TEMPLATE}\nIt is committed alongside this script.")

    with open(TEMPLATE, encoding="utf-8") as fh:
        base = json.load(fh)

    style = {}
    for k, v in base["style"].items():
        if k == "syntax":
            style[k] = {n: {**spec, "color": resolve(spec.get("color"))}
                        for n, spec in v.items()}
        elif k == "players":
            style[k] = [{kk: resolve(vv) for kk, vv in p.items()} for p in v]
        else:
            style[k] = resolve(v)

    if _unresolved:
        sys.exit("unresolved palette tokens: " + ", ".join(sorted(_unresolved)))

    style = glass(ansi(style))

    out = {
        "$schema": "https://zed.dev/schema/themes/v0.2.0.json",
        "name": THEME_NAME,
        "author": "generated by gen_zed_theme.py",
        "themes": [{
            "name": THEME_NAME,
            "appearance": base.get("appearance", "dark"),
            "style": style,
        }],
    }

    # Guard: every colour must be well-formed, and no token may have leaked.
    # Match tokens in VALUES only -- the top-level "$schema" key legitimately
    # starts with a $ and would otherwise trip this every single run.
    blob = json.dumps(out)
    leaked = re.findall(r':\s*"(\$[A-Za-z0-9_+]+)"', blob)
    if leaked:
        sys.exit("palette tokens survived into the output: " + ", ".join(sorted(set(leaked))))
    bad = [v for v in re.findall(r'"(#[^"]*)"', blob)
           if not re.fullmatch(r"#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?", v)]
    if bad:
        sys.exit("malformed colour values: " + ", ".join(sorted(set(bad))))

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8") as fh:
        json.dump(out, fh, ensure_ascii=False, indent=2)
        fh.write("\n")

    print(f"wrote {OUT}")
    print(f"  {len(style)} style keys, {len(style['syntax'])} syntax entries")


if __name__ == "__main__":
    main()
