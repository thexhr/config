-------------------------------------------------------------------------------
-- Neovim config - https://github.com/thexhr/config
--
-- MISC CONFIGURATIONS
-------------------------------------------------------------------------------

local set = vim.opt

set.backup = false 				-- No backup files
set.swapfile = false			-- No swap files
set.modeline = false			-- No modeline
set.ignorecase = true			-- Ignore cases when searching
set.smartcase = true			-- Ignore uppercase except for search
set.tabstop = 4					-- 4 chars tab
set.shiftwidth = 4				-- Also 4 for indent
set.autoindent = true			-- Indent automatically
set.number = true				-- Show line number
set.relativenumber = true		-- Relative line numbers
set.cursorline = true			-- Show cursor line
set.showmatch = true			-- Show matching bracket
set.undolevels = 200			-- Reduce undo levels
set.mouse = ''					-- Disable mouse actions
set.synmaxcol = 300				-- Max column in which to search for syntax
set.splitright = true			-- Vertical split to the right
set.splitbelow = true			-- Horizontal split to the bottom
set.history = 100				-- Remember N lines in history
set.spellsuggest = 'best,10'	-- Show the best 10 suggestions re spellcheck
set.showtabline = 2				-- Always show tab line
set.conceallevel = 2			-- Conceal text, e.g. for Markdown

-- File extensions to be ignored in wildmenu
set.wildignore = '*.o,*~,*.pyc,*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store'

-- Colorscheme settings
set.termguicolors = true		-- 24bit TUI colors
vim.cmd [[ colorscheme xhr3 ]]

vim.diagnostic.config({
	virtual_lines = true
})

-------------------------------------------------------------------------------
-- FUNCTIONS
-------------------------------------------------------------------------------

-- Highlight on yank (copy). It will do a nice highlight blink of the thing you
-- just copied.  From https://tkg.codes/guide-to-modern-neovim-setup-2021/
vim.api.nvim_exec(
  [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]],
  false
)

-- Show trailing whitespace
vim.fn.matchadd('errorMsg', [[\s\+$]])

-- When opening a file, always jump to the latest positions
vim.api.nvim_exec([[
    autocmd BufRead * autocmd FileType <buffer> ++once
      \ if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line("$")
	  \ | exe 'normal! g`"' | endif]],
false)

-- Don't show line numbers in the builtin terminal
vim.api.nvim_create_autocmd('TermOpen', {
	group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
	callback = function()
		vim.opt.number = false
		vim.opt.relativenumber = false
	end,
})

-- Enable spell checking
vim.g.spelllang=en,de
vim.keymap.set('n', '<F3>', '<cmd>set spell!<cr>', {desc = 'Set spell'})

-- Toggle between multiple languages for spell checking
vim.g.lang_c = 0
vim.g.lang_a = { 'de', 'en' }
function _G.ToggleLang()
	vim.g.lang_c = (vim.g.lang_c + 1) % #(vim.g.lang_a)
	-- Lua array indexes start with 1, so plus 1 here
	local i = vim.g.lang_c+1
	local sl = 'set spelllang='..vim.g.lang_a[i]
	vim.api.nvim_command('set spell')
	vim.api.nvim_command(sl)
	print("Spellcheck language is", vim.g.lang_a[i])
end

vim.keymap.set('n', '<Esc>l', '<cmd>lua ToggleLang()<cr>')

-------------------------------------------------------------------------------
-- KEYBINDINGS
-------------------------------------------------------------------------------

-- Enable C-A for the command line
vim.api.nvim_exec([[ cnoremap <C-A> <Home> ]], false)

-- Disable search highlights with space
vim.keymap.set('n', '<space>', '<cmd>noh<cr>', {desc = 'Disable highlight'})

-- My backslash key combos
vim.keymap.set('n', '<Bslash>s', '<cmd>write<cr>', {desc = 'Save'})
vim.keymap.set('n', '<Bslash>q', '<cmd>quitall<cr>',
	{desc = 'Quit all windows'})
vim.keymap.set('n', '<Bslash>w', '<cmd>quit<cr>',
	{desc = 'Quit current window'})
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

-- Stay in visual mode when indeting lines
vim.keymap.set('x', '<', '<gv', {desc = ''})
vim.keymap.set('x', '>', '>gv', {desc = ''})

-- F2 for toggling paste mode
vim.keymap.set('n', '<F2>', '<cmd>set invpaste paste?<cr>', {desc = ''})

-- Reformat paragraph or the whole document.  All content will be reduced to
-- match textwidth.
vim.keymap.set('n', '<Esc>a', 'gqap', { desc = 'Format paragraph on textwidth'})
vim.keymap.set('n', '<Esc>q', 'ggggG', { desc = 'Format all on textwidth'})

