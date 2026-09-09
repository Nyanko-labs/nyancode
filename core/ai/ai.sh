#!/usr/bin/env bash
# Nyan Code AI wrapper: thin layer over `opencode run`.
# Prompt templates live in core/ai/commands/*.md (opencode custom commands),
# linked into ~/.config/opencode/commands by install.sh.
set -euo pipefail

NYAN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
COMMAND_DIR="$NYAN_ROOT/core/ai/commands"
NYAN_PORT="${NYAN_PORT:-4096}"

usage() {
    echo "Usage: nyan ai <command> [-m provider/model] [-f file]... [--json] [--continue] [text]"
    echo "       (text is also read from stdin when piped)"
    echo "Commands:"
    for f in "$COMMAND_DIR"/nyan-*.md; do
        local n; n="$(basename "$f" .md)"
        printf "  %-10s %s\n" "${n#nyan-}" "$(sed -n 's/^description: //p' "$f")"
    done
    echo "  ask        free-form prompt (no template)"
}

[[ $# -lt 1 ]] && { usage; exit 1; }
cmd="$1"; shift

opts=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -m|--model) opts+=(--model "$2"); shift 2 ;;
        -f|--file)  opts+=(--file "$2"); shift 2 ;;
        --json)     opts+=(--format json); shift ;;
        -c|--continue) opts+=(--continue); shift ;;
        --) shift; break ;;
        *) break ;;
    esac
done

input="$*"
[[ ! -t 0 ]] && input+="${input:+$'\n\n'}$(cat)"

# reuse a running `nyan serve` so sessions/history are shared with the TUI
if curl -sf -o /dev/null "http://127.0.0.1:$NYAN_PORT/global/health" 2>/dev/null; then
    opts+=(--attach "http://127.0.0.1:$NYAN_PORT")
fi

command -v opencode >/dev/null || { echo "opencode not installed: https://opencode.ai" >&2; exit 1; }

case "$cmd" in
    ask)
        [[ -z "$input" ]] && { echo "nothing to ask" >&2; exit 1; }
        exec opencode run "${opts[@]}" -- "$input" ;;
    help|-h|--help) usage ;;
    *)
        [[ -f "$COMMAND_DIR/nyan-$cmd.md" ]] || { echo "unknown command: $cmd" >&2; usage; exit 1; }
        exec opencode run "${opts[@]}" --command "nyan-$cmd" -- "$input" ;;
esac
