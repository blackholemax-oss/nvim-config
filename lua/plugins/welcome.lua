---@type LazySpec
return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      local blackhole = require "user.blackhole"
      local get_icon = require("astroui").get_icon

      opts.dashboard = opts.dashboard or {}
      opts.dashboard.width = 50
      -- Keep descriptions compact so action rows never grow past the content width.
      opts.dashboard.preset = opts.dashboard.preset or {}
      opts.dashboard.preset.keys = {
        { key = "n", action = "<Leader>n", icon = get_icon("FileNew", 0, true), desc = "New File" },
        { key = "f", action = "<Leader>ff", icon = get_icon("Search", 0, true), desc = "Find File" },
        { key = "o", action = "<Leader>fo", icon = get_icon("DefaultFile", 0, true), desc = "Recents" },
        { key = "w", action = "<Leader>fw", icon = get_icon("WordFile", 0, true), desc = "Find Word" },
        { key = "'", action = "<Leader>f'", icon = get_icon("Bookmarks", 0, true), desc = "Bookmarks" },
        { key = "s", action = "<Leader>Sl", icon = get_icon("Refresh", 0, true), desc = "Last Session" },
      }
      opts.dashboard.sections = {
        -- VSCode-like welcome: logo, workspace label, actions, recent files, footer.
        function(self)
          if not self._blackhole_top then
            self._blackhole_top = true
            -- Re-renders after a resize keep the old scroll offset, hiding the logo.
            self.on("UpdatePost", function()
              if vim.api.nvim_win_is_valid(self.win) then
                vim.api.nvim_win_call(self.win, function() vim.fn.winrestview { topline = 1 } end)
              end
            end, self.augroup)
          end
          local win_width = self:size().width
          self.opts.width = win_width >= 52 and 50 or math.max(34, win_width - 2)
          return { text = blackhole.text(win_width), align = "center" }
        end,
        function(self)
          local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
          local max = self.opts.width - 4
          local chars = vim.fn.strchars(cwd)
          if chars > max then cwd = "…" .. vim.fn.strcharpart(cwd, chars - max + 1) end
          return {
            text = { { cwd, hl = "SnacksDashboardDesc" } },
            align = "center",
            padding = { 1, 0 },
          }
        end,
        { section = "keys", gap = 0, padding = { 1, 1 } },
        function(self)
          if self:size().height < 26 then return {} end
          return { { section = "recent_files", limit = 5, title = "Recent", padding = { 1, 1 } } }
        end,
        { section = "startup", padding = { 0, 1 } },
      }

      local function accents()
        blackhole.highlights()
        vim.api.nvim_set_hl(0, "SnacksDashboardKey", { fg = "#22d3ee" })
        vim.api.nvim_set_hl(0, "SnacksDashboardIcon", { fg = "#8b5cf6" })
        vim.api.nvim_set_hl(0, "SnacksDashboardTitle", { fg = "#22d3ee", bold = true })
        vim.api.nvim_set_hl(0, "SnacksDashboardFooter", { fg = "#7c3aed" })
        vim.api.nvim_set_hl(0, "SnacksDashboardDesc", { fg = "#a5b4fc" })
        vim.api.nvim_set_hl(0, "SnacksDashboardSpecial", { fg = "#22d3ee" })
      end
      accents()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("BlackHoleMaxAccents", { clear = true }),
        callback = accents,
      })

      return opts
    end,
  },
}
