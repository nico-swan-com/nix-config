#!/bin/sh

tmux new-window -t 0:1 -n 'matrix'
tmux send-keys -t 'matrix' 'cmatrix && watch -n 60 tmux-cycle-windows' C-m

tmux new-window -t 0:2 -n 'btop media'
tmux send-keys -t 'btop media' 'btop' C-m
