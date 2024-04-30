local popup = {}

local size = function(max, value)
    return value > 1 and math.max(max, value) or math.floor(value * max)
end

local function create_buf()
    local config = require("luals").config
    local bufnr = vim.api.nvim_create_buf(false, true)

    -- vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].swapfile = false
    vim.bo[bufnr].textwidth = 0
    vim.bo[bufnr].buftype = "nofile"
    vim.bo[bufnr].bufhidden = "wipe"
    vim.bo[bufnr].buflisted = false
    vim.bo[bufnr].filetype = "LLSAddonManager"
    vim.bo[bufnr].undolevels = -1
    return bufnr
end

local function create_win(bufnr)
    local config = require("luals").config
    local win_config = {
        relative = "editor",
        title = "Lua language server's addons manager",
        border = "none",
    }

    win_config.width = size(vim.o.columns, config.ui.size.width)
    win_config.height = size(vim.o.lines, config.ui.size.height)
    win_config.row = math.floor((vim.o.lines - win_config.height) / 2)
    win_config.col = math.floor((vim.o.columns - win_config.width) / 2)
    local win = vim.api.nvim_open_win(bufnr, true, win_config)

    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].wrap = false
    vim.wo[win].spell = false
    vim.wo[win].foldenable = false
    vim.wo[win].signcolumn = "no"
    vim.wo[win].colorcolumn = ""
    vim.wo[win].cursorline = true
end

function popup.open()
    local bufnr = create_buf()
    local win = create_win(bufnr)
    ---TODO:support flow window like mason.nvim or lazy.nvim
    vim.api.nvim_buf_set_text(bufnr, 0, 0, 0, 0, { "TODO.." })
end

return popup
