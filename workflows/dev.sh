#!/usr/bin/env bash
# Nyan Code dev workspace: nvim | opencode / npm run dev / npm test --watch
# Pane ids come from tmux itself, so base-index / pane-base-index settings don't matter.
set -euo pipefail

SESSION="nyan-dev"
LAYOUT="${LAYOUT:-tiled}"
DIR="$(pwd)"

case "${1:-start}" in
    stop) tmux kill-session -t "$SESSION" 2>/dev/null && echo "stopped $SESSION"; exit ;;
    start) ;;
    *) echo "Usage: $0 {start|stop}"; exit 1 ;;
esac

if tmux has-session -t "$SESSION" 2>/dev/null; then
    exec tmux attach-session -t "$SESSION"
fi

p0=$(tmux new-session -d -s "$SESSION" -n nvim -c "$DIR" -P -F '#{pane_id}')
p1=$(tmux split-window -h -t "$p0" -c "$DIR" -P -F '#{pane_id}')
p2=$(tmux split-window -v -t "$p1" -c "$DIR" -P -F '#{pane_id}')
p3=$(tmux split-window -v -t "$p0" -c "$DIR" -P -F '#{pane_id}')

tmux send-keys -t "$p0" "nvim" C-m
tmux send-keys -t "$p1" "opencode" C-m
tmux send-keys -t "$p2" "npm run dev" C-m
tmux send-keys -t "$p3" "npm test -- --watch" C-m

tmux select-layout -t "$SESSION" "$LAYOUT"
tmux select-pane -t "$p0"
exec tmux attach-session -t "$SESSION"