-- Allow to move selected lines in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Cursor remains at the same position when joining lines
vim.keymap.set("n", "J", "mzJ`z")

-- Screen recenters when searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Don't preserve the word the clipboard is pasted into
vim.keymap.set("v", "p", '"_dP')

-- Open a small terminal at the bottom, from TJ DeVries
vim.keymap.set('n', "<Bslash>st", function()
	vim.cmd.vnew()
	vim.cmd.term()
	vim.cmd.wincmd("J")
	vim.api.nvim_win_set_height(0, 10)
end)

-------------------------------------------------------------------------------
-- PLUGINS
-------------------------------------------------------------------------------

--[[ Paq bootstrap
git clone --depth=1 https://github.com/savq/paq-nvim.git \
    "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/paqs/start/paq-nvim
]]--

require "paq" {
	"savq/paq-nvim";				-- Let Paq manage itself
	'nvim-lualine/lualine.nvim';	-- Fancier statusline
	'neovim/nvim-lspconfig';		-- Configs for LSP client
	'hrsh7th/cmp-nvim-lsp';			-- nvim-cmp source for neovim's built-in LSP
	'hrsh7th/nvim-cmp';				-- completion engine plugin for neovim
	'saadparwaiz1/cmp_luasnip';		-- luasnip completion source for nvim-cmp
	'L3MON4D3/LuaSnip';				-- Snippet Engine for Neovim written in Lua
	'nvim-lua/plenary.nvim';		-- Telescope dependecy
	'nvim-telescope/telescope.nvim';-- Fast and fuzzy search
	'lewis6991/impatient.nvim';		-- Startup cache
}

require('impatient')

-- luasnip setup
luasnip = require 'luasnip'

require('lualine').setup {
	options = {
		icons_enabled = false,
		theme = 'onedark',
		component_separators = '|',
		section_separators = '',
	},
}

-------------------------------------------------------------------------------
-- Telescope config
-------------------------------------------------------------------------------

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fs', builtin.search_history, {})
vim.keymap.set('n', '<leader>fc', builtin.lsp_incoming_calls, {})
vim.keymap.set('n', '<leader>fr', builtin.lsp_references, {})
vim.keymap.set('n', '<leader>fi', builtin.lsp_implementations, {})
vim.keymap.set('n', '<leader>fd', builtin.lsp_definitions, {})
vim.keymap.set('n', '<leader>c', builtin.command_history, {})

-------------------------------------------------------------------------------
-- LSP settings from https://tkg.codes/guide-to-modern-neovim-setup-2021/
-------------------------------------------------------------------------------

local on_attach = function(_, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

-- Sets up all of the keybindings that we will need for navigating the code
-- and using features like getting documentation tooltips or quick actions.
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>x', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>so', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], opts)
  vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
end

-- Disable ESLint LSP server and hide virtual text in Neovim
-- from https://samuellawrentz.com/hacks/neovim/disable-annoying-eslint-lsp-server-and-hide-virtual-text/
local isLspDiagnosticsVisible = true
vim.keymap.set("n", "<leader>lx", function()
	isLspDiagnosticsVisible = not isLspDiagnosticsVisible
	vim.diagnostic.config({
		virtual_text = isLspDiagnosticsVisible,
		underline = isLspDiagnosticsVisible,
		virtual_lines = false
}) end)

-- nvim-cmp supports additional completion capabilities.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Enable the following language servers. If you ever find yourself needing
-- another programming language support, you'll have to find its LSP, add
-- it to this list and make sure it is installed in your system!
local servers = { 'clangd', 'rust_analyzer', 'pylsp', 'gopls' }
for _, lsp in ipairs(servers) do
  vim.lsp.enable(servers)
end

-- Make runtime files discoverable to the server.
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

-- Set completeopt to have a better completion experience.
set.completeopt = 'menuone,noselect'

------------------------------------------------------------------------------
-- nvim-cmp setup from https://tkg.codes/guide-to-modern-neovim-setup-2021/
------------------------------------------------------------------------------

local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<Up>'] = cmp.mapping.select_prev_item(),
    ['<Down>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
	-- If you don't set up snippets in the section below, this might crash,
	-- either go through the "Snippets" section or remove any `luasnip`
	-- related code from this config.
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

------------------------------------------------------------------------------
-- vim markdown setup from https://jdhao.github.io/2019/01/15/markdown_edit_preview_nvim/
------------------------------------------------------------------------------

-- disable header folding
vim.g.vim_markdown_folding_disabled = 1

-- disable math tex conceal feature
vim.g.tex_conceal = ""
vim.g.vim_markdown_math = 1

