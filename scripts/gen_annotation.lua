local utils = require("lua_ls.utils")

---@class schema.Property
---@field default any
---@field scope string
---@field type string
---@field enum? string string[]
---@field items? {enum: string[], type: string}
---@field markdownDescription string
---@field markdownEnumDescriptions? string[]

---@class schema.Setting
---@field description string
---@field title string
---@field type "object"
---@field properties schema.Property[]

---@class VSCode.Command
---@field command string
---@field title string

---@class VSCode.ExtensionConfig
---@field name string
---@field displayName string

local function main()
    vim.system({ "curl", "https://raw.githubusercontent.com/latex-lsp/texlab-vscode/master/package.json" }, { text = true }, function(out)
        assert(out.code == 0, out.stderr)
        ---@type schema.Setting
        local setting_schema = vim.json.decode(out.stdout)
        -- local field
        vim.iter(setting_schema.properties):each(function(property)
            ---@cast property schema.Property
        end)
    end):wait()
end
main()
