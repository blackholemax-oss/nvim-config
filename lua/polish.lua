-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

vim.loader.enable()

-- Startup layout: show Neo-tree beside the Snacks welcome page, like the VSCode explorer.
local function open_startup_tree()
  if vim.bo.filetype ~= "snacks_dashboard" then return end
  local ok, command = pcall(require, "neo-tree.command")
  if ok then command.execute { action = "show", source = "filesystem", position = "left" } end
end

vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function() vim.schedule(open_startup_tree) end,
})
