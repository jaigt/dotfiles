################################################################################
# Platform — this file is shared between macOS (Homebrew) and Arch/CachyOS.
# Everything OS-specific resolves here; the rest of the file uses the results.
#
# macOS note: zsh only reads .zprofile for LOGIN shells. An interactive
# non-login shell never sees it, so BREW_PREFIX comes out empty and every
# plugin sourced from it below silently fails to load. Run shellenv here too,
# if it hasn't already.
################################################################################
if [[ "$OSTYPE" == darwin* ]]; then
  export HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS=1
  (( $+commands[brew] )) || eval "$(/opt/homebrew/bin/brew shellenv zsh)"
  BREW_PREFIX="${HOMEBREW_PREFIX:-$(brew --prefix)}"
  PLUGIN_FZF_TAB="$BREW_PREFIX/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh"
  PLUGIN_FSH="$BREW_PREFIX/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
  PLUGIN_AUTOSUGGEST="$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  EXTRA_SITE_FUNCTIONS="$BREW_PREFIX/share/zsh/site-functions"
else
  PLUGIN_FZF_TAB="/usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh"
  PLUGIN_FSH="/usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
  PLUGIN_AUTOSUGGEST="/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
  EXTRA_SITE_FUNCTIONS=""
fi

# ~/.local/bin (see .zprofile). `typeset -U` makes $path a unique array, so this
# prepend is idempotent: nesting shells can't grow it.
typeset -U path PATH
path=("$HOME/.local/bin" $path)

################################################################################
# Secrets — ~/.zsh_secrets, never tracked by git. See docs/secrets.md.
################################################################################
[[ -f "$HOME/.zsh_secrets" ]] && source "$HOME/.zsh_secrets"

################################################################################
# History
################################################################################
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE      # leading space = don't record (for secrets)
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY

################################################################################
# Completion engine
#
# Must come before fzf-tab, which hooks the menu that compinit sets up.
# Homebrew's completions live outside the default fpath, so add them first.
################################################################################
typeset -U fpath FPATH
[[ -n "$EXTRA_SITE_FUNCTIONS" ]] && fpath=("$EXTRA_SITE_FUNCTIONS" $fpath)

autoload -Uz compinit
# Rebuild the completion cache once a day rather than on every shell start.
#
# The (#q...) glob qualifier needs EXTENDED_GLOB, which is off by default. With
# it off zsh reads the qualifier as a literal filename, so the test is ALWAYS
# true and the slow path runs every time. Setting EXTENDED_GLOB globally would
# change how `#`, `^` and `~` behave for every plugin below, so turn it on only
# inside this anonymous function, where `localoptions` restores it on return.
if [[ ! -f "$HOME/.zcompdump" ]] || () {
     setopt localoptions extendedglob
     [[ -n $HOME/.zcompdump(#qN.mh+24) ]]
   }; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu no                    # fzf-tab replaces the menu
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:descriptions' format '[%d]' # fzf-tab shows these as group headers

################################################################################
# fzf — Ctrl+T (files), Ctrl+R (history), Alt+C (cd)
################################################################################
source <(fzf --zsh)

################################################################################
# fzf-tab — turns Tab into a fuzzy-filterable menu.
# Sourced after compinit and after the zstyles above, before other plugins.
################################################################################
source "$PLUGIN_FZF_TAB"

zstyle ':fzf-tab:*' fzf-flags --height=45% --layout=reverse --border
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group ',' '.'          # cycle between groups
zstyle ':fzf-tab:complete:(cd|z|ls|eza):*' fzf-preview 'ls -1 --color=always "$realpath" 2>/dev/null || ls -1 "$realpath"'

################################################################################
# Tools
################################################################################
eval "$(zoxide init zsh)"

cc() {
  if [[ $# -gt 0 && $1 != -* ]]; then
    z "$1" || return
    shift
  fi
  claude "$@"
}

nv() {
  if [[ $# -gt 0 && $1 != -* ]]; then
    z "$1" || return
    shift
  fi
  nvim "$@"
}

alias vim="nvim"
alias vi="nvim"
alias v="nvim"

# Review changes without "opening an editor": straight into the codediff
# explorer, q exits back to the shell. `gdiff` = working tree, `gdiff main...`
# = branch compare, `gdiff --staged` = what the next commit contains.
gdiff() {
  nvim "+CodeDiff --exit-on-close ${*}"
}

# Noctalia (Linux) merges the wallpaper palette into this machine-local copy;
# absent (macOS, or templates off) starship falls back to ~/.config/starship.toml.
[[ -f "$HOME/.config/starship-noctalia.toml" ]] && export STARSHIP_CONFIG="$HOME/.config/starship-noctalia.toml"
eval "$(starship init zsh)"

alias update="brew update && brew upgrade && brew cleanup"

################################################################################
# Machine-local overrides — ~/.zsh_local if it exists. Anything too specific to
# this setup to belong in a config other people read.
################################################################################
[[ -f "$HOME/.zsh_local" ]] && source "$HOME/.zsh_local"

################################################################################
# Line-editor plugins — these must come last.
#
# fast-syntax-highlighting wraps the ZLE widgets, so anything that also wraps
# them has to be sourced before it. zsh-autosuggestions is the documented
# exception: it goes after, or the highlighter repaints over its ghost text.
################################################################################
source "$PLUGIN_FSH"
source "$PLUGIN_AUTOSUGGEST"

# graphite highlight_high -- the same grey as the wezterm cursor.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#5b5b5b'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
bindkey '^ ' autosuggest-accept
