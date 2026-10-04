#!/bin/bash
# robbyrussell-style statusline for Claude Code.
# Mimics the oh-my-zsh "robbyrussell" theme (ZSH_THEME in ~/.zshrc):
#   ➜ <dir> git:(<branch>) ✗
# then appends the caveman mode badge by delegating to caveman-statusline.sh.
#
# Claude Code feeds this script a JSON blob on stdin; we read .workspace.current_dir.

input=$(cat)

DIR=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty' 2>/dev/null)
[ -z "$DIR" ] && DIR="$PWD"

# %c in zsh = trailing path component, with ~ for $HOME.
if [ "$DIR" = "$HOME" ]; then
  NAME="~"
else
  NAME=$(basename "$DIR")
fi

# ➜ is bold-green on success / red on failure in robbyrussell. A statusline has no
# previous-command exit code, so it is always green here (the one intentional
# divergence from the shell prompt).
printf '\033[1;32m➜\033[0m \033[36m%s\033[0m' "$NAME"

# git:(<branch>) with a yellow ✗ when the tree is dirty — same colors as the theme.
if BRANCH=$(git -C "$DIR" rev-parse --abbrev-ref HEAD 2>/dev/null); then
  printf ' \033[1;34mgit:(\033[31m%s\033[1;34m)\033[0m' "$BRANCH"
  # ponytail: `status --porcelain` counts untracked as dirty (robbyrussell default);
  # swap for `git diff --quiet` if untracked-noise on huge repos ever matters.
  if [ -n "$(git -C "$DIR" status --porcelain 2>/dev/null)" ]; then
    printf ' \033[33m✗\033[0m'
  fi
fi

# Append the caveman badge (reuses the existing hardened script, unmodified).
BADGE=$(bash "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/hooks/caveman-statusline.sh" 2>/dev/null)
[ -n "$BADGE" ] && printf '  %s' "$BADGE"
