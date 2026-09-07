#!/bin/bash
# Re-apply the custom WezTerm app icon. Driven by the LaunchAgent in
# ~/Library/LaunchAgents that watches WezTerm's Info.plist, since a cask upgrade
# replaces the bundle and takes the icon with it.
#
# Needs the App Management permission (System Settings > Privacy & Security),
# or it fails with "Operation not permitted" however it is invoked.
#
# --force re-applies when an icon is ALREADY set. Without it the fast path below
# makes a changed app-icon.png do nothing at all, which is the one case it gets
# wrong. Safe to run by hand either way.

set -uo pipefail

FORCE=0
[[ "${1:-}" == "--force" ]] && FORCE=1

APP="/Applications/WezTerm.app"
ICON="$HOME/.config/wezterm/app-icon.png"
FILEICON="/opt/homebrew/bin/fileicon"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
LOG="$HOME/.config/wezterm/icon.log"
ICON_MARKER="$APP/$(printf 'Icon\r')"

log() { printf '%s  %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$LOG"; }

# Exit before sleeping: WatchPaths fires more than once per upgrade.
[[ $FORCE -eq 0 && -e "$ICON_MARKER" ]] && exit 0

[[ -x "$FILEICON" ]] || { log "ERROR: fileicon not found at $FILEICON (brew install fileicon)"; exit 1; }
[[ -f "$ICON" ]]     || { log "ERROR: icon source missing: $ICON"; exit 1; }

# A cask upgrade unpacks over several seconds; don't write into a half-replaced
# .app.
for _ in $(seq 1 30); do
  [[ -x "$APP/Contents/MacOS/wezterm-gui" ]] && break
  sleep 1
done
[[ -x "$APP/Contents/MacOS/wezterm-gui" ]] || { log "ERROR: $APP never became ready"; exit 1; }
sleep 3

# A concurrent trigger may have won the race while we slept.
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
