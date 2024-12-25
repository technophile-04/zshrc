# Disable terminal beep
unsetopt BEEP

# set auto cd
setopt AUTO_CD

# History configuration
HISTFILE=$HOME/.zsh_history
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

autoload -Uz compinit && compinit

# Key bindings for history search
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# ---- Plugins ----

# Autocompletion plugins
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# Vi mode plugin
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk

# ---- FZF -----

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"
source <(fzf --zsh)

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

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

# yazi startup with yy
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# ---- Alias Definitions ----

# Git and utility aliases
alias gst="git status"
alias gp="git pull"
alias gs="gst"
alias vi="nvim"
alias code="cursor"
alias c="clear"
alias ll="eza -l --icons=always"
alias ls=eza
alias rm=trash
alias bats='fd --type f --strip-cwd-prefix | fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'
alias cat=bat
alias bathelp='bat --plain --language=help'
alias rmrf='rm -rf'
alias vzsh="nvim ~/.config/zshrc/.zshrc"
# Source the zshrc file
alias srz="source ~/.zshrc && echo 'Zsh configuration reloaded'"
# open yt music
alias ytm="open -a Arc 'https://music.youtube.com'"

# ---- Environment Setup ----
export PATH="$HOME/.config/zshrc/scripts:$PATH"

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

# bat (better cat) configuration
export BAT_THEME=tokyonight_night

# Set nvim as man pager
export MANPAGER='nvim +Man!'
export MANWIDTH=999

# bun completions
[ -s "~/.bun/_bun" ] && source "~/.bun/_bun"

# Starship prompt initialization
eval "$(starship init zsh)"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

eval $(thefuck --alias)

# fnm
FNM_PATH="/Users/shivbhonde/Library/Application Support/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/Users/shivbhonde/Library/Application Support/fnm:$PATH"
  eval "`fnm env`"
fi

eval "$(fnm env --use-on-cd --shell zsh)"

# Sesh 
function T() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -t -c -z | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
    zle reset-prompt > /dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}
zle     -N             T
bindkey -M emacs '\es' T
bindkey -M vicmd '\es' T
bindkey -M viins '\es' T

# configure asdf
. "$HOME/.asdf/asdf.sh"

# completions for asdf
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit
export PATH="/opt/homebrew/opt/node@22/bin:$PATH"

if command -v ngrok &>/dev/null; then
  eval "$(ngrok completion)"
fi
