# AstroNvim 全栈 IDE 配置实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 AstroNvim v6 上通过 AstroCommunity 安装全栈语言支持、opencode/sidekick AI 插件和常用快捷键，并补齐 rg/fd/lazygit/rust-analyzer。

**Architecture:** `lua/community.lua` 负责所有插件导入；`lua/plugins/astrocore.lua` 负责选项与快捷键；`lua/plugins/better-escape.lua` 固定 jk/jj；`lua/polish.lua` 启用 Lua 模块缓存。工具二进制放 `~/.local/bin`，其余语言服务器由 Mason 管理。

**Tech Stack:** Neovim + AstroNvim v6 + lazy.nvim + AstroCommunity + Mason + opencode.nvim + sidekick.nvim

**Spec:** `docs/superpowers/specs/2026-10-30-astronvim-ide-design.md`

## Global Constraints

- AstroNvim v6，配置文件位于 `/home/administrator/.config/nvim`。
- 无 sudo；工具安装到 `~/.local/bin`。
- GitHub 下载使用 `https://gh-proxy.com/` 前缀。
- 不安装 CodeCompanion / Avante / Copilot / ClaudeCode 插件。
- 不覆盖已有的 git insteadOf 代理配置。
- 当前目录不是 git 仓库，因此没有 commit 步骤；每个任务以验证命令结束。

## Review Focus

- AstroCommunity 导入路径或子模块写错会导致 lazy 启动报错。
- 新快捷键与 AstroNvim 默认键位冲突会导致功能被覆盖。
- Mason 从 GitHub 直连下载可能超时或部分失败。
- `opencode.nvim` main 分支与 opencode CLI v2 的 API 可能漂移。
- 首次 `MasonToolsInstallSync` 可能运行很久，需确认最终没有失败的包。

---

### Task 1: AstroCommunity 插件导入

**Files:**
- Modify: `lua/community.lua`

**Interfaces:**
- Produces: lazy.nvim 可解析的 `AstroNvim/astrocommunity` 导入列表。
- Consumes: 无。

- [ ] **Step 1: 写入 `lua/community.lua`**

```lua
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
```

- [ ] **Step 2: 语法检查**

Run: `nvim --clean --headless -c "lua assert(loadfile('lua/community.lua')); print('community.lua syntax OK')" -c "qa"`

Expected: 输出 `community.lua syntax OK`。

- [ ] **Step 3: 校验导入路径存在**

Run:

```bash
for m in pack.lua pack.python.base pack.python.basedpyright pack.python.ruff pack.typescript pack.html-css pack.tailwindcss pack.rust pack.go pack.cpp pack.cmake pack.markdown pack.docker pack.sql pack.bash motion.nvim-surround motion.mini-move motion.flash-nvim editing-support.nvim-treesitter-context editing-support.treesj git.diffview-nvim test.neotest ai.opencode-nvim ai.sidekick-nvim; do
  base="/tmp/opencode/astrocommunity/lua/astrocommunity/${m//.//}"
  test -f "$base/init.lua" || test -f "$base.lua" || echo "MISSING $m"
done
```

Expected: 无 `MISSING` 输出。

---

### Task 2: 快捷键、选项与编辑增强

**Files:**
- Modify: `lua/plugins/astrocore.lua`
- Create: `lua/plugins/better-escape.lua`
- Modify: `lua/polish.lua`

**Interfaces:**
- Consumes: `sidekick.cli.toggle`、`astrocore.toggle_term_cmd`、`DiffviewOpen/DiffviewClose` 命令。
- Produces: 全局快捷键与编辑器选项。

- [ ] **Step 1: 写入 `lua/plugins/astrocore.lua`**

```lua
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
        ["<Leader>gD"] = { "<Cmd>DiffviewClose<CR>", desc = "Close git diff view" },
        ["<Leader>gg"] = {
          function() require("astrocore").toggle_term_cmd { cmd = "lazygit", direction = "float" } end,
          desc = "Toggle LazyGit",
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
```

- [ ] **Step 2: 创建 `lua/plugins/better-escape.lua`**

```lua
---@type LazySpec
return {
  "max397574/better-escape.nvim",
  opts = {
    timeout = 300,
    default_mappings = false,
    mappings = { i = { j = { k = "<Esc>", j = "<Esc>" } } },
  },
}
```

- [ ] **Step 3: 启用 Lua 模块缓存**

`lua/polish.lua` 全文替换为：

```lua
-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

vim.loader.enable()
```

- [ ] **Step 4: 语法检查三个文件**

Run:

```bash
for f in lua/plugins/astrocore.lua lua/plugins/better-escape.lua lua/polish.lua; do
  nvim --clean --headless -c "lua assert(loadfile('$f'))" -c "qa" || echo "SYNTAX FAIL $f"
done
echo done
```

Expected: 无 `SYNTAX FAIL`。

---

### Task 3: 安装 CLI 工具与 rust-analyzer

**Files:**
- 无配置文件改动；二进制安装到 `~/.local/bin`。

**Interfaces:**
- Produces: `rg`、`fd`、`lazygit`、`rust-analyzer` 可执行文件。

- [ ] **Step 1: 下载并安装 ripgrep 15.2.0**

```bash
mkdir -p /tmp/opencode/tools ~/.local/bin
curl -fL "https://gh-proxy.com/https://github.com/BurntSushi/ripgrep/releases/download/15.2.0/ripgrep-15.2.0-x86_64-unknown-linux-musl.tar.gz" -o /tmp/opencode/tools/ripgrep.tar.gz
tar -xzf /tmp/opencode/tools/ripgrep.tar.gz -C /tmp/opencode/tools
install -m 755 /tmp/opencode/tools/ripgrep-15.2.0-x86_64-unknown-linux-musl/rg ~/.local/bin/rg
```

