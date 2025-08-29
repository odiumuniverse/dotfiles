export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

zstyle ':omz:update' mode auto      # update automatically without asking

HIST_STAMPS="mm/dd/yyyy"

plugins=(
	git
	zsh-syntax-highlighting
	zsh-autosuggestions
	zsh-completions
    docker
	golang
	chucknorris
)


source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8
export GOPRIVATE=git.topscan.me
export GOPROXY=direct
export GOSUMDB=off
export PATH=/Users/universe/.nvm/versions/node/v20.19.0/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/TeX/texbin:/Users/universe/.local/bin/:/Users/universe/go/bin/:/Users/universe/.cargo/bin:/Users/universe/.spicetify
export GOPATH=/Users/universe/go/

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
alias sptd="spotify_player -d"
alias spt="spotify_player"
alias cur="cursor-agent"
# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
# eval "$(oh-my-posh init zsh)"
eval $(thefuck --alias)
eval $(thefuck --alias fk)
eval "$(zoxide init zsh)"
eval "$(fzf --zsh)"


export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/Users/universe/.opam/opam-init/init.zsh' ]] || source '/Users/universe/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration
