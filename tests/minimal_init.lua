local function add_dependence(url, name)
    local temp_dir = "/tmp/" .. name
    if vim.fn.isdirectory(temp_dir) == 0 then
        vim.fn.system({ "git", "clone", url, temp_dir })
    end
    vim.opt.rtp:append(temp_dir)
end

add_dependence("https://github.com/nvim-lua/plenary.nvim", "plenary.nvim")
add_dependence("https://github.com/neovim/nvim-lspconfig", "nvim-lspconfig")
-- add_dependence("https://github.com/nvim-neotest/nvim-nio", "nvim-nio")

vim.opt.rtp:append(".")

vim.cmd("runtime plugin/plenary.vim")
require("plenary.busted")
