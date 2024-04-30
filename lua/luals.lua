local fs = require("luals.fs")
local popup = require("luals.popup")
local client = require("luals.client")
local manager = require("luals.addon_manager")

---@class luals.ConfigUI
---@field size? {width?: number, height?:number}

---@class luals.Config
---@field install_dir? string
---@field ensure_installed string[]
---@field auto_update? boolean
---@field ui?  luals.ConfigUI

---@type luals.Config
local default_config = {
    ---@diagnostic disable-next-line: param-type-mismatch
    install_dir = fs.joinpath(vim.fn.stdpath("data"), "luals"),
    auto_update = true,
    ensure_installed = {},
    ui = {
        size = { width = 0.8, height = 0.8 },
    },
}

---@class luals
local M = {
    config = default_config,
}

---setup
---@param config? luals.Config
function M.setup(config)
    M.config = vim.tbl_deep_extend("force", default_config, config or {})
    manager.bootstrap()
    client.register_lspconfig()

    if pcall(require, "neoconf") then
        require("luals.neoconf").register()
    end
end

function M.open()
    popup.open()
end

return M
