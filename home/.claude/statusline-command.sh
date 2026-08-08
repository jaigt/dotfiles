#!/bin/bash
# Two-line Claude Code status line:
#   Fable 5 │ Effort: High │ .claude │ main* │ +12/-4
#   Context ████░░░░░░ 50% (501.5k / 1M) │ 5h ██░░░░░░░░ 15% (3h 54m)
# Segments drop out cleanly when their data is absent (older CLI versions).

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // empty')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // empty')

ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
ctx_used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty | if . == "" then . else round end')
ctx_used_tokens=$(echo "$input" | jq -r '.context_window.current_usage // empty |
  if . == "" then empty else
    ((.input_tokens // 0) + (.output_tokens // 0) +
     (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0))
  end')

limit_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty | if . == "" then . else round end')
resets_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')

# Abbreviate directory: ~ for home, basename otherwise
if [ -z "$cwd" ]; then
  dir=""
elif [ "$cwd" = "$HOME" ]; then
  dir="~"
else
  dir=$(basename "$cwd")
fi

# Git branch, only when cwd is inside a git repo. Skip optional locks so this
# never blocks on/mutates the repo (e.g. during concurrent git operations).
branch=""
if [ -n "$cwd" ] && git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
  if [ -z "$branch" ]; then
    branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  fi
  # Mark uncommitted changes (staged, unstaged, or untracked) with *
  if [ -n "$branch" ] && [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null | head -1)" ]; then
    branch="${branch}*"
  fi
fi

RESET=$'\033[0m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
DIM_GREEN=$'\033[2;32m'
DIM_RED=$'\033[2;31m'
PURPLE=$'\033[38;5;141m'
ORANGE=$'\033[38;5;215m'

SEP="${DIM} │ ${RESET}"

# make_bar <used-percent> <width> <color> → colored fill, dim remainder
make_bar() {
  local pct=$1 width=$2 color=$3 filled bar i
  filled=$(( (pct * width + 50) / 100 ))
  [ "$filled" -gt "$width" ] && filled=$width
  [ "$filled" -lt 0 ] && filled=0
  bar="$color"
  i=0; while [ "$i" -lt "$filled" ]; do bar="${bar}█"; i=$((i+1)); done
  bar="${bar}${RESET}${DIM}"
  while [ "$i" -lt "$width" ]; do bar="${bar}░"; i=$((i+1)); done
  printf "%s" "${bar}${RESET}"
}

# fmt_tokens <n> → 800 / 501.5k / 1M / 1.5M
fmt_tokens() {
  awk -v n="$1" 'BEGIN {
    if (n >= 1000000) { v = n / 1000000; printf (v == int(v)) ? "%.0fM" : "%.1fM", v }
    else if (n >= 1000) { v = n / 1000; printf (v == int(v)) ? "%.0fk" : "%.1fk", v }
    else printf "%d", n
  }'
}

# fmt_until <epoch> → time until then: 3h 54m / 2d 5h / 40m
fmt_until() {
  local now diff
  now=$(date +%s)
  diff=$(( $1 - now ))
  [ "$diff" -le 0 ] && return
  if [ "$diff" -ge 86400 ]; then
    printf "%dd %dh" $((diff / 86400)) $((diff % 86400 / 3600))
  elif [ "$diff" -ge 3600 ]; then
    printf "%dh %dm" $((diff / 3600)) $((diff % 3600 / 60))
  else
    printf "%dm" $((diff / 60))
  fi
}

case "$effort" in
  low) effort_label="Low" ;;
  medium) effort_label="Medium" ;;
  high) effort_label="High" ;;
  xhigh) effort_label="Extra-High" ;;
  max) effort_label="Max" ;;
  *) effort_label="$effort" ;;
esac

# ── Line 1: model │ effort │ thinking │ dir │ branch ──
line1=""
[ -n "$model" ] && line1="${BOLD}${model}${RESET}"
if [ -n "$effort_label" ]; then
  [ -n "$line1" ] && line1="${line1}${SEP}"
  line1="${line1}${DIM}Effort: ${RESET}${effort_label}"
fi
if [ -n "$dir" ]; then
  [ -n "$line1" ] && line1="${line1}${SEP}"
  line1="${line1}${DIM}${dir}${RESET}"
fi
if [ -n "$branch" ]; then
  [ -n "$line1" ] && line1="${line1}${SEP}"
  line1="${line1}${DIM_GREEN}${branch}${RESET}"
fi
if [ -n "$lines_added" ] || [ -n "$lines_removed" ]; then
  [ -n "$line1" ] && line1="${line1}${SEP}"
  line1="${line1}${DIM_GREEN}+${lines_added:-0}${RESET}${DIM}/${RESET}${DIM_RED}-${lines_removed:-0}${RESET}"
fi

# ── Line 2: context bar │ 5h bar │ 7d bar ──
line2=""
if [ -n "$ctx_used_pct" ]; then
  line2="${DIM}Context ${RESET}$(make_bar "$ctx_used_pct" 10 "$PURPLE") ${PURPLE}${ctx_used_pct}%${RESET}"
  if [ -n "$ctx_used_tokens" ] && [ -n "$ctx_size" ]; then
    line2="${line2}${DIM} ($(fmt_tokens "$ctx_used_tokens") / $(fmt_tokens "$ctx_size"))${RESET}"
  fi
fi
if [ -n "$limit_5h" ]; then
  [ -n "$line2" ] && line2="${line2}${SEP}"
  line2="${line2}${DIM}5h ${RESET}$(make_bar "$limit_5h" 10 "$ORANGE") ${ORANGE}${limit_5h}%${RESET}"
  if [ -n "$resets_5h" ]; then
    until_5h=$(fmt_until "$resets_5h")
    [ -n "$until_5h" ] && line2="${line2}${DIM} (${until_5h})${RESET}"
  fi
fi
if [ -n "$line2" ]; then
  printf "%s\n%s" "$line1" "$line2"
else
  printf "%s" "$line1"
fi
