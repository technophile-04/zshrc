# Disable terminal beep
unsetopt BEEP

# History configuration
HISTFILE=$HOME/.zsh_history
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# Key bindings for history search
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# ---- Plugins ----

# Autocompletion plugins
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Vi mode plugin
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk

# FZF and related setup
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Zoxide setup for smarter directory navigation
eval "$(zoxide init zsh)"

# ---- Functions ----

# GitHub pull request checkout function using fzf
function ghpr() {
   GH_FORCE_TTY=100% gh pr list | fzf --ansi --preview 'GH_FORCE_TTY=100% gh pr view {1}' --preview-window down --header-lines 3 | awk '{print $1}' | sed 's/#//g' | xargs gh pr checkout
}

# Git branch switching with fzf
function gch() {
  git checkout "$(git branch --all | fzf | tr -d '[:space:]')"
}

# Create and change directory
function take() {
  mkdir -p $1
  cd $1
}

# Helper function for using bat with --help
help() {
    "$@" --help 2>&1 | bathelp
}

# ---- Alias Definitions ----

# Git and utility aliases
alias gst="git status"
alias gp="git pull"
alias gs="gst"
alias vi="nvim"
alias c="clear"
alias ll="eza -l --icons=always"
alias ls=eza
alias rm=trash
alias bats='fd --type f --strip-cwd-prefix | fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'
alias cat=bat
alias bathelp='bat --plain --language=help'

# ---- Environment Setup ----

# Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# PHP paths
export PATH="/opt/homebrew/opt/php@8.0/bin:$PATH"
export PATH="/opt/homebrew/opt/php@8.0/sbin:$PATH"

# Yarn and bun paths
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bun completions
[ -s "~/.bun/_bun" ] && source "~/.bun/_bun"

# Starship prompt initialization
eval "$(starship init zsh)"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
