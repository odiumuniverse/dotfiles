#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────
# Claude Code dotfiles setup
# ─────────────────────────────────────────────────────────────────

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_DIR="$DOTFILES_DIR/.claude-shared"

# Prepare files for stow: remove originals so stow can create symlinks
prepare_claude_for_stow() {
  echo "Preparing ~/.claude and ~/.claude-account1 for stow..."

  for cfg_dir in "$HOME/.claude" "$HOME/.claude-account1"; do
    [ -d "$cfg_dir" ] || continue
    for f in settings.json settings.local.json keybindings.json CLAUDE.md; do
      local target="$cfg_dir/$f"
      if [ -f "$target" ] && [ ! -L "$target" ]; then
        mv "$target" "${target}.orig"
        echo "  Backed up $target"
      fi
    done
  done
}

# Run stow to create file symlinks (.claude/settings.json, etc.)
run_stow() {
  echo "Running stow..."
  cd "$DOTFILES_DIR"
  stow .
  echo "  stow done"
}

# Create symlinks for shared directories: skills/, hooks/
# and plugins/config.json (rest of plugins/ is runtime data)
link_shared() {
  echo "Linking shared directories..."

  for account_dir in "$HOME/.claude" "$HOME/.claude-account1"; do
    [ -d "$account_dir" ] || continue

    # skills/ and hooks/ — full directory symlinks
    for shared_name in skills hooks; do
      local src="$SHARED_DIR/$shared_name"
      local dest="$account_dir/$shared_name"

      if [ -L "$dest" ]; then
        echo "  $dest already symlinked, skipping"
      elif [ -d "$dest" ]; then
        mv "$dest" "${dest}.orig"
        ln -s "$src" "$dest"
        echo "  $dest → $src"
      else
        ln -s "$src" "$dest"
        echo "  $dest → $src"
      fi
    done

    # plugins/config.json — only this file, not the whole dir
    mkdir -p "$account_dir/plugins"
    local plugins_cfg_src="$SHARED_DIR/plugins/config.json"
    local plugins_cfg_dest="$account_dir/plugins/config.json"

    if [ -L "$plugins_cfg_dest" ]; then
      echo "  $plugins_cfg_dest already symlinked, skipping"
    elif [ -f "$plugins_cfg_dest" ]; then
      mv "$plugins_cfg_dest" "${plugins_cfg_dest}.orig"
      ln -s "$plugins_cfg_src" "$plugins_cfg_dest"
      echo "  $plugins_cfg_dest → $plugins_cfg_src"
    else
      ln -s "$plugins_cfg_src" "$plugins_cfg_dest"
      echo "  $plugins_cfg_dest → $plugins_cfg_src"
    fi
  done
}

# Inject mcpServers into ~/.claude.json from template + secrets
inject_mcp() {
  local secrets_env="$DOTFILES_DIR/.claude.secrets.env"
  local mcp_template="$DOTFILES_DIR/.claude.mcp.json"
  local claude_json="$HOME/.claude.json"

  if [ ! -f "$secrets_env" ]; then
    echo "WARNING: $secrets_env not found — skipping MCP inject"
    echo "  Create it from .claude.mcp.json and fill in real API keys"
    return 0
  fi

  if [ ! -f "$claude_json" ]; then
    echo "WARNING: $claude_json not found — skipping MCP inject"
    return 0
  fi

  echo "Injecting MCP servers into ~/.claude.json..."

  # Load secrets into environment
  set -a
  # shellcheck source=/dev/null
  source "$secrets_env"
  set +a

  python3 - "$claude_json" "$mcp_template" <<'PYEOF'
import json, os, re, sys

claude_json_path = sys.argv[1]
mcp_template_path = sys.argv[2]

with open(mcp_template_path) as f:
    tpl = f.read()

# Substitute ${VAR} with environment variables
def subst(m):
    return os.environ.get(m.group(1), m.group(0))

rendered = re.sub(r'\$\{([^}]+)\}', subst, tpl)
mcp_data = json.loads(rendered)

with open(claude_json_path) as f:
    claude = json.load(f)

claude['mcpServers'] = mcp_data['mcpServers']

with open(claude_json_path, 'w') as f:
    json.dump(claude, f, indent=2)

print(f"  Injected {len(mcp_data['mcpServers'])} MCP servers: {', '.join(mcp_data['mcpServers'].keys())}")
PYEOF
}

setup_claude() {
  prepare_claude_for_stow
  run_stow
  link_shared
  inject_mcp
}

# Allow running only claude setup: ./install.sh --claude-only
if [[ "${1:-}" == "--claude-only" ]]; then
  setup_claude
  exit 0
fi

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

setup_claude
