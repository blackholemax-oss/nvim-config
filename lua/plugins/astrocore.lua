---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    options = {
      opt = {
        relativenumber = true,
        number = true,
        spell = false,
        signcolumn = "yes",
        wrap = false,
        scrolloff = 8,
        sidescrolloff = 8,
      },
    },
    mappings = {
      n = {
        ["<Esc>"] = { "<Cmd>nohlsearch<CR>", desc = "Clear search highlight" },
        ["<C-d>"] = { "<C-d>zz", desc = "Scroll down and center" },
        ["<C-u>"] = { "<C-u>zz", desc = "Scroll up and center" },
        ["<Leader>gd"] = { "<Cmd>DiffviewOpen<CR>", desc = "Open git diff view" },
        ["<Leader>gD"] = {
          function()
            if vim.fn.exists ":DiffviewClose" == 1 then
              vim.cmd "DiffviewClose"
            else
              vim.notify("Diffview is not open", vim.log.levels.INFO)
            end
          end,
          desc = "Close git diff view",
        },
        ["<Leader>ao"] = {
          function() require("sidekick.cli").toggle { name = "opencode", focus = true } end,
          desc = "OpenCode CLI",
        },
        ["<Leader>ac"] = {
          function() require("sidekick.cli").toggle { name = "claude", focus = true } end,
          desc = "Claude CLI",
        },
      },
      i = {
        ["<C-s>"] = { "<Cmd>silent! update<CR>", desc = "Save file" },
      },
      x = {
        ["<"] = { "<gv", desc = "Indent left and reselect" },
        [">"] = { ">gv", desc = "Indent right and reselect" },
      },
    },
  },
}
