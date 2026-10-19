#!/usr/bin/env bash

NVIM_WINDOW_ID=$(umbriel windows --json | jq ".[]" | jq "select((.title | contains(\"nvim - nvim\")) and .app_id == \"Alacritty\")" | jq -r '.["id"]')

if [ -n "$NVIM_WINDOW_ID" ]; then
  umbriel msg window-focus-warp:$NVIM_WINDOW_ID
else
  alacritty --title "neovim" -e nvim &
fi
