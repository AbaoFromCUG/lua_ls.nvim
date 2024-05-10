local fs = require("luals.fs")

---@class luals.Addon
---@field name string The name which is defined in info.json, maybe empty for some addon
---@field display_name string The display name for the addon
---@field description string A description for this addon
---@field size number The size of the addon. Generated automatically
---@field has_plugin boolean Whether this addon contains a plugin. Generated automatically
---@field path string The path of this addon
---@field config_settings {[string]: any}|nil
---@field library_settings {[string]: any}
---@field enabled boolean  Whether this addon is enabled
---@field installed boolean Whether this addon is installed
local Addon = {}

---construct a addon from info.json
---@param info_path string
function Addon.from_info(info_path)
    local path = vim.fs.dirname(info_path)
    local addon = {
        path = fs.joinpath(path, "module"),
        enabled = false,
    }
    setmetatable(addon, {
        __index = Addon,
    })
    ---@cast addon luals.Addon

    local info = vim.json.decode(fs.read_file(info_path))
    assert(info, "can't read" .. vim.inspect(info_path))
    addon.name = vim.fs.basename(vim.fs.dirname(info_path))
    addon.display_name = info.name or addon.name
    addon.size = info.size
    addon.description = info.description
    addon.has_plugin = info.hasPlugin
    addon:load_config()
    return addon
end

---construct a addon from info.json
---@param config_path string
function Addon.from_config(config_path)
    local path = vim.fs.dirname(config_path)
    local addon = {
        path = path,
        enabled = false,
    }
    setmetatable(addon, {
        __index = Addon,
    })
    addon.name = vim.fs.basename(path)
    addon.display_name = addon.name

    ---@cast addon luals.Addon
    addon:load_config()
    return addon
end

function Addon:load_config()
    local config_path = fs.joinpath(self.path, "config.json")
    if fs.is_exists(config_path) then
        local config = vim.json.decode(fs.read_file(config_path))
        assert(config, "can't read" .. vim.inspect(config_path))
        if config.settings ~= nil then
            self.config_settings = config.settings
        end
        self.library_settings = { ["Lua.workspace.library"] = { self.path } }
        self.installed = true
    else
        self.installed = false
    end
end

function Addon:install()
    local git = require("luals.addon_manager").git
    -- callback hell
    git:submodule_init(self.path, function(status, data)
        assert(status, data)
        git:submodule_update(self.path, function(status2, data2)
            assert(status2, data2)
            self.installed = true
        end)
    end)
end

function Addon:enable()
    self.enabled = true
end

function Addon:disable()
    self.enabled = false
end

return Addon
