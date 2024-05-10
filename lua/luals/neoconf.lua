local M = {}

function M.register()
    local manager = require("luals.addon_manager")
    local neoconf = require("neoconf")
    local default_settings = { addons = {} }
    local function load_settings()
        local addons = neoconf.get("luals.addons", {})
        for _, addon in ipairs(addons) do
            manager.enable(addon)
        end
    end
    require("neoconf.plugins").register({
        name = "luals",
        on_schema = function(schema)
            schema:set("luals", {
                description = "lua language server settings",
            })
            local addon_names = vim.tbl_map(function(addon)
                ---@cast addon luals.Addon
                return addon.display_name
            end, vim.tbl_values(manager.addons))

            schema:set("luals.addons", {
                description = "",
                type = "array",
                items = {
                    anyOf = {
                        {

                            type = "string",
                            enum = addon_names,
                        },
                        {
                            type = "string",
                        },
                    },
                },
            })
        end,
        on_update = function()
            load_settings()
        end,
    })

    load_settings()
end

return M
