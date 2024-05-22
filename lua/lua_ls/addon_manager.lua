local fs = require("lua_ls.fs")
local Git = require("lua_ls.git")

---@class (exact) lua_ls.UIConfig
---@field size? {width?: number, height?:number}

---@class (exact) lua_ls.AddonManagerSetting
---@field enable? boolean
---@field installDir? string
---@field addons? (string|lua_ls.BuiltinAddonName)[]
---@field ui?  lua_ls.UIConfig

---@class lua_ls.AddonManager
---@field git lua_ls.Git
---@field addons { [string]: lua_ls.Addon } key is name or local path or url
---@field setting lua_ls.AddonManagerSetting
local AddonManager = {
    official_repository_url = "https://github.com/LuaLS/LLS-Addons/",
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
    local builtin_repo_path = self:repository_path("LLS-Addons")
    self.git:cwd(builtin_repo_path)
    if not fs.is_exists(builtin_repo_path) then
        fs.mkdir(builtin_repo_path)
        self.git:clone(self.official_repository_url, builtin_repo_path)
    else
        self.git:pull()
    end
    self:reload_addons()
end

---update
---@param new_setting any
function AddonManager:set_setting(new_setting)
    local setting = vim.tbl_deep_extend("force", self.setting, new_setting)
    if not vim.deep_equal(setting, self.setting) then
        self.setting = setting
        self:reload_addons()
    end
end

function AddonManager:reload_addons()
    self.addons = {}
    local builtin_repo_path = self:repository_path("LLS-Addons")
    self.git:cwd(builtin_repo_path)
    self.addons = vim.iter(self.setting.addons)
        :map(function(name_or_url_or_path)
            local joinpath = vim.fs.joinpath
            if fs.is_exists(joinpath(builtin_repo_path, "addons", name_or_url_or_path)) then
                local prefix_path = joinpath(builtin_repo_path, "addons", name_or_url_or_path)
                local info_path = joinpath(prefix_path, "info.json")
                local addon_path = vim.fs.joinpath(prefix_path, "module")
                if not fs.is_exists(vim.fs.joinpath(addon_path, "config.json")) then
                    self.git:submodule_init(addon_path)
                end
                self.git:submodule_update(addon_path)
                local addon = self:load_builtin_addon(info_path)
                ---@diagnostic disable-next-line: redundant-return-value
                return addon.id, addon
            elseif string.match(name_or_url_or_path, "^git@") or string.match(name_or_url_or_path, "^https?://") then
                local url = name_or_url_or_path
                local dir = url
                if dir:sub(-4) == ".git" then
                    dir = dir:sub(1, -5)
                end
                dir = dir:gsub("^.*/(.*)/?", "%1")
                local addon_dir = self:repository_path(dir)
                local config_path = joinpath(addon_dir, "config.json")
                if not fs.is_exists(config_path) then
                    local git = Git.new()
                    git:clone(url, self:repository_path(dir))
                end
                local addon = self:load_local_addon(config_path)
                addon.id = url
                ---@diagnostic disable-next-line: redundant-return-value
                return url, addon
            elseif fs.is_exists(joinpath(vim.fs.normalize(name_or_url_or_path), "config.json")) then
                local addon_dir = vim.fs.normalize(name_or_url_or_path)
                local config_path = joinpath(addon_dir, "config.json")
                local addon = self:load_local_addon(config_path)
                addon.id = addon_dir
                ---@diagnostic disable-next-line: redundant-return-value
                return addon_dir, addon
            end
        end)
        :totable()
end

---load addon from info.json
---@param info_path string
---@return lua_ls.Addon
function AddonManager:load_builtin_addon(info_path)
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
        library_settings = { ["Lua.workspace.library"] = { addon_path } },
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
    local addon_dir = vim.fs.dirname(config_path)
    local config = fs.read_addon_config(config_path)
    local addon = {
        name = vim.fs.basename(addon_dir),
        library_settings = { ["Lua.workspace.library"] = { addon_dir } },
        installed = true,
        config_settings = config.settings,
    }
    return addon
end

return AddonManager
