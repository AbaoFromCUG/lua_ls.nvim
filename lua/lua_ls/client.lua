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
    require("lspconfig").lua_ls.setup(config)
end

---enable addon
---@param addon lua_ls.Addon
function client.enable_addon(addon)
    local get_clients = vim.lsp.get_clients
    local lua_ls = get_clients({ name = "lua_ls" })[1]
    if not lua_ls then
        return
    end
    local new_settings = utils.merge(client.settings, addon.library_settings, addon.config_settings)
    if vim.deep_equal(new_settings, client.settings) then
        return
    end
    print(client.settings)

    print(vim.inspect(client.settings))
    local method = "workspace/didChangeConfiguration"
    local ok, err = pcall(lua_ls.notify, method, { settings = lua_ls.settings })
    assert(ok, err)
end

return client
