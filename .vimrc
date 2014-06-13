"autocmd BufRead ~/mail/mutt*      :source ~/.vimrc_mail

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" taglist plugin
"Toggle Tag list
nnoremap <silent> <F4> :TlistToggle<CR>
let Tlist_Exist_OnlyWindow = 1 " if you are the last, kill yourself
"let Tlist_Use_Right_Window = 1 " split to the right side of the screen
let Tlist_GainFocus_On_ToggleOpen = 1 " Jump to taglist window on open.
let Tlist_File_Fold_Auto_Close = 1

" turn off blinking cursor
set gcr=n:blinkon0

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

" 4 space tabstops
set tabstop=4
set softtabstop=4

" Wrap search around
set wrapscan

" Show line numbers
set number

" Hide the toolbar:
set go-=T

" rebuild cscope and tags db in current directory
map <C-X> <ESC>:!exctags -R<CR><CR>:!cscope -kcbqR<CR><CR>
map <C-Y> <ESC>:!exctags -R<CR><CR>
map <C-A> <ESC>:cs add ./cscope.out

set hlsearch
set showmatch
set errorformat=%A%f:%l:\ %m,%-Z%p^,%-C%.%#
filetype plugin on
filetype indent on
set laststatus=2

"set smartindent
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

syntax on
set ruler

autocmd BufNewFile,BufRead ferm.conf setf ferm
autocmd BufNewFile,BufRead *.ferm setf ferm
