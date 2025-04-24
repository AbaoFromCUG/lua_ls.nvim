local fs = require("lua_ls.fs")
local Git = require("lua_ls.git")
local utils = require("lua_ls.utils")

---@class (exact) lua_ls.UIConfig
---@field size? {width?: number, height?:number}


---@type {[string]: lua_ls.Addon}
local builtin_addons = {
    nvim = {
        id = "nvim",
        display_name = "Neovim(stable)",
        description = "neovim type annotations",
        library_settings = {
            ["Lua.workspace.library"] = { vim.fs.joinpath(vim.env.VIMRUNTIME, "lua") },
        },
        dependencies = { "luvit" },
    },
    ["nvim-config"] = {
        id = "nvim-config",
        display_name = "Neovim config",
        description = "neovim config files",
        library_settings = {
            ["Lua.workspace.library"] = { vim.fs.joinpath(vim.fn.stdpath("config"), "lua") },
        },
        dependencies = { "luvit", "nvim" },
    },
}


---@class lua_ls.AddonManager
---@field official_repo_path string
---@field git lua_ls.Git
---@field addons { [string]: lua_ls.Addon } key is name or local path or url
local AddonManager = {
    official_repo_url = "https://github.com/LuaLS/LLS-Addons/",
    git = Git.new(),
    addons = {},
}

---@param name string
---@return string
function AddonManager.repository_path(name)
    local config = require("lua_ls").config
    local repository_path = vim.fs.joinpath(config.install_dir, name)
    return repository_path
end

function AddonManager.setup()
    local official_repo_path = AddonManager.repository_path("LLS-Addons")
    AddonManager.official_repo_path = official_repo_path

    AddonManager.git:cwd(official_repo_path)
    if not fs.is_exists(official_repo_path) then
        vim.notify("Downloading LLS-Addons...", vim.log.levels.INFO, { tiltle = "Addon Manager of `lua_ls.nvim`" })
        fs.mkdir(official_repo_path)
        AddonManager.git:clone(AddonManager.official_repo_url, official_repo_path)
    end
    AddonManager.reload_addons()
end

---get or load addon
---@param name_or_url_or_path string
---@return lua_ls.Addon?
function AddonManager.load_addon(name_or_url_or_path)
    local official_repo_path = AddonManager.official_repo_path
    local joinpath = vim.fs.joinpath
    local addon
    if fs.is_exists(joinpath(official_repo_path, "addons", name_or_url_or_path)) then
        local prefix_path = joinpath(official_repo_path, "addons", name_or_url_or_path)
        local info_path = joinpath(prefix_path, "info.json")
        local addon_path = vim.fs.joinpath(prefix_path, "module")
        if not fs.is_exists(vim.fs.joinpath(addon_path, "config.json")) then
            vim.notify(string.format("Clone submodule %s...", name_or_url_or_path), vim.log.levels.INFO, { tiltle = "Addon Manager of `lua_ls.nvim`" })
            AddonManager.git:submodule_init(addon_path)
            AddonManager.git:submodule_update(addon_path)
        end
        addon = AddonManager.load_official_addon(info_path)
    elseif string.match(name_or_url_or_path, "^git@") or string.match(name_or_url_or_path, "^https?://") then
        local url = name_or_url_or_path
        local dir = url
        if dir:sub(-4) == ".git" then
            dir = dir:sub(1, -5)
        end
        dir = dir:gsub("^.*/(.*)/?", "%1")
        local addon_dir = AddonManager.repository_path(dir)
        local config_path = joinpath(addon_dir, "config.json")
        if not fs.is_exists(config_path) then
            local git = Git.new()
            git:clone(url, AddonManager.repository_path(dir))
        end
        addon = AddonManager.load_local_addon(config_path)
    elseif fs.is_exists(joinpath(vim.fs.normalize(name_or_url_or_path), "config.json")) then
        local addon_dir = vim.fs.normalize(name_or_url_or_path)
        local config_path = joinpath(addon_dir, "config.json")
        addon = AddonManager.load_local_addon(config_path)
    elseif builtin_addons[name_or_url_or_path] then
        addon = builtin_addons[name_or_url_or_path]
    else
        addon = AddonManager.try_resolve_nvim_plugin(name_or_url_or_path)
    end
    if addon then
        for _, name in ipairs(addon.dependencies or {}) do
            AddonManager.load_addon(name)
        end
        AddonManager.addons[addon.id] = addon
        return addon
    end
