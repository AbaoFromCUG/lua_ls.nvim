# Lua Language Server

## Introduction

`lua_ls.nvim` a wrapper of [lua language server](https://github.com/luals/lua-language-server)

![show case](./doc/luassert_and_busted.png)

## Features 🌟
- Addon Manager
  - [x] install addon automatically
  - [x] local addon
  - [x] remote addon
  - [ ] UI
  - [ ] support nvim library as addon




## Installation
**NOTICE:**
* Dependent on `nvim-lspconfig.nvim`
* It is a substitute for `require("lspconfig").lua_ls.setup({})`

lazy.nvim

```lua
{
    "AbaoFromCUG/lua_ls.nvim",
    ---@type lua_ls.Config
    config = {
        settings={
            addonManager={
                addons={
                    "luassert",
                    "busted"
                }
            }
        }
    },
    ft = { "lua" },
    dev = true,
},
```


## Third-part integrations

### [Neoconf](https://github.com/folke/neoconf.nvim)


Reference to [neoconf.json](./.neoconf.json)
