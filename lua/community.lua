---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  -- 语言包
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.python.base" },
  { import = "astrocommunity.pack.python.basedpyright" },
  { import = "astrocommunity.pack.python.ruff" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.tailwindcss" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.cpp" },
  { import = "astrocommunity.pack.cmake" },
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.sql" },
  { import = "astrocommunity.pack.bash" },
  -- 编辑增强
  { import = "astrocommunity.motion.nvim-surround" },
  { import = "astrocommunity.motion.mini-move" },
  { import = "astrocommunity.motion.flash-nvim" },
  { import = "astrocommunity.editing-support.nvim-treesitter-context" },
  { import = "astrocommunity.editing-support.treesj" },
  { import = "astrocommunity.git.diffview-nvim" },
  { import = "astrocommunity.test.neotest" },
  -- AI
  { import = "astrocommunity.ai.opencode-nvim" },
  { import = "astrocommunity.ai.sidekick-nvim" },
}
