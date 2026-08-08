#!/bin/bash
# Re-apply the custom WezTerm app icon.
#
# Driven by ~/Library/LaunchAgents/com.jaigupta.wezterm-icon.plist, which watches
# WezTerm's Info.plist — `brew upgrade --cask wezterm` replaces the whole bundle
# and takes the custom icon with it, which fires this script.
#
# NOTE: writing into /Applications/WezTerm.app requires the App Management
# permission (System Settings > Privacy & Security > App Management). Without it
# this fails with "Operation not permitted" no matter how it's invoked.
#
# Safe to run by hand at any time:  ~/.config/wezterm/bin/apply-icon.sh
#
# Pass --force to re-apply when an icon is ALREADY set. The fast path below
# exists because WatchPaths can fire several times per upgrade and re-applying
# an unchanged icon costs a Dock restart -- but it also means that swapping
# app-icon.png for a different design and re-running does nothing at all, which
# is confusing enough to have caught us once. Changing the icon is exactly the
# case the fast path gets wrong, so:
#
#   ~/.config/wezterm/bin/apply-icon.sh --force

set -uo pipefail

FORCE=0
[[ "${1:-}" == "--force" ]] && FORCE=1

APP="/Applications/WezTerm.app"
# app-icon-source.png next to it is the pre-export master for this file.
ICON="$HOME/.config/wezterm/app-icon.png"
FILEICON="/opt/homebrew/bin/fileicon"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
LOG="$HOME/.config/wezterm/icon.log"
ICON_MARKER="$APP/$(printf 'Icon\r')"

log() { printf '%s  %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$LOG"; }

# Fast path: icon already in place, so this was a no-op trigger. Exit before
# any sleeping — WatchPaths can fire more than once per upgrade. --force skips
# it, which is what you want when the icon ARTWORK changed rather than the app.
[[ $FORCE -eq 0 && -e "$ICON_MARKER" ]] && exit 0

[[ -x "$FILEICON" ]] || { log "ERROR: fileicon not found at $FILEICON (brew install fileicon)"; exit 1; }
[[ -f "$ICON" ]]     || { log "ERROR: icon source missing: $ICON"; exit 1; }

# A cask upgrade unpacks the bundle over several seconds; wait for it to settle
# so we don't write the icon into a half-replaced .app.
for _ in $(seq 1 30); do
  [[ -x "$APP/Contents/MacOS/wezterm-gui" ]] && break
  sleep 1
done
[[ -x "$APP/Contents/MacOS/wezterm-gui" ]] || { log "ERROR: $APP never became ready"; exit 1; }
sleep 3

# Re-check: a concurrent trigger may have won the race while we slept.
[[ $FORCE -eq 0 && -e "$ICON_MARKER" ]] && exit 0

if "$FILEICON" set "$APP" "$ICON" >>"$LOG" 2>&1; then
  log "applied $ICON to $APP"
  # Writing the icon changes the bundle's mod date, which invalidates the
  # reference the Dock caches for its pinned tile — the Dock then can't match a
  # running WezTerm to that tile and draws a duplicate. Re-registering with
  # LaunchServices refreshes that record before the Dock restarts.
  "$LSREGISTER" -f "$APP" >>"$LOG" 2>&1 || log "WARN: lsregister failed"
  killall Dock 2>/dev/null || true
else
  log "ERROR: fileicon set failed"
  exit 1
fi