- [ ] **Step 2: 下载并安装 fd 10.5.0**

```bash
curl -fL "https://gh-proxy.com/https://github.com/sharkdp/fd/releases/download/v10.5.0/fd-v10.5.0-x86_64-unknown-linux-musl.tar.gz" -o /tmp/opencode/tools/fd.tar.gz
tar -xzf /tmp/opencode/tools/fd.tar.gz -C /tmp/opencode/tools
install -m 755 /tmp/opencode/tools/fd-v10.5.0-x86_64-unknown-linux-musl/fd ~/.local/bin/fd
```

- [ ] **Step 3: 下载并安装 lazygit 0.66.2**

```bash
curl -fL "https://gh-proxy.com/https://github.com/jesseduffield/lazygit/releases/download/v0.66.2/lazygit_0.66.2_Linux_x86_64.tar.gz" -o /tmp/opencode/tools/lazygit.tar.gz
tar -xzf /tmp/opencode/tools/lazygit.tar.gz -C /tmp/opencode/tools
install -m 755 /tmp/opencode/tools/lazygit ~/.local/bin/lazygit
```

- [ ] **Step 4: 安装 rust-analyzer 组件**

Run: `rustup component add rust-analyzer`

Expected: 输出 `info: installing component 'rust-analyzer'` 或 `info: component 'rust-analyzer' is up to date`。

- [ ] **Step 5: 验证工具**

Run:

```bash
rg --version | head -1
fd --version
lazygit --version | head -1
rust-analyzer --version | head -1
```

Expected: 四个命令都输出版本号，无 `command not found`。

---

### Task 4: 安装 lazy 插件与 Mason 工具

**Files:**
- 无源码改动；写入 `lazy-lock.json`、`~/.local/share/nvim/lazy`、`~/.local/share/nvim/mason`。

**Interfaces:**
- Consumes: Task 1 的导入列表。
- Produces: 已安装的插件和语言服务器。

- [ ] **Step 1: 同步 lazy 插件**

Run: `nvim --headless "+Lazy! sync" +qa`

Expected: 退出码 0；输出中所有插件完成 clone/checkout，无 `Failed`。

- [ ] **Step 2: 同步 Mason 工具**

Run: `nvim --headless "+MasonToolsInstallSync" +qa`

Expected: 退出码 0；输出安装进度，最终无 `failed` 包。若个别包失败，单独 `:MasonInstall <name>` 重试。

- [ ] **Step 3: 确认没有启动错误**

Run: `nvim --headless "+qa"`

Expected: 无 `Error` / `E5108` / `module not found` 输出。

---

### Task 5: 验证插件、快捷键与 LSP

**Files:**
- 无改动；只读验证。

- [ ] **Step 1: 验证关键模块可加载**

Run:

```bash
nvim --headless -c 'lua for _, m in ipairs({ "opencode", "sidekick", "flash", "nvim-surround", "treesj", "diffview", "neotest" }) do local ok, err = pcall(require, m); print(m, ok, ok and "" or err) end' -c qa
```

Expected: 每个模块输出 `true`。

- [ ] **Step 2: 验证快捷键**

Run:

```bash
nvim --headless -c 'lua vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" }); print("jk=" .. vim.fn.maparg("jk", "i")); print("esc=" .. vim.fn.maparg("<Esc>", "n")); print("cs=" .. vim.fn.maparg("<C-s>", "i")); print("gg=" .. vim.fn.maparg("<Leader>gg", "n"))' -c qa
```

Expected: `jk`、`esc`、`cs`、`gg` 均非空。

- [ ] **Step 3: 验证 Mason 语言服务器**

Run:

```bash
for b in lua-language-server basedpyright-langserver vtsls gopls clangd marksman bash-language-server docker-language-server sqls taplo neocmakelsp; do
  test -x "$HOME/.local/share/nvim/mason/bin/$b" && echo "OK $b" || echo "MISSING $b"
done
```

Expected: 全部 `OK`；Mason 的 shim 名称若与列表不同，用 `ls ~/.local/share/nvim/mason/bin` 对照后记录实际名称。

- [ ] **Step 4: 验证启动速度与无错误**

Run: `time nvim --headless "+qa"`

Expected: 退出码 0，无报错；启动时间在 2 秒左右（首次可能有 treesitter 编译，稍慢）。

---

## 执行记录（2026-10-30）

- Task 1 完成：`lua/community.lua` 导入语言包、编辑增强、opencode/sidekick；Java/Kotlin 已移除。
- Task 2 完成：快捷键、`scrolloff`、better-escape、`vim.loader.enable()` 已写入。
- Task 3 完成：`rg 15.2.0`、`fd 10.5.0`、`lazygit 0.66.2`、`rust-analyzer 1.98.1` 可用。
- Task 4 部分完成：`Lazy! sync` 成功（72 个插件）；Mason 安装按用户要求停止，已安装的工具见设计稿“实施补充”。
- Task 5 完成：启动 0.33 秒且无错误；7 个关键模块 `require` 全部成功；`jk` 插入模式退出实测通过；关键映射均存在。
- 额外完成：`lua/plugins/mason.lua` 为 Mason 下载增加 gh-proxy 重写；Go 模块代理改为 `https://goproxy.cn,direct`。

