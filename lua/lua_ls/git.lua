---@class lua_ls.Git
---@field repository_path string
local Git = {}

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
    return vim.system(cmd, { text = true }):wait()
end

function Git:fetch()
    local cmd = {
        "git",
        "fetch",
    }
    return vim.system(cmd, { cwd = self.repository_path }):wait()
end

function Git:pull()
    local cmd = {
        "git",
        "pull",
    }
    return vim.system(cmd, { cwd = self.repository_path }):wait()
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
    return vim.system(cmd, { cwd = self.repository_path }):wait()
end

---@param submodule_name string
function Git:submodule_update(submodule_name)
    local cmd = {
        "git",
        "submodule",
        "update",
        submodule_name,
    }
    return vim.system(cmd, { cwd = self.repository_path }):wait()
end

return Git
