-- Nyan Code <-> NyanVim bridge. Installed as ~/.config/nvim/lua/user/plugins/nyancode.lua
-- (NyanVim's git-ignored user plugin dir, so :NyanUpdate never overwrites it).
-- Adds :Nyan <cmd> and <leader>n* keymaps that call the `nyan` CLI.
-- command names come from core/ai/commands/nyan-*.md via the CLI: one source of truth
local function cmds()
  local out = vim.fn.systemlist({ "nyan", "commands" })
  return vim.v.shell_error == 0 and out or {}
end

local function selection_or_buffer(range)
  local s, e = 1, vim.api.nvim_buf_line_count(0)
  if range > 0 then s, e = vim.fn.line("'<"), vim.fn.line("'>") end
  return table.concat(vim.api.nvim_buf_get_lines(0, s - 1, e, false), "\n")
end

local function open_result(title, lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = "markdown"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.cmd("botright vsplit")
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_buf_set_name(buf, "nyan://" .. title .. "-" .. buf)
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, nowait = true })
end

local function run(cmd, args, range)
  local text = ""
  if range > 0 or vim.tbl_contains({ "refactor", "explain", "test", "fix" }, cmd) then
    text = selection_or_buffer(range)
  end
  local argv = { "nyan", cmd }
  if args ~= "" then table.insert(argv, args) end
  vim.notify("nyan " .. cmd .. " …")
  vim.system(argv, { stdin = text ~= "" and text or nil, text = true }, vim.schedule_wrap(function(r)
    if r.code ~= 0 then
      return vim.notify("nyan " .. cmd .. " failed:\n" .. (r.stderr or ""), vim.log.levels.ERROR)
    end
    open_result(cmd, vim.split(r.stdout, "\n"))
  end))
end

vim.api.nvim_create_user_command("Nyan", function(o)
  local cmd = o.fargs[1]
  if cmd == "chat" then
    return vim.cmd("botright vsplit | terminal nyan chat")
  end
  run(cmd, table.concat(o.fargs, " ", 2), o.range)
end, {
  nargs = "+",
  range = true,
  complete = function() return vim.list_extend({ "chat", "ask" }, cmds()) end,
  desc = "Nyan Code AI",
})

local map = vim.keymap.set
map({ "n", "v" }, "<leader>nr", ":Nyan refactor<cr>", { desc = "Nyan refactor" })
map({ "n", "v" }, "<leader>ne", ":Nyan explain<cr>", { desc = "Nyan explain" })
map({ "n", "v" }, "<leader>nt", ":Nyan test<cr>", { desc = "Nyan write tests" })
map({ "n", "v" }, "<leader>nf", function()
  vim.ui.input({ prompt = "Error: " }, function(e) if e then vim.cmd("Nyan fix " .. e) end end)
end, { desc = "Nyan fix" })
map("n", "<leader>na", function()
  vim.ui.input({ prompt = "Ask nyan: " }, function(q) if q then vim.cmd("Nyan ask " .. q) end end)
end, { desc = "Nyan ask" })
map("n", "<leader>nv", "<cmd>Nyan review<cr>", { desc = "Nyan review diff" })
map("n", "<leader>nn", "<cmd>Nyan chat<cr>", { desc = "Nyan chat (opencode)" })

return {} -- lazy.nvim spec: this file only registers commands/keymaps
