# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

zstyle ':omz:update' mode auto      # update automatically without asking
ENABLE_CORRECTION="true"

HIST_STAMPS="mm/dd/yyyy"

plugins=(git
	zsh-syntax-highlighting
	zsh-autosuggestions
	npm
	docker
	chucknorris
)


source $ZSH/oh-my-zsh.sh



export LANG=en_US.UTF-8

 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='nvim'
 else
   export EDITOR='vim'
 fi

alias e="exit"
alias ldocker="lazydocker"
alias lgit="lazygit"
alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias ls="eza --color=always --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias c-tab="zellij action close-tab"
alias c-pane="zellij action close-pane"
alias lvim="/Users/azamatisbaev/.local/bin/lvim"
alias lstree="ls --tree --level=2"
alias c="clear"
alias cd="z"
alias cat="bat"
alias less="bat"
alias fzf="fzf --preview "bat --color=always --style=numbers --line-range=:500 {}""
alias n="nvim"
alias h="hyfetch"
alias python="python3"
# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
# eval "$(oh-my-posh init zsh)"
eval $(thefuck --alias)
eval $(thefuck --alias fk)
eval "$(zoxide init zsh)"
eval "$(fzf --zsh)"

. "$HOME/.cargo/env"

# bun completions
[ -s "/Users/universe/.bun/_bun" ] && source "/Users/universe/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# vm_envs start
if [ -z "$VM_DISABLE" ]; then
    . ~/.vmr/vmr.sh
fi
# vm_envs end

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
