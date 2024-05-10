---@class luals.Git
---@field repository_path string
local Git = {}

-- function Git.isvaild_url(url)
--     if url.match
-- end

---Git construction
---@return luals.Git
function Git:new()
    local o = {
        repository_path = nil,
    }
    setmetatable(o, {
        __index = self,
    })

    return o
end

local system = vim.system
system = function(cmd, opts, callback)
    return vim.system(
        cmd,
        opts,
        vim.schedule_wrap(function(out)
            if out.code == 0 then
                callback(true, out.stderr)
            else
                callback(false, out.stderr)
            end
        end)
    )
end

---set working directory
---@param path string
function Git:cwd(path)
    self.repository_path = path
end

---git clone
---@param repository_url string
---@param repository_path string
---@param callback function(status, data)
function Git:clone(repository_url, repository_path, callback)
    self.repository_path = repository_path
    local cmd = {
        "git",
        "clone",
        "--depth",
        1,
        repository_url,
        repository_path,
    }
    system(cmd, { text = true }, callback)
end

---@param callback function(status, data)
function Git:fetch(callback)
    local cmd = {
        "git",
        "fetch",
    }
    system(cmd, { cwd = self.repository_path }, callback)
end

---@param submodule_name string
---@param callback function(status, data)
function Git:submodule_init(submodule_name, callback)
    assert(self.repository_path)
    local cmd = {
        "git",
        "submodule",
        "init",
        submodule_name,
    }
    system(cmd, { cwd = self.repository_path }, callback)
end

---@param submodule_name string
---@param callback function(status, data)
function Git:submodule_update(submodule_name, callback)
    local cmd = {
        "git",
        "submodule",
        "update",
        submodule_name,
    }
    system(cmd, { cwd = self.repository_path }, callback)
end

return Git
