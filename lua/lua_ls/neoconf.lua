local utils = require("lua_ls.utils")

local M = {}

function M.setup()
    local neoconf = require("neoconf")
    local function load_settings()
        local manager = require("lua_ls").addon_manager
        local new_settings = neoconf.get("lspconfig.lua_ls")
        new_settings = utils.flatten(new_settings or {})
        local addonSetting = vim.tbl_get(new_settings, "Lua", "addonManager")
        if addonSetting then
            manager:set_setting(addonSetting)
        end
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
