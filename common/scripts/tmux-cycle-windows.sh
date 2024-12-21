#!/bin/sh
NEXT=$(tmux list-windows | grep -v 'active' | head -n 1 | awk '{print $1}' | sed 's/://')
tmux select-window -t "$NEXT"
