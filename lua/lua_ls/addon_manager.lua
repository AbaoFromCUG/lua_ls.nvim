local fs = require("lua_ls.fs")
local Git = require("lua_ls.git")
local utils = require("lua_ls.utils")
local a = require("lua_ls.async")

---@class (exact) lua_ls.UIConfig
---@field size? {width?: number, height?:number}

---@class (exact) lua_ls.AddonManagerSetting
---@field enable? boolean
---@field installDir? string
---@field addons? (string|lua_ls.OfficialAddonName|lua_ls.NeovimAddonName)[]
---@field ui?  lua_ls.UIConfig

---@class lua_ls.AddonManager
---@field git lua_ls.Git
---@field addons { [string]: lua_ls.Addon } key is name or local path or url
---@field setting lua_ls.AddonManagerSetting
local AddonManager = {
    official_repository_url = "https://github.com/LuaLS/LLS-Addons/",
}

local builtin_addons = {
    nvim = {
        id = "nvim",
        display_name = "Neovim(stable)",
        description = "neovim type annotations",
        library_settings = {
            ["Lua.workspace.library"] = { vim.fs.joinpath(vim.env.VIMRUNTIME, "lua") },
        },
    },
}

---Addon manager construction
---@param manager_settings lua_ls.AddonManagerSetting
---@return lua_ls.AddonManager
function AddonManager.new(manager_settings)
    ---@type lua_ls.AddonManager
    local o = {
        setting = manager_settings,
        git = Git.new(),
        addons = {},
    }
    o = setmetatable(o, {
        __index = AddonManager,
    })
    return o
end

---@param name string
---@return string
function AddonManager:repository_path(name)
    local repository_path = vim.fs.joinpath(self.setting.installDir, name)
    return repository_path
end

function AddonManager:setup()
    local official_repo_path = self:repository_path("LLS-Addons")
    self.git:cwd(official_repo_path)
    if not fs.is_exists(official_repo_path) then
        fs.mkdir(official_repo_path)
        self.git:clone(self.official_repository_url, official_repo_path)
    else
        vim.schedule(function()
            a.run(function()
                self.git:pull()
            end)
        end)
    end
    self:reload_addons()
    local client = require("lua_ls.lsp")
    client.update_settings()
end

---update
---@param new_setting any
function AddonManager:set_setting(new_setting)
    new_setting = utils.flatten(new_setting)
    local setting = vim.tbl_deep_extend("force", self.setting, new_setting or {})
    if not vim.deep_equal(setting, self.setting) then
        self.setting = setting
        self:reload_addons()
        local client = require("lua_ls.lsp")
        client.update_settings()
    end
end

---get or load addon
---@param name_or_url_or_path string
---@return lua_ls.Addon?
function AddonManager:get_addon(name_or_url_or_path)
    local official_repo_path = self:repository_path("LLS-Addons")
    local joinpath = vim.fs.joinpath
    if fs.is_exists(joinpath(official_repo_path, "addons", name_or_url_or_path)) then
        if self.addons[name_or_url_or_path] then
            return self.addons[name_or_url_or_path]
        end
        local prefix_path = joinpath(official_repo_path, "addons", name_or_url_or_path)
        local info_path = joinpath(prefix_path, "info.json")
        local addon_path = vim.fs.joinpath(prefix_path, "module")
        if not fs.is_exists(vim.fs.joinpath(addon_path, "config.json")) then
            self.git:submodule_init(addon_path)
        end
        self.git:submodule_update(addon_path)
        local addon = self:load_official_addon(info_path)
        self.addons[addon.id] = addon
        return addon
    elseif string.match(name_or_url_or_path, "^git@") or string.match(name_or_url_or_path, "^https?://") then
        local url = name_or_url_or_path
        local dir = url
        if dir:sub(-4) == ".git" then
            dir = dir:sub(1, -5)
        end
        dir = dir:gsub("^.*/(.*)/?", "%1")
        if self.addons[dir] then
            return self.addons[dir]
        end
        local addon_dir = self:repository_path(dir)
        local config_path = joinpath(addon_dir, "config.json")
        if not fs.is_exists(config_path) then
            local git = Git.new()
            git:clone(url, self:repository_path(dir))
        end
        local addon = self:load_local_addon(config_path)
        self.addons[addon.id] = addon
        return addon
    elseif fs.is_exists(joinpath(vim.fs.normalize(name_or_url_or_path), "config.json")) then
        local addon_dir = vim.fs.normalize(name_or_url_or_path)
        local basename = vim.fs.basename(addon_dir)
        if self.addons[basename] then
            return self.addons
        end
        local config_path = joinpath(addon_dir, "config.json")
        local addon = self:load_local_addon(config_path)
        self.addons[addon.id] = addon
        return addon
    elseif builtin_addons[name_or_url_or_path] then
        return builtin_addons[name_or_url_or_path]
    end
end

function AddonManager:reload_addons()
    vim.iter(self.setting.addons):each(function(name)
        self:get_addon(name)
    end)
end

---load addon from info.json
---@param info_path string
---@return lua_ls.Addon
function AddonManager:load_official_addon(info_path)
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
function AddonManager:load_local_addon(config_path)
    local addon_path = vim.fs.dirname(config_path)
    local config = fs.read_addon_config(config_path)
    local addon = {
        id = vim.fs.basename(addon_path),
        name = vim.fs.basename(addon_path),
        library_settings = { ["Lua.workspace.library"] = {
            vim.fs.joinpath(addon_path, "library"),
        } },
        installed = true,
        config_settings = config.settings,
    }
    return addon
end

return AddonManager
