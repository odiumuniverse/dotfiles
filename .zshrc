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
	herdr
)


source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8
# Machine-local env (GOPRIVATE, Boundary IDs) lives in ~/.config/zsh/local.zsh (untracked).
[ -s ~/.config/zsh/local.zsh ] && source ~/.config/zsh/local.zsh
export GOPROXY=direct
export GOSUMDB=off
export PATH=/Users/universe/.nvm/versions/node/v20.19.0/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/TeX/texbin:/Users/universe/.local/bin/:/Users/universe/go/bin/:/Users/universe/.cargo/bin:/Users/universe/.spicetify:/Applications/Obsidian.app/Contents/MacOS
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
alias cur="cursor-agent"
alias cs="cswap --switch"
alias spt="spotatui"
# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
# eval "$(oh-my-posh init zsh)"
eval $(thefuck --alias)
eval $(thefuck --alias fk)
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

# zoxide must init last (see zoxide doctor)
eval "$(zoxide init zsh)"

# boundary: no args -> connect target, auth-on-fail fallback. Args -> passthrough real binary.
# Uses BOUNDARY_* values from ~/.config/zsh/local.zsh (sourced above, untracked).
boundary() {
  local addr=${BOUNDARY_ADDR:?set BOUNDARY_ADDR in ~/.config/zsh/boundary.zsh}
  local target=${BOUNDARY_TARGET_ID:?set BOUNDARY_TARGET_ID in ~/.config/zsh/boundary.zsh}
  local authmethod=${BOUNDARY_AUTH_METHOD_ID:?set BOUNDARY_AUTH_METHOD_ID in ~/.config/zsh/boundary.zsh}
  if [[ $# -eq 0 ]]; then
    command boundary connect -addr "$addr" -target-id "$target" || {
      command boundary authenticate oidc -addr "$addr" -auth-method-id "$authmethod" &&
      command boundary connect -addr "$addr" -target-id "$target"
    }
  else
    command boundary "$@"
  fi
}


# Added by Antigravity CLI installer
export PATH="/Users/universe/.local/bin:$PATH"

# herdr-automatic-rename: мгновенное переименование табов при старте команды
for _f in ${HOME}/.config/herdr/plugins/github/herdr-automatic-rename-*/shell/hook.zsh(N); do
  source $_f; break
done

# bun completions
[ -s "/Users/universe/.bun/_bun" ] && source "/Users/universe/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
