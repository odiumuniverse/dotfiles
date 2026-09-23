#!/usr/bin/env bash
# <swiftbar.title>yabai spaces</swiftbar.title>
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>
# Refreshed by yabai signals (see yabairc), no interval on purpose.

export PATH=/opt/homebrew/bin:$PATH

spaces=$(yabai -m query --spaces 2>/dev/null) || { echo "–"; exit 0; }
windows=$(yabai -m query --windows)

current=$(jq -r '.[] | select(."has-focus") | .label | ltrimstr("ws")' <<<"$spaces")
echo "${current:-·}"
echo "---"

for n in $(seq 1 10); do
  apps=$(jq -r --arg l "ws$n" --argjson w "$windows" '
    (.[] | select(.label == $l) | .index) as $i
    | [$w[] | select(.space == $i and (."is-minimized" | not)) | .app] | unique | join(", ")' <<<"$spaces")
  exists=$(jq --arg l "ws$n" 'any(.[]; .label == $l)' <<<"$spaces")
  [ "$exists" = true ] || continue
  checked=false
  [ "$n" = "$current" ] && checked=true
  echo "$n  ${apps:-—} | checked=$checked bash=/opt/homebrew/bin/yabai param1=-m param2=space param3=--focus param4=ws$n terminal=false"
done
