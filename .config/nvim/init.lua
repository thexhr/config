-------------------------------------------------------------------------------
-- Neovim config - https://github.com/thexhr/config
--
-- MISC CONFIGURATIONS
-------------------------------------------------------------------------------

vim.o.backup = false 			-- No backup files
vim.o.swapfile = false			-- No swap files
vim.o.modeline = false			-- No modeline
vim.o.ignorecase = true			-- Ignore cases when searching
vim.o.smartcase = true			-- Ignore uppercase except for search
vim.o.tabstop = 4				-- 4 chars tab
vim.o.shiftwidth = 4			-- Also 4 for indent
vim.o.number = true				-- Show line number
vim.o.relativenumber = true		-- Relative line numbers
vim.o.cursorline = true			-- Show cursor line
vim.o.showmatch = true			-- Show matching bracket
vim.o.undolevels = 200			-- Reduce undo levels
vim.o.mouse = ''				-- Disable mouse actions
vim.o.synmaxcol = 300			-- Max column in which to search for syntax
vim.o.splitright = true			-- Vertical split to the right
vim.o.splitbelow = true			-- Horizontal split to the bottom
vim.o.history = 100				-- Remember N lines in history

-- Colorscheme settings
vim.o.termguicolors = true		-- 24bit TUI colors
vim.cmd [[colorscheme moonfly]]
vim.g.lightline = {
  colorscheme = 'moonfly',
}

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

-------------------------------------------------------------------------------
-- KEYBINDINGS
-------------------------------------------------------------------------------

-- Y yank the whole line
vim.api.nvim_set_keymap('n', 'Y', '^y$', { noremap = true })

-- Disable search highlights with space
vim.keymap.set('n', '<space>', '<cmd>noh<cr>', {desc = 'Disable highlight'})

-- My backslash key combos
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

-- Stay in visual mode when indeting lines
vim.keymap.set('x', '<', '<gv', {desc = ''})
vim.keymap.set('x', '>', '>gv', {desc = ''})

-- F2 for toggling paste mode
vim.keymap.set('n', '<F2>', '<cmd>set invpaste paste?<cr>', {desc = ''})

-------------------------------------------------------------------------------
-- PLUGINS
-------------------------------------------------------------------------------

require "paq" {
	"savq/paq-nvim";				-- Let Paq manage itself
	'bluz71/vim-moonfly-colors';	-- Color scheme
	'itchyny/lightline.vim';		-- Status line
	'neovim/nvim-lspconfig';		-- Configs for LSP client
	'hrsh7th/cmp-nvim-lsp';			-- nvim-cmp source for neovim's built-in LSP
	'hrsh7th/nvim-cmp';				-- completion engine plugin for neovim
	'saadparwaiz1/cmp_luasnip';		-- luasnip completion source for nvim-cmp
	'L3MON4D3/LuaSnip';				-- Snippet Engine for Neovim written in Lua
}

-- luasnip setup
luasnip = require 'luasnip'

-------------------------------------------------------------------------------
-- LSP settings from https://tkg.codes/guide-to-modern-neovim-setup-2021/
-------------------------------------------------------------------------------

local nvim_lsp = require 'lspconfig'
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
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>so', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], opts)
  vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
end

-- nvim-cmp supports additional completion capabilities.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Enable the following language servers. If you ever find yourself needing
-- another programming language support, you'll have to find its LSP, add 
-- it to this list and make sure it is installed in your system!
local servers = { 'clangd', 'rust_analyzer', 'pyright', 'tsserver', 'gopls' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

-- Make runtime files discoverable to the server.
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

-- Set completeopt to have a better completion experience.
vim.o.completeopt = 'menuone,noselect'

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

