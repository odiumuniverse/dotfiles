#!/bin/bash
# Workaround for https://github.com/asmvik/yabai/issues/2686 (yabai >= 7.1.16 on Sequoia):
# the SA loader is built with PAC ABI v1 (caps 0x81) while Dock.app runs ABI v0, so injection
# fails with "could not spawn remote thread: (os/kern) protection failure". Patch caps back to 0x80.
# Run with sudo after every yabai upgrade: sudo ~/.config/yabai/patch-sa.sh

loader=/Library/ScriptingAdditions/yabai.osax/Contents/MacOS/loader

[ "$(id -u)" -eq 0 ] || { echo "Run with sudo"; exit 1; }
[ -f "$loader" ] || /opt/homebrew/bin/yabai --load-sa 2>/dev/null
[ -f "$loader" ] || { echo "Error: '$loader' not found"; exit 1; }

read -r I O <<<"$(otool -f "$loader" | awk '/architecture/{i=$2} /capabilities 0x81/{f=1} f&&/offset/{print i, $2; exit}')"

if [ -n "$O" ]; then
  printf '\x80' | dd of="$loader" bs=1 seek=$((8 + I * 20 + 4)) count=1 conv=notrunc 2>/dev/null
  printf '\x80' | dd of="$loader" bs=1 seek=$((O + 11)) count=1 conv=notrunc 2>/dev/null
  codesign -f -s - "$loader" &>/dev/null
  echo "Patched $loader (arch $I)."
else
  echo "No slice with caps 0x81 in '$loader', already patched."
fi

/opt/homebrew/bin/yabai --load-sa && echo "Scripting addition loaded."