end

---try to resolve as a nvim plugin
---@param name string
---@return lua_ls.Addon|nil
function AddonManager.try_resolve_nvim_plugin(name)
    if package.loaded["lazy"] then
        if name == "nvim-full" then
            return {
                id = "nvim-full",
                name = "nvim-full",
                display_name = string.format("nvim+all plugins(nvim plugin)"),
                description = "nvim runtime + all plugins",
                library_settings = {
                    ["Lua.workspace.library"] = vim.iter(require("lazy").plugins())
                        :map(function(plugin)
                            return vim.fs.joinpath(plugin.dir, "lua")
                        end)
                        :totable(),
                },
                dependencies = { "nvim", "nvim-config" },
            }
        end

        local plugin = vim.iter(require("lazy").plugins())
            :filter(function(plugin)
                return plugin.name == name
            end)
            :totable()[1]
        if plugin then
            return {
                id = plugin.name,
                display_name = string.format("%s(nvim plugin)", plugin.name),
                description = plugin[1],
                library_settings = {
                    ["Lua.workspace.library"] = { vim.fs.joinpath(plugin.dir, "lua") },
                },
                dependencies = { "nvim" },
            }
        end
    end
end

function AddonManager.reload_addons()
    local config = require("lua_ls").config
    local offical_addons = vim.fs.find("info.json", { limit = math.huge, path = AddonManager.official_repo_path, type = "file" })
    vim.iter(offical_addons):map(AddonManager.load_official_addon):each(function(addon)
        AddonManager.addons[addon.id] = addon
    end)

    if package.loaded["lazy"] then
        vim.iter(require("lazy").plugins())
            :map(function(plugin)
                return plugin.name
            end)
            :each(function(name)
                AddonManager.load_addon(name)
            end)
    end

    for _, name in ipairs(config.addons) do
        AddonManager.load_addon(name)
        if AddonManager.addons[name] then
            AddonManager.addons[name].enabled = true
        end
    end
end

---load addon from info.json
---@param info_path string
---@return lua_ls.Addon
function AddonManager.load_official_addon(info_path)
    local dir = vim.fs.dirname(info_path)
    local addon_path = vim.fs.joinpath(dir, "module")
    local config_path = vim.fs.joinpath(addon_path, "config.json")

    local info = fs.read_addon_info(info_path)

    local addon = {
        id = vim.fs.basename(dir),
        path = addon_path,
        display_name = info.name,
        size = info.size,
        description = info.description,
        has_plugin = info.hasPlugin,
        library_settings = {
            ["Lua.workspace.library"] = {
                vim.fs.joinpath(addon_path, "library"),
            },
        },
    }
    if fs.is_exists(config_path) then
        addon.installed = true
        local config = fs.read_addon_config(config_path)
        addon.config_settings = config.settings
    else
        addon.installed = false
    end
    return addon
end

---local addon from local path
---@param config_path string
---@return lua_ls.Addon
function AddonManager.load_local_addon(config_path)
    local addon_path = vim.fs.dirname(config_path)
    local config = fs.read_addon_config(config_path)
    local addon = {
        id = vim.fs.basename(addon_path),
        name = vim.fs.basename(addon_path),
        library_settings = {
            ["Lua.workspace.library"] = {
                vim.fs.joinpath(addon_path, "library"),
            },
        },
        installed = true,
        config_settings = config.settings,
    }
    return addon
end

return AddonManager
