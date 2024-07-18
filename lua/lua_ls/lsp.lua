local utils = require("lua_ls.utils")
local lsputil = require("lspconfig.util")

local M = {}

---@param config lspconfig.Config
function M.setup(config)
    local settings = M.get_settings()
    config.settings = utils.merge(config.settings or {}, settings)
    require("lspconfig").lua_ls.setup(config)
end

function M.get_settings()
    local addon_manager = require("lua_ls").addon_manager
    local all_settings = vim.iter(vim.tbl_values(addon_manager.addons))
        :map(function(addon)
            ---@cast addon lua_ls.Addon
            return { addon.library_settings, addon.config_settings }
        end)
        :flatten()
        :totable()

    return utils.merge(unpack(all_settings))
end

---enable addon
function M.update_settings()
    local client = vim.lsp.get_clients({ name = "lua_ls" })[1]

    if not client then
        return
    end

    -- local settings = M.get_settings()
    -- local new_settings = utils.merge(client.settings, settings)
    --
    -- if vim.deep_equal(new_settings, client.config.settings) then
    --     return
    -- end
    -- print("update settings", vim.inspect(new_settings))
    -- client.config.settings = new_settings
    --
    -- local ok, err = pcall(client.notify, "workspace/didChangeConfiguration", {
    --     settings = client.config.settings,
    -- })
    -- client.sta
end

return M
