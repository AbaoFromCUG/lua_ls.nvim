local health = {}

function health.check()
    local addon_manager = require("lua_ls").addon_manager
    vim.health.start("Addons of lua language server:")
    vim.health.info(string.format("%-30s %s", "name", "enabled"))
    vim.iter(addon_manager.addons):each(function(name, addon)
        vim.health.info(string.format("%-30s %s", name, addon.installed))
    end)
end

return health
