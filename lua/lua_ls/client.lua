local utils = require("lua_ls.utils")

local client = {}

function client.setup(config)
    local addon_manager = require("lua_ls").addon_manager
    config = vim.deepcopy(config)
    local all_settings = vim.iter(addon_manager.addons)
        :map(function(_, addon)
            ---@cast addon lua_ls.Addon
            return { addon.library_settings, addon.config_settings }
        end)
        :flatten()
        :totable()
    config.settings = utils.merge(config.settings, unpack(all_settings))
    print("setup", vim.inspect(config.settings.Lua.workspace))
    require("lspconfig").lua_ls.setup(config)
end

---enable addon
function client.update_settings()
    local lsp_client = vim.lsp.get_clients({ name = "lua_ls" })[1]
    if not lsp_client then
        return
    end

    local addon_manager = require("lua_ls").addon_manager
    local all_settings = vim.iter(addon_manager.addons)
        :map(function(_, addon)
            ---@cast addon lua_ls.Addon
            return { addon.library_settings, addon.config_settings }
        end)
        :flatten()
        :totable()
    local settings = utils.merge(lsp_client.config.settings, unpack(all_settings))

    if vim.deep_equal(settings, lsp_client.config.settings) then
        return
    end
    if lsp_client.config.original_settings then
        lsp_client.config.original_settings = utils.merge(lsp_client.config.original_settings, unpack(all_settings))
    end
    lsp_client.config.settings = settings
    print("update_settings", vim.inspect(settings.Lua.workspace))

    local ok, err = pcall(lsp_client.notify, "workspace/didChangeConfiguration", {
        settings = lsp_client.config.settings,
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

return client
