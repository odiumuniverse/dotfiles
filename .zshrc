export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

zstyle ':omz:update' mode auto      # update automatically without asking

HIST_STAMPS="mm/dd/yyyy"

plugins=(
	git
	zsh-syntax-highlighting
	zsh-autosuggestions
	zsh-completions
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
alias ldock="lazydocker"
alias lg="lazygit"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias ls="eza --color=always --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias lstree="ls --tree --level=2"
alias c="clear"
alias cd="z"
alias cat="bat"
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

# vm_envs start
if [ -z "$VM_DISABLE" ]; then
    . ~/.vmr/vmr.sh
fi
# vm_envs end
