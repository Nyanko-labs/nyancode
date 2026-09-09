# CONTEXT.md - nyancode domain language

Terms used in code, docs, and architecture reviews. Keep them exact.

- **AI command**: a prompt template `core/ai/commands/nyan-<name>.md` in opencode custom-command format. The directory is the only registry: `cli/nyan`, `nyan help`, and NyanVim completion read it. `ask` is the one AI command without a template.
- **opencode adapter**: the `ai()` function in `cli/nyan`. Every call to `opencode` goes through it. It is the seam to replace if the backend ever changes.
- **Workflow**: a shell script `workflows/<name>.sh`, overridable by `~/.nyan-code/workflows/<name>.sh`. Run with `nyan run <name>` or `nyan <name>`. There is no workflow DSL.
- **Workspace**: a workflow that starts a tmux session (`dev`, `debug`).
- **NyanVim bridge**: `core/nvim/nyancode.lua`, linked into NyanVim's `lua/user/plugins/`. It only shells out to `nyan`; it holds no command list of its own.
- **nyan serve**: an `opencode serve` on `:4096`. When it is up, the adapter attaches to it so CLI and nvim share sessions.
