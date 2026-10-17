#!/usr/bin/env bash

TASK=$(fuzzel --dmenu --prompt="Todoist Task: ")

if [ -n "$TASK" ]; then
  /usr/bin/env td add "$TASK"
fi
