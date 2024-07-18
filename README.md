# Lua Language Server

## Introduction

`lua_ls.nvim` a wrapper of [lua language server](https://github.com/luals/lua-language-server)

![show case](./doc/luassert_and_busted.png)

## Features 🌟

- Addon Manager
  - addon
    - [x] install [LLS-Addons](https://github.com/LuaLS/LLS-Addons) automatically
    - [x] local addon
    - [x] remote addon
  - neovim specific
    - [x] neovim runtime path
    - [x] neovim plugin(current `lazy.nvim` managed only)

## Installation

**NOTICE:**

- Dependent on `nvim-lspconfig.nvim`
- It is a substitute for `require("lspconfig").lua_ls.setup({})`

```lua
require("lua_ls").setup({
    settings = {
        Lua = {
            ---@type lua_ls.AddonManagerSetting
            addonManager = {
                enable = true,
                addons = {
                    "nvim",
                    "luassert",
                    "busted",
                    "nvim-lspconfig",
                },
            },
        },
    },
})
```

## Third-part integrations

### [Neoconf](https://github.com/folke/neoconf.nvim)

Reference to [neoconf.json](./.neoconf.json)
