local utils = require("luals.utils")
local addon_manager = require("luals.addon_manager")

local client = {}

---enable addon
---@param addon luals.Addon
function client.enable_addon(addon)
    local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
    local lua_ls = get_clients({ name = "lua_ls" })[1]
    if not lua_ls then
        return
    end
    local new_settings = utils.merge(client.settings, addon.library_settings, addon.config_settings)
    if vim.deep_equal(new_settings, client.settings) then
        return
    end

    -- lua_ls..settings = new_settings
    print(vim.inspect(client.settings))
    local method = "workspace/didChangeConfiguration"
    local ok, err = pcall(lua_ls.notify, method, { settings = lua_ls.settings })
    assert(ok, err)
end

function client.register_lspconfig()
    local lspconfig = require("lspconfig")
    lspconfig.util.on_setup = lspconfig.util.add_hook_after(lspconfig.util.on_setup, function(config)
        if config.name == "lua_ls" then
            -- vim.print(config.settings)
            local all_settings = {
                config.settings,
            }
            for _, addon in pairs(addon_manager.addons) do
                if addon.enabled then
                    table.insert(all_settings, addon.library_settings)
                    table.insert(all_settings, addon.config_settings)
                end
            end

            -- vim.print(all_settings)
            config.settings = utils.merge(unpack(all_settings))
        end
    end)
end

return client
