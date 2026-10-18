#!/bin/bash
# Toggle an Umbriel named scratchpad with same-key launch.
# Usage: umbriel-scratchpad-toggle.sh <scratchpad> <app_id> <startup_command> [title]
#
# - No window matching app_id/title anywhere -> run startup command
#   (default_scratchpad rule auto-stores it hidden), wait for it, then show it.
# - Window stored in the scratchpad -> scratchpad-toggle (show/hide).
# - Window on a workspace -> hide it back if focused, else focus it.
# Mirrors the behavior of scratchpad-toggle.sh (sway).

set -u

SCRATCHPAD="${1:-}"
APP_ID="${2:-}"
STARTUP_COMMAND="${3:-}"
TITLE="${4:-}"

if [ -z "${SCRATCHPAD:-}" ] || [ -z "${APP_ID:-}" ] || [ -z "${STARTUP_COMMAND:-}" ]; then
  echo "Usage: $0 <scratchpad> <app_id> <startup_command> [title]" >&2
  exit 1
fi

# Window list as JSON array; empty array when the compositor is unreachable.
windows_json() {
  umbriel windows --json 2>/dev/null || echo "[]"
}

# Print "id focused scratchpad" of the first window matching app_id or title.
find_match() {
  windows_json | jq -r \
    --arg app_id "$APP_ID" \
    --arg title "$TITLE" \
    '.[] | select(.app_id == $app_id or ($title != "" and .title == $title))
         | "\(.id) \(.focused) \(.scratchpad)"' | head -n 1
}

MATCH="$(find_match)"

if [ -z "$MATCH" ]; then
  # Nothing exists yet: launch it; the default_scratchpad rule stores it hidden.
  bash -c "$STARTUP_COMMAND" &
  # Wait for the new window to register inside our scratchpad.
  for _ in $(seq 1 15); do
    sleep 0.2
    if windows_json | jq -e \
      --arg app_id "$APP_ID" \
      --arg title "$TITLE" \
      --arg scratchpad "$SCRATCHPAD" \
      'any(.[]; (.app_id == $app_id or ($title != "" and .title == $title))
                and .scratchpad == $scratchpad)' >/dev/null; then
      break
    fi
  done
  # Show it. No-op if the scratchpad is somehow still empty.
  exec umbriel msg "scratchpad-toggle:$SCRATCHPAD"
fi

read -r WIN_ID WIN_FOCUSED WIN_SCRATCHPAD <<<"$MATCH"

if [ "$WIN_SCRATCHPAD" = "$SCRATCHPAD" ]; then
  # Stored in (possibly visible on another output summons it here).
  exec umbriel msg "scratchpad-toggle:$SCRATCHPAD"
fi

if [ "$WIN_SCRATCHPAD" = "default" ]; then
  # Implicit default scratchpad (no named scratchpads configured for it).
  exec umbriel msg "scratchpad-toggle"
fi

if [ "$WIN_FOCUSED" = "true" ]; then
  # Visible on a workspace and focused -> hide it back into the scratchpad.
  exec umbriel msg "window-move-to-scratchpad:$SCRATCHPAD"
else
  # Visible elsewhere (workspace, maybe another output) -> focus it.
  exec umbriel msg "window-focus:$WIN_ID"
fi
