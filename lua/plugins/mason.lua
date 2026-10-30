---@type LazySpec
return {
  "mason-org/mason.nvim",
  config = function(_, opts)
    local ok, spawn = pcall(require, "mason-core.spawn")
    if ok and not rawget(spawn, "__gh_proxy_patched") then
      rawset(spawn, "__gh_proxy_patched", true)

      local prefix = "https://gh-proxy.com/"
      local pattern = "^https://(github%.com/|raw%.githubusercontent%.com/|codeload%.github%.com/)"

      local function rewrite(args)
        if type(args) ~= "table" then return args end
        for i, value in ipairs(args) do
          if type(value) == "string" then args[i] = value:gsub(pattern, prefix .. "https://%1") end
        end
        return args
      end

      for _, method in ipairs { "curl", "wget" } do
        local original = spawn[method]
        if type(original) == "function" then
          rawset(spawn, method, function(args) return original(rewrite(args)) end)
        end
      end
    end
    require("mason").setup(opts)
  end,
}
