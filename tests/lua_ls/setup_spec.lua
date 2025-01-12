---@type lua_ls
local lua_ls

describe("default config", function()
    before_each(function()
        lua_ls = require("luals-addonmanager")
    end)
    after_each(function()
        for name, _ in pairs(package.loaded) do
            if string.match(name, "^lua_ls.*") or string.match(name, "^lspconfig.*") then
                -- print("reset:", name)
                package.loaded["lua_ls"] = nil
            end
        end
    end)
    it("default config", function()
        lua_ls.setup()
        assert.are_nil(false)
    end)
    it("default config2", function()
        lua_ls.setup({})
    end)
end)
