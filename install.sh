#!/usr/bin/env bash
#
# Symlink everything under home/ into $HOME, mirroring the directory structure.
# home-macos/ and home-linux/ hold OS-specific configs; the tree matching
# `uname` is linked alongside home/.
#
# Linking happens per *file*, not per directory. That matters because ~/.claude
# and ~/.config are shared with a lot of machine-local state (caches, session
# logs, credentials) that must not end up in this repo — symlinking the whole
# directory would drag it all in.
#
#   ./install.sh            apply
#   ./install.sh --dry      show what would happen, change nothing
#   ./install.sh --check    verify every link is still intact; exit 1 if not
#
#   ./install.sh --adopt [--os] [--force] <path>...
#                           take a live config file under ~ into the repo: move
#                           it to the mirrored path, git add it, and symlink it
#                           back — in one run. A directory adopts every file
#                           inside it, one link each. --os targets the OS tree
#                           instead of home/. --force skips the credential scan.
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO/home"
case "$(uname -s)" in
  Darwin) OS_TREE="home-macos" ;;
  Linux)  OS_TREE="home-linux" ;;
  *)      OS_TREE="" ;;
esac
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

MODE=apply
ADOPT_TREE=home
DRY=0
FORCE=0
declare -a ADOPT_PATHS=()
while (( $# )); do
  case "$1" in
    --dry|--dry-run) DRY=1 ;;
    --check)         MODE=check ;;
    --adopt)         MODE=adopt ;;
    --os)            ADOPT_TREE="$OS_TREE" ;;
    --force)         FORCE=1 ;;
    -h|--help)       sed -n '3,21p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    --)              shift; ADOPT_PATHS+=("$@"); break ;;
    -*)              echo "unknown option: $1 (try --help)" >&2; exit 2 ;;
    *)               ADOPT_PATHS+=("$1") ;;
  esac
  shift
done

# --dry is a modifier, not a mode, so that it composes with --adopt. The plain
# install path still reads MODE=dry, which is what link() has always keyed on.
if (( DRY )) && [[ $MODE == apply ]]; then MODE=dry; fi

