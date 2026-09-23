#!/usr/bin/env bash
# Replaces yabai's mouse_follows_focus: its per-window rule never reaches Arc's invisible 10x10 dialog
# (bottom-left corner), which takes focus when PiP is clicked. Called from the window_focused signal.

window=$(yabai -m query --windows --window "$YABAI_WINDOW_ID" 2>/dev/null) || exit 0
IFS=, read -r cx cy <<<"$(cliclick p)"

target=$(jq -r --argjson cx "$cx" --argjson cy "$cy" '
  select(.role == "AXWindow" and (.subrole | IN("AXStandardWindow", "AXFloatingWindow", "AXDialog")))
  | .frame
  | select(($cx >= .x and $cx < .x + .w and $cy >= .y and $cy < .y + .h) | not)
  | "=\((.x + .w / 2) | floor),=\((.y + .h / 2) | floor)"
' <<<"$window")

[ -n "$target" ] && cliclick "m:$target"
exit 0
