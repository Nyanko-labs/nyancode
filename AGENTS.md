# AGENTS.md - Nyan Code Development Guide

This file provides guidelines for agentic coding agents operating in the Nyan Code repository.

## Project Overview

Nyan Code is a modular, terminal-based AI development system integrating tmux, NyanVim, and OpenCode. The project consists of:
- **CLI** (`cli/nyan`) - Bash shell wrapper
- **Core scripts** (`core/tmux/*.sh`, `core/ai/ai.sh`) - Tmux workspace and AI wrapper scripts
- **Workflows** (`workflows/*.yaml`) - YAML workflow definitions
- **Installer** (`install.sh`) - Bootstrap installer

## Build Commands

This is a pure bash/shell project - no build step required.

### Development Commands

```bash
# Install Nyan Code
./install.sh install

# Run CLI
./cli/nyan dev          # Start dev workspace
./cli/nyan debug      # Start debug workspace
./cli/nyan status     # Show active sessions

# Run tmux scripts directly
./core/tmux/dev.sh start    # Start dev session
./core/tmux/dev.sh stop     # Stop dev session
./core/tmux/debug.sh start  # Start debug session
./core/tmux/debug.sh stop    # Stop debug session

# Run AI wrapper
./core/ai/ai.sh refactor "code snippet"
./core/ai/ai.sh fix "error message"
./core/ai/ai.sh generate "description"
```

### Testing

There are no automated tests in this project. Manual testing:
- Run each CLI command and verify expected behavior
- Verify tmux sessions start correctly
- Verify AI wrapper calls opencode properly

### Linting

```bash
# Shell script linting (optional)
shellcheck cli/nyan core/tmux/*.sh core/ai/ai.sh install.sh

# YAML validation (optional)
yamllint workflows/*.yaml
```

## Code Style Guidelines

### Shell Scripts (bash)

**Shebang and interpreter:**
```bash
#!/usr/bin/env bash
```
Always use `#!/usr/bin/env bash` - not `/bin/bash` or direct path.

**Error handling:**
```bash
set -e  # Exit on error (at top of installers)
# OR check exit codes explicitly
command || { echo "Error"; exit 1; }
```

**Variable naming:**
- Uppercase for constants: `NYAN_VERSION`, `INSTALL_DIR`
- Lowercase for locals: `session_name`, `prompt_type`
- Use `_` separator: `PROJECT_DIR`, `SCRIPT_DIR`

**Functions:**
```bash
function_name() {
    local arg1="$1"
    local arg2="${2:-default}"
    # ... implementation
}
```

**Quoting:**
```bash
# Always quote variables
"$variable"
"${var}_suffix"
# Use single quotes for literal strings
'static string'
```

**Conditionals:**
```bash
# String comparison
if [[ "$var" == "value" ]]; then
    # ...
fi

# File existence
if [[ -f "$file" ]]; then
    # ...
fi

# Command exists
if command -v cmd &>/dev/null; then
    # ...
fi
```

**Case statements:**
```bash
case "${1:-default}" in
    start) start_session ;;
    stop) stop_session ;;
    *) echo "Usage" ; exit 1 ;;
esac
```

**Exit codes:**
- 0 = success
- 1 = general error
- 2 = usage error

### YAML Files

**Format:**
```yaml
name: workflow-name
description: Brief description

steps:
  - name: step_name
    command: command to run

ai_usage_points:
  - tool: opencode refactor
```

**Rules:**
- Use 2-space indentation
- No tabs
- Uppercase for boolean values (true/false in YAML 1.1)
- Wrap strings with special chars in quotes

### General Conventions

**File permissions:**
- Shell scripts: `chmod +x script.sh`
- Use `#!/usr/bin/env bash` shebang

**Directory structure:**
```
cli/nyan           # CLI entry point
core/
  tmux/
    dev.sh         # Dev workspace
    debug.sh       # Debug workspace
    review.sh      # Review workspace
    test.sh        # Test workspace
  ai/
    ai.sh          # AI wrapper
    commands/      # opencode command templates (nyan-*.md)
workflows/         # YAML workflows
```

**Error messages:**
- Prefix with `[ERR]` or similar convention
- Use stderr: `echo "Error" >&2`
- Include context: `"Error: file not found: $file"`

**Logging:**
```bash
log_info()  { echo "[INFO] $1"; }
log_ok()    { echo "[OK] $1"; }
log_err()   { echo "[ERR] $1" >&2; }
```

### Import Conventions

No import system - scripts source files directly:
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CONFIG_FILE"
```

### Function Return Values

- Use return 0/1 for boolean success/failure
- Capture output: `result=$(command)`
- Avoid output on stdout for return values

### Common Patterns

**Argument parsing:**
```bash
arg="${1:-default_value}"
shift  # for positional arguments
```

**Path resolution:**
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
```

**Check existing session:**
```bash
if tmux has-session -t "$SESSION" 2>/dev/null; then
    # session exists
fi
```

## Dependencies

Required:
- `tmux` >= 2.9
- `nvim` >= 0.9
- `opencode` CLI

## Common Tasks

### Adding a new tmux workspace

1. Create `core/tmux/<name>.sh`
2. Add executable: `chmod +x core/tmux/<name>.sh`
3. Add the name to the `ask|refactor|...` case in `cli/nyan` and to `cmds` in `core/nvim/nyancode.lua`
4. Create symlink in `install.sh`

### Adding a new AI command

1. Add a template in `core/ai/commands/nyan-<command>.md` (opencode command format: `$ARGUMENTS`, `!`cmd`` shell output, `@file`)
2. Add case handler in `core/ai/ai.sh`

### Adding a workflow

1. Create `workflows/<name>.yaml`
2. Define steps and commands
3. Add to CI if needed

## Configuration

Project config stored at: `~/.nyan-code/config.sh`

```bash
PROJECT_DIR="$HOME/projects"
```

## Notes

- This is a bash-first project with no build system
- Installer generates user config in `$HOME/.nyan-code`
- All scripts should be POSIX-compatible where possible
- CI runs via GitHub Actions (see `.github/workflows/ci.yml`)