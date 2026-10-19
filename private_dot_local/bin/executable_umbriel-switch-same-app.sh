#!/usr/bin/env bash
set -euo pipefail

WINDOWS=$(umbriel windows --json)

ACTIVE_APP=$(echo "$WINDOWS" | jq -r '.[] | select(.active == true) | .app_id')

if [ -z "$ACTIVE_APP" ] || [ "$ACTIVE_APP" = "null" ]; then
  exit 0
fi

MATCHING_IDS=($(echo "$WINDOWS" | jq -r --arg app "$ACTIVE_APP" '.[] | select(.app_id == $app) | .id'))

ACTIVE_INDEX=-1
for i in "${!MATCHING_IDS[@]}"; do
  if echo "$WINDOWS" | jq -e --arg id "${MATCHING_IDS[$i]}" '.[] | select(.id == $id and .focused == true)' >/dev/null; then
    ACTIVE_INDEX=$i
    break
  fi
done

if [ ${#MATCHING_IDS[@]} -le 1 ]; then
  # Only one window exists, nowhere to switch
  exit 0
fi

NEXT_INDEX=$(((ACTIVE_INDEX + 1) % ${#MATCHING_IDS[@]}))
TARGET_ID="${MATCHING_IDS[$NEXT_INDEX]}"

umbriel msg "window-focus:$TARGET_ID"
