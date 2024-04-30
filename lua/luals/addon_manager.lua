local fs = require("luals.fs")
local Git = require("luals.git")
local Addon = require("luals.addon")

---@class luals.Manager
local addon_manager = {
    ---@type { [string]: luals.Addon }
    addons = {},
    ---@type luals.Git
    git = Git:new(),
}

local REPOSITORY_URL = "https://github.com/LuaLS/LLS-Addons/"

function addon_manager.repository_path()
    local config = require("luals").config
    local repository_path = fs.joinpath(config.install_dir, "addonManager")

    return repository_path
end

function addon_manager.bootstrap()
    local repository_path = addon_manager.repository_path()
    if not fs.is_exists(repository_path) then
        fs.mkdir(repository_path)
    end
    addon_manager.git:cwd(repository_path)
    if not fs.is_exists(repository_path) then
        addon_manager.git:clone(REPOSITORY_URL, repository_path, function(status, data)
            assert(status, string.format("Failed to clone %s to %s! %s", REPOSITORY_URL, repository_path, data))
            addon_manager.load_addons()
        end)
    else
        addon_manager.load_addons()
    end
end

function addon_manager.load_addons()
    local repository_path = addon_manager.repository_path()
    addon_manager.addons = {}
    for info_path in fs.glob(repository_path .. "/addons/*/info.json") do
        local addon = Addon:new(info_path)
        if addon.display_name == nil then
            print(vim.inspect(addon))
        end
        addon_manager.addons[addon.name] = addon
    end
end

function addon_manager.install(name)
    local addon = addon_manager.addons[name]
    if addon then
        addon:install()
    end
end

function addon_manager.enable(name)
    local client = require("luals.client")
    local addon = addon_manager.addons[name]
    if addon then
        addon:enable()
        client.enable_addon(addon)
    else
        vim.notify(string.format("Invaild addon's name: [%s]", name), vim.log.levels.ERROR, { title = "Luals" })
    end
end

return addon_manager
