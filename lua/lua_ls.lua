local fs = require("lua_ls.fs")
local utils = require("lua_ls.utils")
local popup = require("lua_ls.popup")
local client = require("lua_ls.lsp")
local AddonManager = require("lua_ls.addon_manager")
local a = require("lua_ls.async")

---@class (exact) lua_ls.Settings
---@field Lua? {addonManager?: lua_ls.AddonManagerSetting}

local data_path = vim.fn.stdpath("data")
---@cast data_path string

---@class (exact) lua_ls.Config: lspconfig.Config
---@field settings? lua_ls.Settings

---@type lua_ls.Config
local default_config = {
    settings = {
        Lua = {
            runtime = {
                path = { "?.lua", "?/init.lua" },
                pathStrict = true,
                version = "LuaJIT",
            },
            telemetry = {
                enable = false,
            },
            addonManager = {
                enable = true,
                installDir = vim.fs.joinpath(data_path, "lua_ls"),
                addons = {},
                ui = {
                    size = { width = 0.8, height = 0.8 },
                },
            },
        },
    },
}

---@class lua_ls
---@field config lua_ls.Config
---@field is_loaded boolean
local M = {
    is_loaded = false,
}

---setup
---@param config? lua_ls.Config
function M.setup(config)
    config = vim.tbl_deep_extend("force", default_config, config or {})

    local manager_settings = config.settings.Lua.addonManager
    ---@cast manager_settings -nil
    config.settings.Lua.addonManager = {
        enable = manager_settings.enable,
    }
    a.run(function()
        if config.settings.Lua.addonManager.enable then
            M.addon_manager = AddonManager.new(manager_settings)
            if pcall(require, "neoconf") then
                require("lua_ls.neoconf").setup()
            end
            M.addon_manager:setup()
        end
    end, function()
        M.is_loaded = true
    end)

    client.setup(config)
end

function M.open()
    popup.open()
end

return M
