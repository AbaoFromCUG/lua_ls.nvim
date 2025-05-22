local utils = require("lua_ls.utils")
local data_path = vim.fn.stdpath("data")
---@cast data_path string

---@class (exact) lua_ls.Config
---@field enable? boolean
---@field installDir? string
---@field addons? (string|lua_ls.OfficialAddonName|lua_ls.NeovimAddonName)[]
---@field ui?  lua_ls.UIConfig

---@type lua_ls.Config
local default_config = {
    enable = true,
    addons = {
        "nvim",
    },
    install_dir = vim.fs.joinpath(data_path, "lua_ls", "addons"),
    ui = {
        size = { width = 0.8, height = 0.8 },
    },
}

---@class lua_ls
---@field config lua_ls.Config
local M = {}

---setup
---@param config? lua_ls.Config
function M.setup(config)
    local popup = require("lua_ls.popup")
    local lsp = require("lua_ls.lsp")
    local AddonManager = require("lua_ls.addon_manager")
    M.config = vim.tbl_deep_extend("force", default_config, config or {})

    if pcall(require, "neoconf") then
        require("lua_ls.neoconf").setup()
    end

    AddonManager.setup()
    if M.config.enable then
        vim.lsp.enable("lua_ls")
    end
end

return M