if [[ $MODE != adopt ]] && (( ${#ADOPT_PATHS[@]} > 0 )); then
  echo "paths are only meaningful with --adopt (try --help)" >&2; exit 2
fi

bold=$(tput bold 2>/dev/null || true)
dim=$(tput dim 2>/dev/null || true)
green=$(tput setaf 2 2>/dev/null || true)
yellow=$(tput setaf 3 2>/dev/null || true)
red=$(tput setaf 1 2>/dev/null || true)
reset=$(tput sgr0 2>/dev/null || true)

linked=0 skipped=0 backed_up=0
ok=0 detached=0 missing=0 wrong=0
adopted=0 adopt_skipped=0
declare -a recover=()
declare -a orphans=()
declare -a adopt_add=()

say() { printf '%s\n' "$*"; }

link() {
  local src="$1" rel="$2" dest="$HOME/$2"

  # Already pointing where we want it.
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    say "  ${dim}ok${reset}      $rel"
    skipped=$((skipped + 1))
    return
  fi

  # Something real is in the way — move it aside rather than clobber it.
  if [[ -e "$dest" || -L "$dest" ]]; then
    say "  ${yellow}backup${reset}  $rel ${dim}-> ${BACKUP#$HOME/}/$rel${reset}"
    if [[ $MODE == apply ]]; then
      mkdir -p "$(dirname "$BACKUP/$rel")"
      mv "$dest" "$BACKUP/$rel"
    fi
    backed_up=$((backed_up + 1))
  fi

  say "  ${green}link${reset}    $rel"
  if [[ $MODE == apply ]]; then
    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
  fi
  linked=$((linked + 1))
}

# Report only what's broken. A file can detach silently: apps that save settings
# atomically (write temp, rename over target) replace the symlink with a regular
# file. `git status` stays clean when that happens — the repo's copy genuinely
# wasn't touched — so this is the only way to notice.
check() {
  local src="$1" rel="$2" dest="$HOME/$2"

  if [[ -L "$dest" ]]; then
    if [[ "$(readlink "$dest")" == "$src" ]]; then
      ok=$((ok + 1))
    else
      say "  ${red}wrong${reset}     $rel ${dim}-> $(readlink "$dest")${reset}"
      wrong=$((wrong + 1))
    fi
    return
  fi

  if [[ ! -e "$dest" ]]; then
    say "  ${yellow}missing${reset}   $rel ${dim}(nothing at ~/$rel)${reset}"
    missing=$((missing + 1))
    return
  fi

  # A real file sits where the symlink should be. Whether its content has
  # drifted decides the fix: copy it back first, or just re-link.
  if cmp -s "$dest" "$src"; then
    say "  ${yellow}detached${reset}  $rel ${dim}(same content — safe to re-link)${reset}"
  else
    say "  ${red}detached${reset}  $rel ${bold}(content differs — the live copy has edits)${reset}"
    recover+=("cp ~/$rel $src")
  fi
  detached=$((detached + 1))
}

# Links can also break from the other direction: rename or delete a file in the
# repo and the link in $HOME is left pointing at nothing. Neither loop above can
# see that — both are driven by what's *in* the repo, so a link with no
# counterpart there is invisible to them. That's how ~/.config/fastfetch/
# wings.txt outlived its rename to luffy.txt. Walk the destinations instead and
# flag any link that aims into this repo and resolves to nothing.
find_orphans() {
  local base dir rel dest entry target
  for base in "$SRC" ${OS_TREE:+"$REPO/$OS_TREE"}; do
    [[ -d "$base" ]] || continue
    while IFS= read -r -d '' dir; do
      rel="${dir#$base}"; rel="${rel#/}"
      dest="$HOME${rel:+/$rel}"
      if [[ ! -d "$dest" ]]; then continue; fi
      while IFS= read -r -d '' entry; do
        target="$(readlink "$entry")"
        if [[ "$target" != "$REPO/home"* ]]; then continue; fi  # not ours; prefix glob covers home/, home-macos/, home-linux/
        if [[ -e "$entry" ]]; then continue; fi                 # still resolves
        orphans+=("${entry#$HOME/}")
      done < <(find "$dest" -maxdepth 1 -type l -print0 2>/dev/null)
    done < <(find "$base" -type d -print0)
  done
}

# Take a live file into the repo: move it to the mirrored path, then link it
# straight back. The order matters and so does the *move*. Copying instead
# leaves two independent files — the repo's and the live one — and nothing
# notices when they drift, because git status is clean either way; --check only
# catches it later, once you've forgotten which side is authoritative. After a
# move there is no second copy to drift from.
cred_hit() {
  grep -nEIi -m1 \
    -e 'sk-[A-Za-z0-9_-]{20,}' \
    -e 'gh[pousr]_[A-Za-z0-9]{20,}' \
    -e 'github_pat_[A-Za-z0-9_]{20,}' \
    -e 'AKIA[0-9A-Z]{16}' \
    -e 'xox[baprs]-[A-Za-z0-9-]{10,}' \
    -e '-----BEGIN [A-Z ]*PRIVATE KEY-----' \
    -e '(api[_-]?key|secret|password|token)["'\'']?[[:space:]]*[:=][[:space:]]*["'\'']?[A-Za-z0-9/+_-]{16,}' \
    "$1" 2>/dev/null
}

refuse() { say "  ${red}skip${reset}      $1 ${dim}($2)${reset}"; adopt_skipped=$((adopt_skipped + 1)); }

# $2 is "dir" when we're walking a directory rather than acting on a path the
# user named. Inside a directory, a gitignored file is expected — settings sit
# next to logs and caches all the time — so it's a quiet pass, not a complaint.
adopt_one() {
  local abs="$1" from="${2:-arg}" rel reldest dest rule hit

  case "$abs" in
    "$HOME"/*) rel="${abs#$HOME/}" ;;
    *) refuse "$abs" "not under \$HOME"; return ;;
  esac
  reldest="$ADOPT_TREE/$rel"
  dest="$REPO/$reldest"

  if [[ -L "$abs" ]]; then
    if [[ "$(readlink "$abs")" == "$REPO/home"* ]]; then
      say "  ${dim}ok${reset}        $rel ${dim}(already adopted)${reset}"
    else
      refuse "$rel" "symlink to $(readlink "$abs")"
    fi
    return
  fi
  [[ -f "$abs" ]] || { refuse "$rel" "not a regular file"; return; }
  [[ -e "$dest" ]] && { refuse "$rel" "already in the repo at $reldest"; return; }

  # Untracked files are never linked, so adopting into an ignored path would
  # silently produce nothing. Say so instead.
  if rule=$(git -C "$REPO" check-ignore -v -- "$reldest" 2>/dev/null); then
    if [[ $from == dir ]]; then
      say "  ${dim}ignored   $rel${reset}"
    else
      refuse "$rel" "${rule%%$'\t'*} excludes it — it would never get linked"
    fi
    return
  fi

  if (( ! FORCE )) && hit=$(cred_hit "$abs"); then
    say "  ${red}refuse${reset}    $rel ${bold}(looks like it holds a credential)${reset}"
    say "            ${dim}${hit}${reset}"
    say "            ${dim}Real? Add the path to .gitignore rather than tracking it.${reset}"
    say "            ${dim}False positive? Re-run with --force.${reset}"
    adopt_skipped=$((adopt_skipped + 1))
    return
  fi

  say "  ${green}adopt${reset}     $rel ${dim}-> $reldest${reset}"
  adopted=$((adopted + 1))
  (( DRY )) && return

  mkdir -p "$(dirname "$dest")"
  mv "$abs" "$dest"
  if ! ln -s "$dest" "$abs"; then
    mv "$dest" "$abs"
    say "  ${red}failed${reset}    $rel ${bold}(could not link — the file has been moved back)${reset}"
    adopted=$((adopted - 1)); adopt_skipped=$((adopt_skipped + 1))
    return
  fi
  adopt_add+=("$reldest")
}

adopt_path() {
  local p="$1" abs f
  if [[ ! -e "$p" && ! -L "$p" ]]; then refuse "$p" "no such path"; return; fi
  abs="$(cd "$(dirname "$p")" && pwd)/$(basename "$p")"

  if [[ -d "$abs" && ! -L "$abs" ]]; then
    while IFS= read -r -d '' f; do adopt_one "$f" dir; done \
      < <(find "$abs" -type f -print0 | sort -z)
  else
    adopt_one "$abs"
  fi
}

if [[ $MODE == adopt ]]; then
  (( ${#ADOPT_PATHS[@]} > 0 )) || {
    say "${red}--adopt needs a path${reset}  ${dim}e.g. ./install.sh --adopt ~/.config/newthing/config.toml${reset}" >&2
    exit 2; }
  [[ -n "$ADOPT_TREE" ]] || { say "${red}--os: no OS tree for $(uname -s)${reset}" >&2; exit 2; }

  say "${bold}dotfiles${reset} ${dim}$REPO${reset}"
  say "${dim}adopting into $ADOPT_TREE/${reset}"
  (( DRY )) && say "${yellow}dry run — nothing will change${reset}"
  say ""

  for p in "${ADOPT_PATHS[@]}"; do adopt_path "$p"; done

  (( ${#adopt_add[@]} > 0 )) && git -C "$REPO" add -- "${adopt_add[@]}"

  say ""
  say "${bold}$adopted adopted${reset}, $adopt_skipped skipped"
  (( adopted > 0 && ! DRY )) && say "${dim}staged in git — commit when you're happy with it.${reset}"
  (( adopt_skipped > 0 )) && exit 1
  exit 0
fi

say "${bold}dotfiles${reset} ${dim}$REPO${reset}"
case $MODE in
  dry)   say "${yellow}dry run — nothing will change${reset}" ;;
  check) say "${dim}checking links — reporting problems only${reset}" ;;
esac
say ""

# What gets linked is decided by git, not by walking the filesystem. `ls-files`
# reports exactly the tracked set, so anything .gitignore already rejects —
# __pycache__/*.pyc left behind by the generator scripts, machine-local state,
# .DS_Store — never gets dragged into $HOME. Walking home/ instead would link
# it all, and then --check would spend the rest of its life reporting the junk
# as "missing".
declare -a files=() rels=()
for tree in home ${OS_TREE:+"$OS_TREE"}; do
  while IFS= read -r -d '' rel; do
    files+=("$REPO/$rel"); rels+=("${rel#$tree/}")
  done < <(git -C "$REPO" ls-files -z -- "$tree/" | sort -z)
done

if (( ${#files[@]} == 0 )); then
  say "${red}no tracked files under home/ or the OS tree${reset} — is $REPO a git checkout?" >&2
  exit 2
fi

# The one deliberate exception. .zsh_secrets holds API keys, so it is
# gitignored, but the shell still needs it linked — see the note at the end of
# a run.
if [[ -e "$SRC/.zsh_secrets" ]]; then files+=("$SRC/.zsh_secrets"); rels+=(".zsh_secrets"); fi

for i in "${!files[@]}"; do
  case $MODE in
    check) check "${files[$i]}" "${rels[$i]}" ;;
    *)     link  "${files[$i]}" "${rels[$i]}" ;;
  esac
done

find_orphans
for rel in "${orphans[@]:-}"; do
  if [[ -n "$rel" ]]; then say "  ${red}orphan${reset}    $rel ${dim}(points into the repo at a file that no longer exists)${reset}"; fi
done

if [[ $MODE == check ]]; then
  problems=$((detached + missing + wrong + ${#orphans[@]}))
  if (( problems == 0 )); then
    say "${green}all $ok links intact${reset}"
    exit 0
  fi
  say ""
  say "${bold}$ok intact${reset}, $detached detached, $missing missing, $wrong wrong, ${#orphans[@]} orphaned"
  if (( ${#orphans[@]} > 0 )); then
    say ""
    say "${bold}Orphans are safe to delete${reset} — they already point at nothing:"
    for rel in "${orphans[@]}"; do say "  rm ~/$rel"; done
  fi
  if (( ${#recover[@]} > 0 )); then
    say ""
    say "${bold}Salvage the live edits first${reset} — re-linking would discard them:"
    for cmd in "${recover[@]}"; do say "  $cmd"; done
  fi
  say ""
  say "Then: ${bold}./install.sh${reset}   ${dim}(re-links; anything in the way is backed up)${reset}"
  exit 1
fi

say ""
say "${bold}$linked linked${reset}, $skipped already correct, $backed_up backed up"
if (( backed_up > 0 )) && [[ $MODE == apply ]]; then say "${dim}originals: $BACKUP${reset}"; fi
if (( ${#orphans[@]} > 0 )); then
  say ""
  say "${bold}${#orphans[@]} orphaned link(s)${reset} — left over from a rename. Safe to delete:"
  for rel in "${orphans[@]}"; do say "  rm ~/$rel"; done
fi
say ""
say "Not managed here: ~/.ssh, ~/.codex/auth.json, ~/.config/gh/hosts.yml,"
say "~/.config/raycast/config.json, ~/.claude/settings.local.json"
say ""
say "${dim}home/.zsh_secrets is linked like everything else but never tracked."
say "A fresh clone won't have it — write it by hand, then re-run.${reset}"
