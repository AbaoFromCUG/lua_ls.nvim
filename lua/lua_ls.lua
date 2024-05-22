local fs = require("lua_ls.fs")
local utils = require("lua_ls.utils")
local popup = require("lua_ls.popup")
local client = require("lua_ls.client")
local AddonManager = require("lua_ls.addon_manager")
local a = require("lua_ls.async")

---@class (exact) lua_ls.Settings
---@field addonManager? lua_ls.AddonManagerSetting

local data_path = vim.fn.stdpath("data")
---@cast data_path string

---@class (exact) lua_ls.Config
---@field settings? lua_ls.Settings

---@type lua_ls.Config
local default_config = {
    settings = {
        addonManager = {
            enable = true,
            installDir = vim.fs.joinpath(data_path, "lua_ls"),
            addons = {},
            ui = {
                size = { width = 0.8, height = 0.8 },
            },
        },
    },
}

---@class lua_ls
---@field config lua_ls.Config
local M = {}

---setup
---@param config lua_ls.Config
function M.setup(config)
    M.config = vim.tbl_deep_extend("force", default_config, config or {})
    if M.config.settings.addonManager.enable then
        M.addon_manager = AddonManager.new(M.config.settings.addonManager)
    end
    if pcall(require, "neoconf") then
        require("lua_ls.neoconf").setup()
    end

    -- async setup
    a.run(
        function()
            M.addon_manager:setup()
        end,
        vim.schedule_wrap(function()
            client.setup(config)
        end)
    )
end

function M.open()
    popup.open()
end

return M
