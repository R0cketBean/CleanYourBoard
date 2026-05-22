#!/usr/bin/env bash
#
# Take a screenshot of the frontmost CleanYourBoard window.
# Usage:
#   ./Scripts/screenshot.sh idle
#   ./Scripts/screenshot.sh locked
#   ./Scripts/screenshot.sh about
#   ./Scripts/screenshot.sh settings
#
# Before running, bring the desired window to the front:
#   idle / locked   →   click the main window (locked = after pressing Lock)
#   about           →   App menu → About CleanYourBoard
#   settings        →   Cmd+, or click the gear in the toolbar
#
# Output: docs/screenshots/<state>.png, resized to 1400 px max edge.
#
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$PROJECT_ROOT/docs/screenshots"
mkdir -p "$OUT_DIR"

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <idle|locked|about|settings>"
    exit 1
fi

STATE="$1"
case "$STATE" in
    idle | locked | about | settings) ;;
    *)
        echo "Unknown state: $STATE"
        exit 1
        ;;
esac

# Find the frontmost large window owned by CleanYourBoard.
# CGWindowListCopyWindowInfo returns windows in front-to-back order, so the
# first match is whatever the user has on top right now.
WID=$(/usr/bin/swift - <<'SWIFT'
import Cocoa

let opts: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
guard let wins = CGWindowListCopyWindowInfo(opts, kCGNullWindowID) as? [[String: Any]] else {
    exit(1)
}

for w in wins {
    guard let owner = w[kCGWindowOwnerName as String] as? String,
          owner.contains("CleanYourBoard"),
          let id = w[kCGWindowNumber as String] as? Int,
          let layer = w[kCGWindowLayer as String] as? Int, layer == 0,
          let bounds = w[kCGWindowBounds as String] as? [String: CGFloat],
          (bounds["Width"] ?? 0) > 200,
          (bounds["Height"] ?? 0) > 150
    else { continue }
    print(id)
    exit(0)
}
exit(1)
SWIFT
) || true

if [[ -z "${WID:-}" ]]; then
    echo "✗ Could not find a CleanYourBoard window."
    echo "  Make sure the app is open and the window for '$STATE' is on top."
    exit 2
fi

OUT="$OUT_DIR/$STATE.png"
screencapture -x -l "$WID" "$OUT"
sips -Z 1400 "$OUT" >/dev/null

echo "✓ Saved $OUT  (window id $WID, $(/usr/bin/stat -f%z "$OUT") bytes)"
