#!/bin/sh
# Splits the current tmux window into the project layout: the caller's pane stays on the left
# as the main pane for nvim, with a shell on the right. Passing `claude` puts claude above the
# shell, which is reserved for pinned projects so idle claude sessions don't pile up.
# sesh runs this as a session's startup command; sesh 2.34 has no [[pane]] config to do it natively.
set -eu

shell=$(tmux split-window -h -l 40% -c "$PWD" -P -F '#{pane_id}')
if [ "${1-}" = claude ]; then
	tmux send-keys -t "$shell" claude Enter
	shell=$(tmux split-window -v -l 30% -t "$shell" -c "$PWD" -P -F '#{pane_id}')
fi
tmux send-keys -t "$shell" 'git status' Enter
tmux select-pane -t "$TMUX_PANE"
