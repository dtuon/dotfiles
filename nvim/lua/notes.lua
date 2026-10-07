-- Per-machine temp dir: comes from the TEMPDOCS env var,
-- falling back to a folder in Neovim's data dir if it isn't set
local temp_dir = vim.env.TEMPDOCS
  or vim.fs.joinpath(vim.fn.stdpath("data"), "tempdocs")

vim.fn.mkdir(temp_dir, "p") -- create it if it doesn't exist

local function temp_path(name)
  return vim.fs.joinpath(temp_dir, name)
end

-- :Tmp <name> -> open/create a file in the temp dir
vim.api.nvim_create_user_command("Tmp", function(opts)
  local name = opts.args ~= "" and opts.args or "scratch.md"
  vim.cmd("edit " .. vim.fn.fnameescape(temp_path(name)))
end, {
  nargs = "?",
  complete = function() return vim.fn.readdir(temp_dir) end,
})

-- Save the current buffer into the temp dir with a timestamped name
vim.keymap.set("n", "<leader>ns", function()
  vim.cmd("saveas " .. vim.fn.fnameescape(temp_path(os.date("note-%Y%m%d-%H%M%S.md"))))
end, { desc = "Save note to temp dir" })

-- Open today's note
vim.keymap.set("n", "<leader>nd", function()
  vim.cmd("edit " .. vim.fn.fnameescape(temp_path(os.date("%Y-%m-%d") .. ".md")))
end, { desc = "Open today's note" })
