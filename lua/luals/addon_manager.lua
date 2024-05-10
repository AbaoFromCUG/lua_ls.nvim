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
        local addon = Addon.from_info(info_path)
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

---enable plugin
---@param name string
function addon_manager.enable(name)
    local client = require("luals.client")
    local addon = addon_manager.addons[name]
    if addon then
        addon:enable()
        client.enable_addon(addon)
    else
        if fs.is_exists(vim.fs.normalize(name)) then
            addon_manager.load_local_addon(vim.fs.normalize(name))
        else
            addon_manager.load_git_addon(name)
        end
    end
end

---local addon from local
---@param path string
---@return luals.Addon|nil
function addon_manager.load_local_addon(path)
    local client = require("luals.client")
    local config_path = fs.joinpath(path, "config.json")
    if fs.is_exists(config_path) then
        local addon = Addon.from_config(config_path)
        addon_manager.addons[addon.name] = addon
        addon:enable()
        client.enable_addon(addon)
    else
        vim.notify(string.format("Don't exists config.json in %s", path), vim.log.levels.ERROR, { title = "Luals" })
    end
end

---@param url string
---@return luals.Addon|nil
function addon_manager.load_git_addon(url)
    local config = require("luals").config
    local name = url
    if url:sub(-4) == ".git" then
        name = url:sub(1, -5)
    end
    name = name:gsub("^.*/(.*)/?", "%1")
    local repository_path = fs.joinpath(config.install_dir, name)
    local config_path = fs.joinpath(repository_path, "config.json")
    if fs.is_exists(config_path) then
        addon_manager.load_local_addon(repository_path)
    else
        local git = Git:new()
        git:clone(url, repository_path, function(status, error)
            if status then
                addon_manager.load_local_addon(repository_path)
            else
                vim.notify(string.format("[%s] is invalid name/path/url of addon: %s", url, error), vim.log.levels.ERROR, { title = "Luals" })
            end
        end)
    end
end

return addon_manager
