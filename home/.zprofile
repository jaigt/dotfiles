
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# Hermes Agent — ensure ~/.local/bin is on PATH
export PATH="$HOME/.local/bin:$PATH"

# Here, not .zshrc, so non-interactive children inherit it. After brew shellenv:
# nvim lives in the Homebrew prefix.
export EDITOR="nvim"
export VISUAL="nvim"
