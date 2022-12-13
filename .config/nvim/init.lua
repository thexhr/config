-------------------------------------------------------------------------------
-- Neovim config - https://github.com/thexhr
--
-- MISC CONFIGURATION
-------------------------------------------------------------------------------

vim.o.backup = false 			-- No backup files
vim.o.swapfile = false			-- No swap files
vim.o.modeline = false			-- No modeline
vim.o.ignorecase = true			-- Ignore cases when searching
vim.o.smartcase = true			-- Ignore uppercase except for search
vim.o.tabstop = 4				-- 4 chars tab
vim.o.shiftwidth = 4			-- Also 4 for indent
vim.o.relativenumber = true		-- Relative line numbers
vim.o.cursorline = true			-- Show cursor line
vim.o.termguicolors = true		-- 24bit TUI colors
vim.o.showmatch = true			-- Show matching bracket

vim.cmd("colorscheme tokyonight-night")

-------------------------------------------------------------------------------
-- KEYBINDINGS
-------------------------------------------------------------------------------

vim.keymap.set('n', '<space>', '<cmd>noh<cr>', {desc = 'Disable highlight'})

vim.keymap.set('n', '<Bslash>s', '<cmd>write<cr>', {desc = 'Save'})
vim.keymap.set('n', '<Bslash>q', '<cmd>quitall<cr>',
	{desc = 'Quit all windows'})
vim.keymap.set('n', '<Bslash>r', '<cmd>source %<cr>',
	{desc = 'Reload config'})

-- Tab handling
vim.keymap.set('n', '<leader>t', '<cmd>tabnew<cr>', {desc = 'Open new tab'})
vim.keymap.set('n', '<leader>w', '<cmd>tabclose<cr>', {desc = 'Close tab'})
vim.keymap.set('n', '{', '<cmd>tabprevious<cr>', {desc = 'Prev tab'})
vim.keymap.set('n', '}', '<cmd>tabnext<cr>', {desc = 'Next tab'})

-- Move up/down virtual lines and not real lines
vim.api.nvim_set_keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'",
	{ noremap = true, expr = true, silent = true})
vim.api.nvim_set_keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'",
	{ noremap = true, expr = true, silent = true})

-- Disable arrow keys in normal mode
vim.keymap.set('n', '<Up>', '<Nop>', {desc = 'Disable up key'})
vim.keymap.set('n', '<Down>', '<Nop>', {desc = 'Disable down key'})
vim.keymap.set('n', '<Left>', '<Nop>', {desc = 'Disable left key'})
vim.keymap.set('n', '<Right>', '<Nop>', {desc = 'Disable right key'})

-------------------------------------------------------------------------------
-- PLUGINS
-------------------------------------------------------------------------------

require "paq" {
	"savq/paq-nvim";				-- Let Paq manage itself
	"folke/tokyonight.nvim";		-- Color scheme
	"nvim-lualine/lualine.nvim";	-- Lua status line
}

require('lualine').setup()			-- Start lua line
