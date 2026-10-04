#!/usr/bin/env bash
# on-window-detected for Arc: Little Arc (link from another app) floats centered on the workspace the
# link was clicked on, other Arc windows go to workspace 1.
# Arc's activation focuses its main window first, so a link click jumps to workspace 1 before Little Arc
# exists. A jump in the last 2s means a link click: undo it right away with plain aerospace calls, and
# only then confirm via the AXIdentifier (littleBrowserWindow-*), which needs a slow osascript.

aerospace=/opt/homebrew/bin/aerospace
id=$AEROSPACE_WINDOW_ID

read -r at prev focused 2>/dev/null </tmp/aerospace-workspace-switch
jumped=
if [ -n "$prev" ] && [ "$prev" != "$focused" ] && [ $(($(date +%s) - at)) -le 2 ]; then
  jumped=1
  "$aerospace" layout floating --window-id "$id"
  "$aerospace" move-node-to-workspace --window-id "$id" --focus-follows-window "$prev"
fi

IFS=$'\t' read -r title screen <<<"$("$aerospace" list-windows --all \
  --format '%{window-id}%{tab}%{window-title}%{tab}%{monitor-appkit-nsscreen-screens-id}' \
  | awk -F'\t' -v id="$id" '$1 == id { print $2 "\t" $3; exit }')"

# prints "little" after centering the window at 70%x70% of its screen, "big" for a regular Arc window
place() {
  osascript -l JavaScript - "$title" "${screen:-1}" "$jumped" 2>/dev/null <<'EOF'
function run([title, screen, jumped]) {
  ObjC.import('AppKit');
  const screens = $.NSScreen.screens;
  const vf = screens.objectAtIndex(Number(screen) - 1).visibleFrame;
  const primaryH = screens.objectAtIndex(0).frame.size.height;
  const w = Math.round(vf.size.width * 0.7), h = Math.round(vf.size.height * 0.7);
  const x = Math.round(vf.origin.x + (vf.size.width - w) / 2);
  const y = Math.round(primaryH - vf.origin.y - vf.size.height + (vf.size.height - h) / 2);
  const arc = Application('System Events').processes.byName('Arc');
  const isLittle = win => String(win.attributes.byName('AXIdentifier').value()).startsWith('littleBrowserWindow-');
  const center = win => { win.position = [x, y]; win.size = [w, h]; return 'little'; };
  for (let i = 0; i < 20; i++) {
    for (const win of arc.windows()) {
      if (win.name() === title) return isLittle(win) ? center(win) : 'big';
    }
    delay(0.05);
  }
  // the title changes once the page loads (URL -> page title); after a link-click jump the new window
  // is the frontmost Little Arc, AX lists windows front to back
  if (jumped) {
    const win = arc.windows().find(isLittle);
    if (win) return center(win);
  }
  return '';
}
EOF
}

case $(place) in
  little)
    # still tiled: floating it keeps the tile frame, so center again
    [ -n "$jumped" ] || { "$aerospace" layout floating --window-id "$id" && place >/dev/null; }
    ;;
  big)
    [ -n "$jumped" ] && "$aerospace" layout tiling --window-id "$id"
    "$aerospace" move-node-to-workspace --window-id "$id" 1
    ;;
esac
