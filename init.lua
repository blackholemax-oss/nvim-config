-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.

-- Route GitHub git traffic through gh-proxy.com for faster plugin downloads (requires git >= 2.31).
-- Append to any GIT_CONFIG_* entries inherited from the environment instead of overwriting them.
local github = "https://github.com/"
local gh_proxy = "https://gh-proxy.com/"
local git_config_count = tonumber(vim.env.GIT_CONFIG_COUNT) or 0
vim.env["GIT_CONFIG_KEY_" .. git_config_count] = "url." .. gh_proxy .. github .. ".insteadOf"
vim.env["GIT_CONFIG_VALUE_" .. git_config_count] = github
vim.env.GIT_CONFIG_COUNT = tostring(git_config_count + 1)

local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  local result = vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
  if vim.v.shell_error ~= 0 then
    -- stylua: ignore
    vim.api.nvim_echo({ { ("Error cloning lazy.nvim:\n%s\n"):format(result), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
    vim.fn.getchar()
    vim.cmd.quit()
  end
end

vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

require "lazy_setup"
require "polish"
