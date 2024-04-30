local addon_manager = require("luals.addon_manager")

local health = {}

function health.check()
    vim.health.info(string.format("%-30s %-10s %s", "name", "enabled", "installed"))
    for name, addon in pairs(addon_manager.addons) do
        vim.health.info(string.format("%-30s %-10s %s", name, addon.enabled, addon.installed))
    end
end

return health
