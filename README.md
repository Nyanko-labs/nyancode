# NYAN CODE 🐱

> Terminal AI development system: [NyanVim](https://github.com/Nyanko-labs/NyanVim) + tmux + [opencode](https://opencode.ai), driven by one `nyan` command.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/Nyanko-labs/nyancode/main/install.sh | bash
nyan doctor
```

Needs `git`, `tmux`, `nvim`, `opencode`. NyanVim is installed automatically if `~/.config/nvim` is not already NyanVim.

## AI commands

Text comes from args, stdin, or `-f file`. Every command is an [opencode custom command](https://opencode.ai/docs/commands) in `core/ai/commands/`, so it also works inside the opencode TUI as `/nyan-<name>`.

| Command | What it does |
|---|---|
| `nyan ask "<text>"` | free-form prompt |
| `nyan refactor` | refactor, behaviour unchanged |
| `nyan fix "<error>"` | root-cause fix |
| `nyan generate "<desc>"` | generate code |
| `nyan explain` | explain code (read-only agent) |
| `nyan test` | write tests in the project's framework |
| `nyan review` | review uncommitted diff (read-only agent) |
| `nyan commit [-a]` | commit message for staged changes, `-a` commits |
| `nyan chat` | opencode TUI |
| `nyan serve` | opencode server on `:4096`; CLI and nvim reuse it when running |

Flags: `-m provider/model`, `-f file` (repeatable), `--json`, `-c` continue last session.

```bash
git diff | nyan review
nyan explain -f src/app.ts
echo "$ERR" | nyan fix -f src/x.ts
nyan commit -a
```

## NyanVim

`install.sh` links `core/nvim/nyancode.lua` into NyanVim's git-ignored `lua/user/plugins/`, so `:NyanUpdate` never touches it.

| Key | Command |
|---|---|
| `<Space>nr` | `:Nyan refactor` (selection or buffer) |
| `<Space>ne` | `:Nyan explain` |
| `<Space>nt` | `:Nyan test` |
| `<Space>nf` | `:Nyan fix <error>` |
| `<Space>na` | `:Nyan ask <question>` |
| `<Space>nv` | `:Nyan review` |
| `<Space>nn` | `:Nyan chat` (opencode in a split) |

Results open in a markdown split, `q` closes.

## Workspaces

```bash
nyan dev           # nvim + opencode + npm run dev + npm test --watch
nyan debug
nyan list          # workflows in ./workflows and ~/.nyan-code/workflows
nyan run <name>
```

## Layout

```
cli/nyan                 CLI entry point
core/ai/ai.sh            thin wrapper over `opencode run --command nyan-<cmd>`
core/ai/commands/        nyan-*.md opencode command templates
core/nvim/nyancode.lua   NyanVim bridge (:Nyan, <Space>n*)
core/tmux/               tmux workspace scripts
core/workflow/           YAML workflow runner
workflows/               built-in workflows
```

## Add a command

1. Create `core/ai/commands/nyan-<name>.md` with `description:` frontmatter. Use `$ARGUMENTS`, `` !`shell` `` and `@file` as in opencode commands.
2. Add `<name>` to the AI case in `cli/nyan` and to `cmds` in `core/nvim/nyancode.lua`.
3. Re-run `./install.sh` to link it.
