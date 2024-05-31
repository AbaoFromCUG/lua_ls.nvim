local utils = require("lua_ls.utils")
local lsputil = require("lspconfig.util")

local M = {}

---@param config lspconfig.Config
function M.setup(config)
    M.hook_lspconfig()

    -- print(vim.inspect(config))
    require("lspconfig").lua_ls.setup(config)
end

function M.hook_lspconfig()
    local hook = lsputil.add_hook_after
    lsputil.on_setup = hook(lsputil.on_setup, function(config)
        if config.name == "lua_ls" then
            config.on_new_config = hook(config.on_new_config, M.on_new_config)
        end
    end)
end

---
---@param config lua_ls.Config
function M.on_new_config(config)
    local addon_manager = require("lua_ls").addon_manager
    vim.wait(10000, function()
        return require("lua_ls").is_loaded
    end, 50)
    local all_settings = vim.iter(vim.tbl_values(addon_manager.addons))
        :map(function(addon)
            ---@cast addon lua_ls.Addon
            return { addon.library_settings, addon.config_settings }
        end)
        :flatten()
        :totable()
    config.settings = utils.merge(config.settings or {}, unpack(all_settings))
    -- print("on_new_config", vim.inspect(config.settings.Lua.workspace.library))
end

---enable addon
function M.update_settings()
    local client = vim.lsp.get_clients({ name = "lua_ls" })[1]
    if not client then
        return
    end

    local addon_manager = require("lua_ls").addon_manager
    local all_settings = vim.iter(vim.tbl_values(addon_manager.addons))
        :map(function(addon)
            ---@cast addon lua_ls.Addon
            return { addon.library_settings, addon.config_settings }
        end)
        :flatten()
        :totable()
    local settings = utils.merge(client.config.settings, unpack(all_settings))

    if vim.deep_equal(settings, client.config.settings) then
        return
    end
    if client.config.original_settings then
        ---@diagnostic disable-next-line: inject-field
        client.config.original_settings = utils.merge(client.config.original_settings, unpack(all_settings))
    end
    -- print("update_settings", vim.inspect(settings.Lua.workspace), vim.inspect(client.config.settings.Lua.workspace))
    client.config.settings = settings

    local ok, err = pcall(client.notify, "workspace/didChangeConfiguration", {
        settings = client.config.settings,
    })
    assert(ok, err)
end

_G.restart = function()
    local lsp_client = vim.lsp.get_clients({ name = "lua_ls" })[1]
    if not lsp_client then
        print("failed")
        return
    end
    local ok, err = pcall(lsp_client.notify, "workspace/didChangeConfiguration", {
        settings = lsp_client.config.settings,
    })
    assert(ok, err)
    print("ok")
end

return M
