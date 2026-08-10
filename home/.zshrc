# zsh reads .zprofile for LOGIN shells only, so an interactive non-login shell
# leaves BREW_PREFIX empty and every plugin below silently fails to load.
# Hence running shellenv here too.
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

# `typeset -U` makes $path unique, so this prepend is idempotent under nesting.
typeset -U path PATH
path=("$HOME/.local/bin" $path)

# ~/.zsh_secrets is never tracked by git. See docs/secrets.md.
[[ -f "$HOME/.zsh_secrets" ]] && source "$HOME/.zsh_secrets"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE      # leading space = don't record (for secrets)
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY

# Must come before fzf-tab, which hooks the menu compinit sets up. Homebrew's
# completions live outside the default fpath, so add them first.
typeset -U fpath FPATH
[[ -n "$EXTRA_SITE_FUNCTIONS" ]] && fpath=("$EXTRA_SITE_FUNCTIONS" $fpath)

autoload -Uz compinit
# Rebuild the completion cache daily, not per shell.
#
# The (#q...) qualifier needs EXTENDED_GLOB; without it zsh reads it as a
# literal filename and the test is ALWAYS true. Enabling it globally would
# change `#`, `^` and `~` for every plugin below, hence the anonymous function
# with `localoptions`.
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

source <(fzf --zsh)

# fzf-tab: after compinit and the zstyles above, before other plugins.
source "$PLUGIN_FZF_TAB"

zstyle ':fzf-tab:*' fzf-flags --height=45% --layout=reverse --border
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group ',' '.'          # cycle between groups
zstyle ':fzf-tab:complete:(cd|z|ls|eza):*' fzf-preview 'ls -1 --color=always "$realpath" 2>/dev/null || ls -1 "$realpath"'

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

# Straight into the codediff explorer; q exits back to the shell.
gdiff() {
  nvim "+CodeDiff --exit-on-close ${*}"
}

# Noctalia (Linux) merges the wallpaper palette into this machine-local copy;
# without it starship falls back to the repo's starship.toml.
[[ -f "$HOME/.config/starship-noctalia.toml" ]] && export STARSHIP_CONFIG="$HOME/.config/starship-noctalia.toml"
eval "$(starship init zsh)"

alias update="brew update && brew upgrade && brew cleanup"

# Machine-local overrides, too specific to belong in a published config.
[[ -f "$HOME/.zsh_local" ]] && source "$HOME/.zsh_local"

# These must come last. fast-syntax-highlighting wraps the ZLE widgets, so
# anything else that wraps them is sourced before it. zsh-autosuggestions is
# the documented exception — after, or the highlighter repaints its ghost text.
source "$PLUGIN_FSH"
source "$PLUGIN_AUTOSUGGEST"

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#5b5b5b'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
bindkey '^ ' autosuggest-accept
