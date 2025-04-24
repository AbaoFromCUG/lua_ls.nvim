local utils = require("lua_ls.utils")

local M = {}

function M.setup()
    local neoconf = require("neoconf")
    local manager = require("lua_ls.addon_manager")
    local function load_settings()
        local new_settings = neoconf.get("lua_ls")
        new_settings = utils.flatten(new_settings or {})
        require("lua_ls").config = vim.tbl_deep_extend("force", require("lua_ls").config, new_settings)
    end
    require("neoconf.plugins").register({
        name = "lua_ls",
        on_schema = function(schema)
            local addon_names = vim.iter(manager.addons)
                :map(function(_, v)
                    return v.id
                end)
                :totable()
            schema:set("lua_ls", {
                description = "Configuration of lua_ls.nvim",
                type = "object",
                properties = {
                    addons = {
                        type = "array",
                        description = "addon list which will be added to `Lua.workspace.library`",
                        items = {
                            anyOf = {
                                { enum = addon_names },
                                { type = "string" },
                            },
                        },
                    },
                },
            })
        end,
        on_update = function()
            -- print("update")
            -- load_settings()
        end,
    })
    load_settings()
end

return M
