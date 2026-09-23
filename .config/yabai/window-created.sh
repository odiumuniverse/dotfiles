#!/usr/bin/env bash
# window_created: fixed-size windows (Arc cmd+, and most app settings) float instead of splitting the space.
# Arc: Little Arc (link from another app) floats on the current space, other Arc windows go to ws1 with focus.
# Rules can't tell Little Arc apart (same app, title is the page), only its AXIdentifier littleBrowserWindow-*.

window=$(yabai -m query --windows --window "$YABAI_WINDOW_ID" 2>/dev/null) || exit 0
IFS=$'\t' read -r app subrole resizable floating <<<"$(jq -r '[.app, .subrole, ."can-resize", ."is-floating"] | @tsv' <<<"$window")"
[ "$subrole" = AXStandardWindow ] || exit 0

float() {
  [ "$floating" = true ] || yabai -m window "$YABAI_WINDOW_ID" --toggle float
}

if [ "$app" = Arc ]; then
  ax_id=$(osascript -e 'tell application "System Events" to value of attribute "AXIdentifier" of window 1 of process "Arc"' 2>/dev/null)
  if [[ $ax_id == littleBrowserWindow-* ]]; then
    float
    yabai -m window "$YABAI_WINDOW_ID" --grid 8:8:1:1:6:6
    exit 0
  fi
  yabai -m window "$YABAI_WINDOW_ID" --space ws1 2>/dev/null && yabai -m space --focus ws1 2>/dev/null
  yabai -m window --focus "$YABAI_WINDOW_ID" 2>/dev/null
fi

[ "$resizable" = false ] && float
exit 0
