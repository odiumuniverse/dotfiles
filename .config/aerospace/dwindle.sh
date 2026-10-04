#!/usr/bin/env bash
# on-window-detected: Hyprland-style dwindle. A new window lands right after the focused one in the same
# parent; joining the two wraps them in a container of the opposite orientation (normalization), so each
# new window halves the focused one and the split alternates vertical/horizontal.

aerospace=/opt/homebrew/bin/aerospace
id=$AEROSPACE_WINDOW_ID

read -r workspace layout parent <<<"$("$aerospace" list-windows --all \
  --format '%{window-id} %{workspace} %{window-layout} %{window-parent-container-layout}' \
  | awk -v id="$id" '$1 == id { print $2, $3, $4; exit }')"

# floating and accordion windows keep the default placement
case "$layout $parent" in
  *_tiles\ h_tiles) dir=left ;;
  *_tiles\ v_tiles) dir=up ;;
  *) exit 0 ;;
esac

# the first two windows share the root: a plain split in half
tiled=$("$aerospace" list-windows --workspace "$workspace" --format '%{window-layout}' | grep -c _tiles)
[ "$tiled" -gt 2 ] && "$aerospace" join-with --window-id "$id" "$dir"
