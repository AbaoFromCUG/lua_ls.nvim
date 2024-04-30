local fs = {}
local uv = vim.uv or vim.loop

function fs.is_exists(path)
    return not not uv.fs_stat(path)
end

function fs.glob(path)
    local info_paths = vim.split(vim.fn.glob(path), "\n")
    local i = 0
    return function()
        i = i + 1
        if i <= #info_paths then
            return info_paths[i]
        end
    end
end

---read file content
---@param path string
---@return string
function fs.read_file(path)
    local fd, err = uv.fs_open(path, "r", 438)
    assert(fd, err)
    local stat, err2 = uv.fs_stat(path)
    assert(stat, err2)
    local content, err3 = uv.fs_read(fd, stat.size, 0)
    assert(content, err3)
    ---@type string
    return content
end

function fs.mkdir(path)
    ---TODO:check mode?
    uv.fs_mkdir(path, 644)
end

---
---@param ... string
function fs.joinpath(...)
    if vim.fs.joinpath then
        return vim.fs.joinpath(...)
    end
    return table.concat({ ... }, "/")
end

return fs
