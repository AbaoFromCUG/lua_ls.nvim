local utils = require("luals-addonmanager.utils")
local data_path = vim.fn.stdpath("data")
---@cast data_path string

---@class (exact) lua_ls.AddonManagerSetting
---@field enable? boolean
---@field installDir? string
---@field addons? (string|lua_ls.OfficialAddonName|lua_ls.NeovimAddonName)[]
---@field ui?  lua_ls.UIConfig

---@type lua_ls.AddonManagerSetting
local default_config = {

    enable = true,
    addons = {
        "nvim",
    },
    install_dir = vim.fs.joinpath(data_path, "luals-addonmanager", "addons"),
    ui = {
        size = { width = 0.8, height = 0.8 },
    },
}

---@class lua_ls
---@field config lua_ls.Config
local M = {}

local function setup_neoconf()
    local neoconf = require("neoconf")
    local manager = require("luals-addonmanager.addon_manager")
    local function load_settings()
        local new_settings = neoconf.get("lspconfig.lua_ls")
        new_settings = utils.flatten(new_settings or {})
        local addonSetting = vim.tbl_get(new_settings, "Lua", "addonManager")
        M.config = vim.tbl_deep_extend("force", M.config, addonSetting)
    end
    require("neoconf.plugins").register({
        name = "lua_ls",
        on_schema = function(schema)
            local addon_names = vim.iter(manager.addons)
                :map(function(_, v)
                    return v.name
                end)
                :totable()
        end,
        on_update = function()
            load_settings()
        end,
    })
    load_settings()
end

---setup
---@param config? lua_ls.Config
function M.setup(config)
    local popup = require("luals-addonmanager.popup")
    local lsp = require("luals-addonmanager.lsp")
    local AddonManager = require("luals-addonmanager.addon_manager")
    M.config = vim.tbl_deep_extend("force", default_config, config or {})
    if not M.config.enable then
        return
    end

    if pcall(require, "neoconf") then
        setup_neoconf()
    end

    AddonManager.setup()
    -- lsp.setup(config)
end



return M
