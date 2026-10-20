export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

zstyle ':omz:update' mode auto      # update automatically without asking

HIST_STAMPS="mm/dd/yyyy"
SAVEHIST=50000

# zsh-completions is not an omz plugin: its src must be in fpath before compinit
fpath+=$ZSH/custom/plugins/zsh-completions/src

# zsh-syntax-highlighting must be the last plugin
plugins=(
	git
	zsh-autosuggestions
	docker
	golang
	herdr
	zsh-syntax-highlighting
)


source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8
# Machine-local env (GOPRIVATE, Boundary IDs) lives in ~/.config/zsh/local.zsh (untracked).
[ -s ~/.config/zsh/local.zsh ] && source ~/.config/zsh/local.zsh
export GOPROXY=direct
export GOSUMDB=off
export PATH=/Users/universe/.nvm/versions/node/v20.19.0/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/TeX/texbin:/Users/universe/.local/bin/:/Users/universe/go/bin/:/Users/universe/.cargo/bin:/Users/universe/.spicetify:/Applications/Obsidian.app/Contents/MacOS
export GOPATH=/Users/universe/go/

export EDITOR=nvim
export VISUAL=nvim

alias e="exit"
alias ldock="lazydocker"
alias lg="lazygit"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias ls="eza --color=always --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias lstree="ls --tree --level=2"
alias c="clear"
alias cd="z"
alias cat="bat"
alias fzf="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
alias n="nvim"
alias vim="nvim"
alias vi="nvim"
alias h="hyfetch"
alias python="python3"
alias cur="cursor-agent"
alias cs="cswap --switch"
# cswap run: transcripts and memory (projects/, history.jsonl) shared with ~/.claude across accounts
cswap() {
  if [[ $1 == run ]]; then
    shift
    command cswap run --share-history "$@"
  else
    command cswap "$@"
  fi
}
alias spt="spotatui"
# omp: vanilla isolated profile; ompn/ompf: main dir + overlay (roles reset each launch)
alias omp="command omp --profile vanilla"
alias ompn="command omp --config ~/.omp/agent/paid.yml"
alias ompf="command omp --config ~/.omp/agent/free.yml"
alias ompc="command omp --config ~/.omp/agent/paid.yml --config ~/.omp/agent/claude.yml"
alias ompd="command omp --config ~/.omp/agent/go.yml"
# eval "$(oh-my-posh init zsh)"
eval "$(thefuck --alias fk)"
alias fuck=fk
eval "$(fzf --zsh)"

# Up/Ctrl-R stay with zsh and fzf; atuin only feeds autosuggestions.
# Suggest exit 0, 130 (Ctrl-C) and -1 (imported from zsh, status unknown).
eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r --disable-ai)"
_zsh_autosuggest_strategy_atuin() {
  suggestion=$(ATUIN_QUERY="$1" atuin search --cmd-only --author '$all-user' --limit 1 --search-mode prefix \
    --exit 0 --exit 130 --exit=-1 2>/dev/null)
}
ZSH_AUTOSUGGEST_STRATEGY=(atuin)

# macOS-style line editing; Cmd keys are mapped to Home/End/^U in wezterm.lua
bindkey '^[[1;3D' backward-word      # Option+Left
bindkey '^[[1;3C' forward-word       # Option+Right
bindkey '^U' backward-kill-line      # Cmd+Backspace
bindkey '^Z' undo                    # Ctrl+Z


export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# zoxide must init last (see zoxide doctor)
eval "$(zoxide init zsh)"

# boundary: no args -> connect target, auth-on-fail fallback. Args -> passthrough real binary.
# Uses BOUNDARY_* values from ~/.config/zsh/local.zsh (sourced above, untracked).
boundary() {
  local addr=${BOUNDARY_ADDR:?set BOUNDARY_ADDR in ~/.config/zsh/local.zsh}
  local target=${BOUNDARY_TARGET_ID:?set BOUNDARY_TARGET_ID in ~/.config/zsh/local.zsh}
  local authmethod=${BOUNDARY_AUTH_METHOD_ID:?set BOUNDARY_AUTH_METHOD_ID in ~/.config/zsh/local.zsh}
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
