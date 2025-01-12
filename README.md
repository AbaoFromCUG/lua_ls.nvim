# Introduction

`luals-addonmanager.nvim` is a neovim plugin provide [Addon management capability](https://luals.github.io/wiki/addons/#addon-manager) for [lua language server](https://github.com/luals/lua-language-server)

![show case](./doc/luassert_and_busted.png)


# Installation

- With 💤lazy.nvim:

```lua
{
    "AbaoFromCUG/luals-addonmanager.nvim",
    event = "VeryLazy",
    opts= {
        enable = true,
        addons = {
            "nvim",
            "luassert",
            "nvim-lspconfig",
        }

    }
}
```

Supported addons

- [x] Neovim plugins
- [x] Install from [LLS-Addons](https://github.com/LuaLS/LLS-Addons) automatically
- [x] Local addon
- [x] Remote addon

# Integration


## [Neoconf](https://github.com/folke/neoconf.nvim)

`luals-addonmanager.nvim` support neoconf, like it's a native settings supported by lua language server

`.neoconf.json`

```
{
  "lspconfig": {
    "lua_ls": {
      "Lua.addonManager.addons": [
        "nvim-full",
        "nvim",
        "nvim-lspconfig",
        "luassert",
        "busted"
      ]
    }
  }
}
```
