local M = {}

M.islist = vim.islist or vim.tbl_islist

---merge multiple table and flatten
---@param ... table
function M.merge(...)
    local all_settings = { ... }
    all_settings = vim.tbl_filter(function(item)
        return type(item) == "table" and not vim.tbl_isempty(item)
    end, all_settings)
    all_settings = vim.tbl_map(M.flatten, all_settings)

    local function _merge(tbls)
        -- all_settings = vim.tbl_filter(function(item)
        --     return type(item) == "table" and not vim.tbl_isempty(item)
        -- end, all_settings)
        -- print(vim.inspect(all_settings))
        local settings = vim.deepcopy(tbls[1] or {})
        for i = 2, #tbls, 1 do
            local another = tbls[i]
            if M.islist(another) and M.islist(settings) then
                vim.list_extend(settings, another)
            else
                for key, value in pairs(another) do
                    local value_type = type(value)
                    -- print(key, value, value_type)
                    if value_type == "number" or value_type == "string" or value_type == "boolean" then
                        settings[key] = value
                    else
                        settings[key] = M.merge(settings[key], value)
                    end
                end
            end
        end
        return settings
    end
    return _merge(all_settings)
end

function M.flatten(settings)
    local function _flatten(tbl)
        if type(tbl) == "string" or type(tbl) == "number" or type(tbl)=="boolean" then
            return tbl
        elseif M.islist(tbl) then
            local ctbl = {}
            for _, value in ipairs(tbl) do
                table.insert(ctbl, _flatten(value))
            end
            return ctbl
        else
            local ctbl = {}
            for key, value in pairs(tbl) do
                local path = vim.split(key, "%.")
                local current_tbl = ctbl
                for i = 1, #path - 1, 1 do
                    current_tbl[path[i]] = {}
                    current_tbl = current_tbl[path[i]]
                end
                current_tbl[path[#path]] = _flatten(value)
            end
            return ctbl
        end
    end
    return _flatten(settings)
end

return M
