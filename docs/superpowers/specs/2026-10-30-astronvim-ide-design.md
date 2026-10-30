# AstroNvim 全栈 IDE 配置设计

日期：2026-10-30
状态：已获用户批准

## 目标

在现有 AstroNvim v6 模板上，按 AstroNvim 官方推荐方式（AstroCommunity + `plugins/` 覆盖）搭建一套覆盖常用语言、AI Agent 和高效快捷键的完整开发环境。

## 非目标

- 不安装 CodeCompanion / Avante / Copilot / ClaudeCode 插件（用户选择 opencode + sidekick）。
- 不为 AI 插件配置 API key。
- 不改变终端里的全局 git 配置，也不处理 Mason 的下载代理。

## 已确认的需求

- 语言：Python、TypeScript/JS + Web、Rust、Go、C/C++、Lua、SQL、Docker、Bash、Markdown。
- 不安装 Java/Kotlin 支持（用户后续明确移除）。
- AI：`opencode.nvim` + `sidekick.nvim`。
- 快捷键：`jk`/`jj` 退出插入模式，另加一组常用编辑/导航快捷键。
- 追求“全面、快速”，但不重复安装 AstroNvim 已有的功能。

## 方案

### 1. 插件导入（官方方式）

`lua/community.lua` 启用并导入 AstroCommunity 条目：

- 语言包：lua、python(base + basedpyright + ruff)、typescript、html-css、tailwindcss、rust、go、cpp、cmake、markdown、docker、sql、bash。
- 编辑增强：nvim-surround、mini-move、flash-nvim、nvim-treesitter-context、treesj、diffview-nvim、neotest。
- AI：opencode-nvim、sidekick-nvim。

不导入 undotree，因为 `<Leader>fu` 与 AstroNvim/ snacks 的 undo picker 冲突。

### 2. 快捷键与选项

`lua/plugins/astrocore.lua`：

- `scrolloff = 8`、`sidescrolloff = 8`。
- `<Esc>` 清除搜索高亮。
- 插入模式 `<C-s>` 保存。
- 可视模式 `<` / `>` 缩进后保持选中。
- `<C-d>` / `<C-u>` 滚动并居中。
- `<Leader>gd` / `<Leader>gD` 打开/关闭 Diffview。
- `<Leader>gg` 打开 LazyGit。
- `<Leader>ao` 启动 opencode CLI，`<Leader>ac` 启动 claude CLI（Sidekick）。

`lua/plugins/better-escape.lua` 显式固定 `jk` / `jj` 退出插入模式。

### 3. 工具补齐

Mason 注册表没有 `ripgrep` / `fd` / `lazygit`，因此通过 gh-proxy 下载官方二进制到 `~/.local/bin`：

- ripgrep 15.2.0
- fd 10.5.0
- lazygit 0.66.2

并通过 `rustup component add rust-analyzer` 补齐 Rust LSP。其余 LSP/formatter/debugger 由 AstroCommunity 语言包的 Mason 清单安装。

### 4. 性能

`lua/polish.lua` 启用 `vim.loader.enable()`。AstroNvim 已有的 lazy-loading、rtp 裁剪保持不变。

## 风险

- Mason 从 GitHub 直接下载，首次安装较多工具可能较慢或偶发失败，需要重试。
- `opencode.nvim` 跟随 main 分支，与 opencode CLI v2 的 API 可能偶有漂移。
- 语言包会安装较多工具，首次启动前用 `MasonToolsInstallSync` 预热。

## 验证标准

- `Lazy! sync` 无报错，所有导入插件存在。
- 关键模块可 `require`：opencode、sidekick、flash、nvim-surround、treesj、diffview、neotest。
- `jk`、`<Esc>`、插入模式 `<C-s>` 映射生效。
- `rg`、`fd`、`lazygit`、`rust-analyzer` 可执行。
- Mason 语言服务器覆盖已安装的工具范围；未安装项见“实施补充”。

## 实施补充（2026-10-30）

- Java/Kotlin 按用户要求移除，`lua/community.lua` 不再导入对应 pack。
- 新增 `lua/plugins/mason.lua`：包装 `mason-core.spawn.curl/wget`，把 `github.com`、`raw.githubusercontent.com`、`codeload.github.com` 下载重写到 `https://gh-proxy.com/`。实测 clangd 安装从直连卡住变为 53 秒完成。
- Mason 安装按用户要求中途停止。已安装：basedpyright、ruff、vtsls、gopls、delve、goimports、gomodifytags、gotests、iferr、impl、clangd、neocmakelsp、lua-language-server、stylua、selene、marksman、taplo、yaml-language-server、bash-language-server、hadolint、debugpy、codelldb、js-debug-adapter 及各 Web LSP。
- 未安装：docker-language-server、sqls、shellcheck、shfmt、bash-debug-adapter、sqlfluff。
- Go 模块代理持久化为 `https://goproxy.cn,direct`，解决 `proxy.golang.org` 超时。

