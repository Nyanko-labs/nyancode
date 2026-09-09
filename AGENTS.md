# AGENTS.md - Nyan Code

Guidelines for coding agents working in this repository. Read `CONTEXT.md` for the domain terms and `README.md` for usage.

## What this is

A bash CLI (`cli/nyan`) that ties together NyanVim, tmux, and opencode. Four files matter:

| Path | Role |
|---|---|
| `cli/nyan` | the whole CLI, including the opencode adapter (`ai()`) |
| `core/ai/commands/nyan-*.md` | AI command templates, the only registry of AI commands |
| `core/nvim/nyancode.lua` | NyanVim bridge, shells out to `nyan` |
| `workflows/*.sh` | workflows, plain shell |

`install.sh` only creates symlinks. There is no build step and no package manager.

## Rules

- Do not add a registry, list, or case branch for AI commands anywhere. Adding a template file is the whole change.
- Every `opencode` invocation goes through `ai()` in `cli/nyan`.
- Workflows are shell scripts. Do not reintroduce a YAML or other DSL.
- Keep `bash -n`, `shellcheck -S warning cli/nyan install.sh workflows/*.sh`, and `nvim --clean --headless -c "luafile core/nvim/nyancode.lua" -c qa` passing. CI runs exactly these.
- New domain terms go in `CONTEXT.md`.

## Verify a change

```bash
shellcheck -S warning cli/nyan install.sh workflows/*.sh
nvim --clean --headless -c "luafile core/nvim/nyancode.lua" -c qa
./cli/nyan help && ./cli/nyan commands && ./cli/nyan list
echo 'x=1' | ./cli/nyan explain     # real opencode call
```
