local uv = vim.uv
local fs = {}

function fs.is_exists(path)
    return uv.fs_stat(path)
end

---read file content
---@param path string
---@return string
function fs.read_file(path)
    local fd = assert(uv.fs_open(path, "r", 438))
    local stat = assert(uv.fs_stat(path))
    local content = assert(uv.fs_read(fd, stat.size, 0))
    return content
end

function fs.write_file() end

function fs.mkdir(path)
    uv.fs_mkdir(path, 448)
end

--- https://github.com/carsakiller/LLS-Addons/blob/main/schemas/addon_info.schema.json
---@class lua_ls.AddonInfo
---@field name string The display name for the addon
---@field description string A description for this addon
---@field size number The size of the addon. Generated automatically
---@field hasPlugin boolean Whether this addon contains a plugin. Generated automatically

--- https://github.com/carsakiller/LLS-Addons/blob/main/schemas/addon_config.schema.json
---@class lua_ls.AddonConfig
---@field words string[] Lua string patterns that, if matched in the content of a file, will recommend this addon get applied.
---                      These should be as unique as possible to prevent this project from being recommended too often and annoying users.",
---@field files string[] Lua string patterns that, if matched to a filename, will recommend this addon get applied.
---                      These should be as unique as possible to prevent this project from being recommended too often and annoying users.",
---@field settings object Configurations to insert/overwrite in the user's local config file when this addon is applied.

---read info.json
---@param info_path string
---@return lua_ls.AddonInfo
function fs.read_addon_info(info_path)
    return vim.json.decode(fs.read_file(info_path))
end

---read config.json
---@param config_path string
---@return lua_ls.AddonConfig
function fs.read_addon_config(config_path)
    return vim.json.decode(fs.read_file(config_path))
end

return fs
