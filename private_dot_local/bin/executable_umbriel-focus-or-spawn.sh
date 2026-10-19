#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <app-id> <executable>"
  exit 1
fi

APP_ID="$1"
EXECUTABLE="$2"

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is not installed. Please install jq to use this script."
  exit 1
fi

WINDOW_IDS=($(umbriel windows --json | jq ".[] | select(.app_id==\"$(echo $APP_ID)\")" | jq -r '.["id"]'))
echo "${WINDOW_IDS[@]}"

# If there is no instance
if [ ${#WINDOW_IDS[@]} -eq 0 ]; then
  setsid "$EXECUTABLE" &
else
  # if there is only one instance
  if [ ${#WINDOW_IDS[@]} -eq 1 ]; then
    echo "ONLY ONE INSTANCE"
    umbriel msg window-focus-warp:$WINDOW_IDS
  else
    # More than one instance -> sort
    echo "More than one instance \n"
    ISORTED=($(printf "%s\n" "${WINDOW_IDS[@]}" | sort -n))

    # Focused window ID
    FOCUSED=$(umbriel windows --json | jq ".[] | select(.active==true)" | jq -r '.id')

    # If not focused on any of them, focus the first one
    if [[ ! " ${ISORTED[@]} " =~ ${FOCUSED} ]]; then
      echo "Not focused on any, focusing the first one... \n"
      umbriel msg window-focus-warp:${ISORTED[0]}
    else
      # If one is in focus, focus the next one
      count=-1
      for i in "${ISORTED[@]}"; do
        ((count = $count + 1))

        if [[ "${i}" == "${FOCUSED}" ]]; then
          ((new_index = $count + 1))
        fi
      done

      # if focus is on last id, loop back to the first
      if [[ "$new_index" -eq "${#WINDOW_IDS[@]}" ]]; then
        echo "Focus is on last one, looping back to first"
        ((new_index = 0))
      fi

      umbriel msg window-focus-warp:${ISORTED[new_index]}
    fi
  fi
fi

# if [ -n "$WINDOW_IDS" ]; then
#   niri msg action focus-window --id "$WINDOW_IDS"
# else
#   setsid "$EXECUTABLE" &
# fi
