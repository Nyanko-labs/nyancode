# NYAN CODE 🐱

> Terminal AI development system: [NyanVim](https://github.com/Nyanko-labs/NyanVim) + tmux + [opencode](https://opencode.ai), driven by one `nyan` command.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/Nyanko-labs/nyancode/main/install.sh | bash
nyan doctor
```

Needs `git`, `tmux`, `nvim`, `opencode`. NyanVim is installed automatically if `~/.config/nvim` is not already NyanVim.

## Nyan TUI

```bash
nyan            # opencode TUI with the Nyan agent and the Night City Mix theme
```

`nyan` with no arguments is the interactive mode. The agent (`core/ai/agents/nyan.md`) is a lazy senior dev: shortest diff that fixes the root cause. The theme (`core/ai/themes/nyan.json`) matches NyanVim's palette. Inside the TUI, `/nyan-review`, `/nyan-fix` and the other templates are available as slash commands, and Tab cycles agents.

## Models: Claude and Ollama

```bash
nyan claude              # log in to Anthropic (Claude Pro/Max subscription or API key)
nyan ollama              # register the models `ollama list` has as an opencode provider
nyan model               # show default + aliases
nyan model sonnet        # set default; claude|opus, sonnet, haiku, ollama, ollama:<tag>, default
nyan -m ollama           # TUI on a local model
nyan explain -m haiku -f src/app.ts
```

`-m` accepts an alias or any `provider/model`. Claude aliases map to `claude-opus-5`, `claude-sonnet-5`, `claude-haiku-4-5`. nyan keeps its provider and model settings in `~/.nyan-code/opencode.json`, passed to opencode as `OPENCODE_CONFIG`, so your own `~/.config/opencode` config is never edited. `install.sh` runs `nyan ollama` automatically when ollama is up.

Ollama tip: a 7B model needs roughly 5 GB free RAM. On an 8 GB machine use `ollama pull qwen2.5-coder:1.5b` and raise `num_ctx` (16k or more) so tool calls work.

## AI commands

Text comes from args, stdin, or `-f file`. Every command is an [opencode custom command](https://opencode.ai/docs/commands) in `core/ai/commands/nyan-<name>.md`, so it also works inside the opencode TUI as `/nyan-<name>`. `nyan help` lists whatever is in that directory.

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

`install.sh` links `core/nvim/nyancode.lua` into NyanVim's git-ignored `lua/user/plugins/`, so `:NyanUpdate` never touches it. `:Nyan <Tab>` completes from `nyan commands`.

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

## Workflows

A workflow is a shell script. `nyan run <name>` (or just `nyan <name>`) runs `~/.nyan-code/workflows/<name>.sh` if it exists, else `workflows/<name>.sh`.

```bash
nyan dev           # tmux: nvim + opencode + npm run dev + npm test --watch
nyan debug         # tmux: logs + terminal + nvim
nyan list
```

## Layout

```
cli/nyan                 the whole CLI: TUI, AI commands, workflows, doctor
core/ai/agents/nyan.md   the Nyan agent (system prompt) for the TUI
core/ai/themes/nyan.json opencode TUI theme, NyanVim palette
core/ai/commands/        nyan-*.md opencode command templates (source of truth for AI commands)
core/nvim/nyancode.lua   NyanVim bridge (:Nyan, <Space>n*)
workflows/               dev.sh, debug.sh, add your own
```

## Add an AI command

Create `core/ai/commands/nyan-<name>.md` with a `description:` frontmatter line. Use `$ARGUMENTS`, `` !`shell` `` and `@file` as in opencode commands. Re-run `./install.sh` to link it. That is the only step: the CLI, `nyan help`, and nvim completion read the directory.

## Add a workflow

Drop `<name>.sh` in `workflows/` (or `~/.nyan-code/workflows/` to override). `nyan <name>` runs it.
