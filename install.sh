#!/usr/bin/env bash
# Nyan Code installer: links the CLI, opencode command templates and the NyanVim bridge.
#   curl -fsSL https://raw.githubusercontent.com/Nyanko-labs/nyancode/main/install.sh | bash
#   ./install.sh            install from this checkout
#   ./install.sh uninstall
set -euo pipefail

REPO="${NYANCODE_REPO:-https://github.com/Nyanko-labs/nyancode.git}"
INSTALL_DIR="${NYANCODE_DIR:-$HOME/.nyan-code}"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
BIN="$HOME/.local/bin"

log() { printf '\033[0;36m[nyan]\033[0m %s\n' "$*"; }

install() {
    for d in git tmux nvim; do
        command -v "$d" >/dev/null || { echo "missing: $d" >&2; exit 1; }
    done
    command -v opencode >/dev/null || log "opencode not found: curl -fsSL https://opencode.ai/install | bash"

    # 1. source: use this checkout if run from the repo, else clone/pull
    if [[ -f "${BASH_SOURCE[0]:-}" && -f "$(dirname "${BASH_SOURCE[0]}")/cli/nyan" ]]; then
        INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    elif [[ -d "$INSTALL_DIR/.git" ]]; then
        git -C "$INSTALL_DIR" pull --ff-only
    else
        git clone --depth 1 "$REPO" "$INSTALL_DIR"
    fi
    log "source: $INSTALL_DIR"

    # 2. CLI
    mkdir -p "$BIN"
    ln -sf "$INSTALL_DIR/cli/nyan" "$BIN/nyan"
    log "cli: $BIN/nyan"

    # 3. opencode custom commands (global: ~/.config/opencode/commands)
    mkdir -p "$CFG/opencode/commands"
    for f in "$INSTALL_DIR"/core/ai/commands/nyan-*.md; do
        ln -sf "$f" "$CFG/opencode/commands/$(basename "$f")"
    done
    log "opencode commands: $CFG/opencode/commands/nyan-*.md"

    # 3b. nyan agent + theme; set theme only if the user has not chosen one
    mkdir -p "$CFG/opencode/agents" "$CFG/opencode/themes"
    ln -sf "$INSTALL_DIR/core/ai/agents/nyan.md" "$CFG/opencode/agents/nyan.md"
    ln -sf "$INSTALL_DIR/core/ai/themes/nyan.json" "$CFG/opencode/themes/nyan.json"
    local oc_cfg
    for oc_cfg in "$CFG/opencode/opencode.jsonc" "$CFG/opencode/opencode.json"; do [[ -f "$oc_cfg" ]] && break; done
    if [[ ! -f "$oc_cfg" ]]; then
        printf '{\n  "$schema": "https://opencode.ai/config.json",\n  "theme": "nyan"\n}\n' > "$oc_cfg"
    elif ! grep -q '"theme"' "$oc_cfg"; then
        sed -i.bak '1s/{/{ "theme": "nyan",/' "$oc_cfg" && rm -f "$oc_cfg.bak"
    fi
    log "nyan agent + theme: $oc_cfg"

    # 4. NyanVim (+ bridge plugin in its git-ignored user dir)
    if [[ ! -f "$CFG/nvim/lua/nyanvim/init.lua" ]]; then
        log "NyanVim not found, installing"
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/Nyanko-labs/NyanVim/main/install.sh)"
    fi
    mkdir -p "$CFG/nvim/lua/user/plugins"
    ln -sf "$INSTALL_DIR/core/nvim/nyancode.lua" "$CFG/nvim/lua/user/plugins/nyancode.lua"
    log "nvim bridge: $CFG/nvim/lua/user/plugins/nyancode.lua"

    mkdir -p "$HOME/.nyan-code/workflows"

    # 5. local models: register whatever ollama has (skipped when ollama is not running)
    if curl -sf -m 2 "${OLLAMA_URL:-http://localhost:11434}/api/tags" >/dev/null 2>&1; then
        "$INSTALL_DIR/cli/nyan" ollama || true
    fi
    case ":$PATH:" in *":$BIN:"*) ;; *) log "add to PATH: export PATH=\"$BIN:\$PATH\"" ;; esac
    log "done. try: nyan doctor"
}

uninstall() {
    rm -f "$BIN/nyan" "$CFG"/opencode/commands/nyan-*.md "$CFG/nvim/lua/user/plugins/nyancode.lua"
    log "uninstalled (clone at $INSTALL_DIR left in place)"
}

case "${1:-install}" in
    install) install ;;
    uninstall) uninstall ;;
    *) echo "Usage: $0 {install|uninstall}"; exit 1 ;;
esac
