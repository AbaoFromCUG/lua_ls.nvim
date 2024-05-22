local a = require("lua_ls.async")

---@class lua_ls.Git
---@field repository_path string
local Git = {}

---@param cmd (string[]) Command to execute
---@param opts vim.SystemOpts? Options:
---@return string
local function system(cmd, opts)
    local out = a.system(cmd, opts)
    if out.code ~= 0 then
        error(out.stderr)
    end
    return out.stdout
end

---Git construction
---@return lua_ls.Git
function Git.new()
    local o = {
        repository_path = nil,
    }
    setmetatable(o, {
        __index = Git,
    })

    return o
end

---set working directory
---@param path string
function Git:cwd(path)
    self.repository_path = path
end

---git clone
---@param repository_url string
---@param repository_path string
function Git:clone(repository_url, repository_path)
    self.repository_path = repository_path
    local cmd = {
        "git",
        "clone",
        "--depth",
        1,
        repository_url,
        repository_path,
    }
    return system(cmd, { text = true })
end

function Git:fetch()
    local cmd = {
        "git",
        "fetch",
    }
    return system(cmd, { cwd = self.repository_path })
end

function Git:pull()
    local cmd = {
        "git",
        "pull",
    }
    return system(cmd, { cwd = self.repository_path })
end

---@param submodule_name string
function Git:submodule_init(submodule_name)
    assert(self.repository_path)
    local cmd = {
        "git",
        "submodule",
        "init",
        submodule_name,
    }
    return system(cmd, { cwd = self.repository_path })
end

---@param submodule_name string
function Git:submodule_update(submodule_name)
    local cmd = {
        "git",
        "submodule",
        "update",
        submodule_name,
    }
    return system(cmd, { cwd = self.repository_path })
end

return Git
