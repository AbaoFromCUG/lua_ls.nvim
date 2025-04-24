local utils = require("lua_ls.utils")

local M = {}


function M.get_settings()
    local addon_manager = require("lua_ls.addon_manager")
    local addons = vim.tbl_filter(function(addon)
        return addon.enabled
    end, vim.tbl_values(addon_manager.addons))
    local i = 1
    while i <= #addons do
        ---@type lua_ls.Addon
        local addon = addons[i]
        if addon.dependencies then
            vim.iter(addon.dependencies):each(function(name)
                if addon_manager.addons[name] then
                    table.insert(addons, addon_manager.addons[name])
                end
            end)
        end
        i = i + 1
    end
    local all_settings = vim.iter(addons)
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
