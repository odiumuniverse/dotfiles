#!/usr/bin/env bash
# Work mode for screen sharing: every window opaque. Shadows stay on in both modes.
# Usage: work-mode.sh toggle | apply   (apply re-reads the flag, called from yabairc on start)

flag=/tmp/yabai-work-mode
opacity_rules=(
  "arc-opacity:^Arc$"
  "obsidian-opacity:^Obsidian$"
  "slack-opacity:^Slack$"
  "telegram-opacity:^Telegram$"
)

work_on() {
  for rule in "${opacity_rules[@]}"; do
    yabai -m rule --remove "${rule%%:*}" 2>/dev/null
  done
  for id in $(yabai -m query --windows | jq '.[].id'); do
    yabai -m window "$id" --opacity 1.0 2>/dev/null
  done
  yabai -m config window_shadow on
}

work_off() {
  for rule in "${opacity_rules[@]}"; do
    name=${rule%%:*}
    yabai -m rule --remove "$name" 2>/dev/null
    yabai -m rule --add label="$name" app="${rule#*:}" opacity=0.9
    yabai -m rule --apply "$name"
  done
  yabai -m config window_shadow on
}

case "$1" in
  toggle)
    if [ -e "$flag" ]; then rm -f "$flag"; work_off; else touch "$flag"; work_on; fi
    ;;
  apply)
    if [ -e "$flag" ]; then work_on; else work_off; fi
    ;;
  *)
    echo "usage: $0 toggle|apply" >&2
    exit 1
    ;;
esac
