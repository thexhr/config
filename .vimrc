"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Lot of stuff is from the Internetz, especially from
" https://github.com/s3rvac/dotfiles/blob/master/vim/.vimrc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vundle config
set nocompatible              " be iMproved, required
filetype off                  " required
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" My collection of vim plugins
Plugin 'junegunn/goyo.vim'
Plugin 'bling/vim-airline'
Plugin 'rking/ag.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Use j/k to move virtual lines instead of physical ones
noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')
" Stay in visual mode when indenting. You will never have to run gv after
" performing an indentation.
vnoremap < <gv
vnoremap > >gv

" Make Ctrl-e jump to the end of the current line in the insert mode. This is
" handy when you are in the middle of a line and would like to go to its end
" without switching to the normal mode.
inoremap <C-e> <C-o>$

" taglist plugin
"Toggle Tag list
nnoremap <silent> <F4> :TlistToggle<CR>
let Tlist_Exist_OnlyWindow = 1 " if you are the last, kill yourself
"let Tlist_Use_Right_Window = 1 " split to the right side of the screen
let Tlist_GainFocus_On_ToggleOpen = 1 " Jump to taglist window on open.
let Tlist_File_Fold_Auto_Close = 1


" Hitting space in normal/visual mode will make the current search disappear.
noremap <silent> <Space> :silent nohlsearch<CR>

" Disable arrows keys (I use exclusively h/j/k/l).
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>
inoremap <Up> <Nop>
inoremap <Down> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>

function! s:JoinWithoutSpaces()
	normal! gJ
	" Remove any whitespace.
	if matchstr(getline('.'), '\%' . col('.') . 'c.') =~ '\s'
		normal! dw
	endif
endfunction
noremap <silent> J :call <SID>JoinWithoutSpaces()<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible        " Disable vi compatibility.
set undolevels=200      " Number of undo levels.
set ttyfast             " Improves redrawing for newer computers.
set nobackup            " Disable backup files.
set noswapfile          " Disable swap files.

" Splitting.
set splitright          " Open new vertical panes in the right rather than left.
set splitbelow          " Open new horizontal panes in the bottom rather than top.

set secure              " Forbid loading of .vimrc under $PWD.
set nomodeline          " Modelines have been a source of vulnerabilities.

set autoindent          " Indent a new line according to the previous one.
set copyindent          " Copy (exact) indention from the previous line.
set nopreserveindent    " Do not try to preserve indention when indenting.
set nosmartindent       " Turn off smartindent.
set nocindent           " Turn off C-style indent.
set fo+=q               " Allow formatting of comments with "gq".
set fo-=r fo-=o         " Turn off automatic insertion of comment characters.
set fo+=j               " Remove a comment leader when joining comment lines.

set gcr=n:blinkon0		" turn off blinking cursor

" Whitespace.
set tabstop=4           " Number of spaces a tab counts for.
set shiftwidth=4        " Number of spaces to use for each step of indent.
set shiftround          " Round indent to multiple of shiftwidth.
set noexpandtab         " Do not expand tab with spaces.

set wrapscan			" Wrap search around

set go-=T				 " Hide the toolbar:

" Searching.
set hlsearch            " Highlight search matches.
set incsearch           " Incremental search.
" Case-smart searching (make /-style searches case-sensitive only if there
" is a capital letter in the search expression).
set ignorecase
set smartcase
" When editing a file, always jump to the last cursor position
au BufReadPost *
	\ if ! exists("g:leave_my_cursor_position_alone") |
	\     if line("'\"") > 0 && line ("'\"") <= line("$") |
	\         exe "normal g'\"" |
	\     endif |
	\ endif

set statusline=%<%1*(%M%R)%f(%F)%=\ [%n]%1*%-19(%2*\ %03lx%02c(%p%%)\ %1*%)%O'%3*%02b%1*'
" now set it up to change the status line based on mode
au InsertEnter * hi User1 term=inverse,bold ctermbg=darkblue ctermfg=cyan guibg=#18163e guifg=grey
au InsertLeave * hi User1 term=inverse,bold ctermbg=cyan ctermfg=darkblue guibg=grey guifg=#0d0c22

" Toggle copy and paste modus with <F2>
nnoremap <F2> :set invpaste paste?<CR>
imap <F2> <C-O><F2>
set pastetoggle=<F2>

colorscheme vombatidae
" set color scheme for GUI mode
if has("gui_running")
		set guifont=Monospace\ 10  " use this font
		set lines=30       " height = 50 lines
		set columns=100        " width = 100 columns
		"set selectmode=key,cmd
		"set keymodel=
		colorscheme torte
endif
" forget current search term
nmap <silent> <C-n> :noh<CR>

" rebuild cscope and tags db in current directory
map <C-X> <ESC>:!exctags -R<CR><CR>:!cscope -kcbqR<CR><CR>
map <C-Y> <ESC>:!exctags -R<CR><CR>
map <C-A> <ESC>:cs add ./cscope.out

set showmatch
set errorformat=%A%f:%l:\ %m,%-Z%p^,%-C%.%#
filetype plugin on
filetype indent on
set laststatus=2

" set dark background
set bg=dark
syntax on
set ruler
autocmd BufNewFile,BufRead COMMIT_EDITMSG set filetype=gitcommit
map <F6> <Esc>:setlocal spell spelllang=en<CR>
map <F7> <Esc>:setlocal nospell<CR>
setlocal spell spelllang=en
set spellfile=~/.vim/spellfile.add
set bg=dark 
set wildmenu

" Absatz auf textwidth runterbrechen
map <Esc>a gqap
" Ganzes Dokument auf textwidth runterbrechen
map <Esc>q gggqG

hi SpellBad term=reverse ctermfg=white ctermbg=darkred guifg=#ffffff guibg=#7f0000 gui=underline
"hi SpellCap guifg=#ffffff guibg=#7f007f
"hi SpellRare guifg=#ffffff guibg=#00007f gui=underline
hi SpellLocal term=reverse ctermfg=black ctermbg=darkgreen guifg=#ffffff guibg=#7f0000 gui=underline

" Rechtschreibkorrektur mit <esc>-l zwischen en und de umschalten
let langcnt = 0 
let spellst = ["de", "en"] 
function Sel_lang() 
  let g:langcnt = (g:langcnt+1) % len(g:spellst)
  let lang = g:spellst[g:langcnt] 
  echo "language " . lang . " selected" 
  exe "set spelllang=" . lang
  exec "set spell" 
endfunction 
nmap <Esc>l  :call Sel_lang()<CR> 
" spell checking off by default
set nospell

nmap <Esc>o	:set bg=dark<CR>
nmap <Esc>p	:set bg=light<CR>

" Use silver_searcher with Ack
if executable('ag')
	let g:ackprg = 'ag --vimgrep'
endif

syntax on
set ruler

autocmd BufNewFile,BufRead ferm.conf setf ferm
autocmd BufNewFile,BufRead *.ferm setf ferm

hi mailHeader      ctermfg=Gray
hi mailSubject     ctermfg=Red
hi mailEmail       ctermfg=Blue
hi mailSignature   ctermfg=DarkRed
hi mailQuoted1     ctermfg=Darkyellow
hi mailQuoted2     ctermfg=Green

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Show line numbers
set number
" Show relative number
set relativenumber

function! NumberToggle()
	if(&relativenumber == 1)
		set number
	else
		set relativenumber
	endif
endfunc

nnoremap <C-n> :call NumberToggle()<cr>

