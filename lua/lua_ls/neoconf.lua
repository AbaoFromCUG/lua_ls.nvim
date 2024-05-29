local a = require("lua_ls.async")

local M = {}

function M.setup()
    local neoconf = require("neoconf")
    local function load_settings()
        local manager = require("lua_ls").addon_manager
        local new_settings = neoconf.get("lspconfig.lua_ls")
        a.run(function()
            print("will update, ", vim.inspect(new_settings))
            manager:set_setting(new_settings)
        end)
    end
    require("neoconf.plugins").register({
        name = "lua_ls",
        on_schema = function(schema)
            local manager = require("lua_ls").addon_manager
            local addon_names = vim.iter(manager.addons)
                :map(function(_, v)
                    return v.name
                end)
                :totable()
        end,
        on_update = function()
            load_settings()
        end,
    })

    load_settings()
end

return M
