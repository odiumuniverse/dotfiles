#!/usr/bin/env bash
# Keeps labelled spaces ws1..ws10: ws1-5 on the main display, ws6-10 on the secondary one, all ten on a
# single display. Mirrors aerospace workspace-to-monitor-force-assignment. Needs the scripting addition.

lock=/tmp/yabai-spaces.lock
mkdir "$lock" 2>/dev/null || exit 0
trap 'rmdir "$lock"' EXIT

displays=$(yabai -m query --displays)
main=$(jq '.[] | select(.frame.x == 0 and .frame.y == 0) | .index' <<<"$displays")
secondary=$(jq --argjson m "$main" '[.[] | select(.index != $m) | .index] | first // empty' <<<"$displays")

regular_spaces() {
  yabai -m query --spaces --display "$1" | jq '[.[] | select(."is-native-fullscreen" | not) | .index]'
}

ensure_count() {
  local display=$1 want=$2 have
  have=$(regular_spaces "$display" | jq length)
  while [ "$have" -lt "$want" ]; do
    yabai -m space --create "$display" || break
    have=$((have + 1))
  done
}

label_range() {
  local display=$1 first=$2 count=$3 i=0
  for idx in $(regular_spaces "$display" | jq -r ".[:$count][]"); do
    yabai -m space "$idx" --label "ws$((first + i))"
    i=$((i + 1))
  done
}

for idx in $(yabai -m query --spaces | jq -r '.[] | select(.label | startswith("ws")) | .index'); do
  yabai -m space "$idx" --label ""
done

if [ -n "$secondary" ]; then
  ensure_count "$main" 5
  ensure_count "$secondary" 5
  label_range "$main" 1 5
  label_range "$secondary" 6 5
else
  ensure_count "$main" 10
  label_range "$main" 1 10
fi

# on-window-detected; rules resolve the label to an index when added, so re-add after relabelling.
# ^ follows focus to the space; only standard windows, so popups and dialogs don't drag focus away.
# Arc lives in window-created.sh: Little Arc must stay on the current space.
rules=(
  "wezterm:^WezTerm$:ws2"
  "telegram:^Telegram$:ws3"
  "tv:^TV$:ws4"
  "goland:^GoLand$:ws4"
  "datagrip:^DataGrip$:ws5"
  "obsidian:^Obsidian$:ws6"
  "slack:^Slack$:ws7"
  "orbstack:^OrbStack$:ws8"
)
for rule in "${rules[@]}"; do
  IFS=: read -r name app space <<<"$rule"
  yabai -m rule --remove "$name" 2>/dev/null
  yabai -m rule --add label="$name" app="$app" subrole="^AXStandardWindow$" space="^$space" 2>/dev/null
done

open -g "swiftbar://refreshplugin?name=yabai" 2>/dev/null
exit 0
