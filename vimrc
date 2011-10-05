" This configuration is based on the example vimrc included with Arch Linux,
" the Vim Tips Wiki, and the vimrc file Ben Breedlove sent me to look at.
" (Thanks, Ben!)

" Enable Vim improvements at the expense of losing full vi compatibility.
set nocompatible

" Disable swap files. (Not sure if this is wise or not.)
set noswapfile

" Set display options.
set lazyredraw
set showcmd
set laststatus=2
set ruler
set number
set numberwidth=5
set wildmenu
if exists("&colorcolumn")
  set colorcolumn=+2
endif
set linebreak
set scrolloff=4

" Give us a big command history.
set history=999

" Make backspace act normally.
set backspace=indent,eol,start

" Make indentation and wrapping behave in a civilized manner.
set autoindent
set expandtab
set smarttab

set tabstop=2
set shiftwidth=2

set textwidth=78

" Make indentation smarter.
if has("smartindent")
  set smartindent
endif

" Set up custom key bindings.
" See also: <http://stackoverflow.com/q/726920/152208>
" See also: <http://vimcasts.org/episodes/creating-colorschemes-for-vim/>
command W w !sudo tee % >/dev/null

let mapleader=","
let maplocalleader=","

nnoremap <silent> <Leader><Leader> :nohlsearch<CR>
nnoremap <silent> <Leader>s :set spell!<CR>

noremap <silent> <Leader><Space> :EraseBadWhitespace<CR>
nmap <silent> <Leader>cc <Plug>RefreshColorScheme
nmap <silent> <Leader>ch <Plug>HexHighlightToggle
nmap <silent> <Leader>cr <Plug>HexHighlightRefresh
noremap <silent> <Leader>cs :echo map(synstack(line("."), col(".")),
      \ 'synIDattr(v:val, "name")')<CR>

" Load plugins 'n' stuff with Pathogen.
if !has("python")
  let g:pathogen_disabled=["blogit"]
end

set runtimepath+=~/.vim/bundle/pathogen
set runtimepath+=~/_vim/bundle/pathogen
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

" Customize the UltiSnips search path to avoid default snippets.
let g:UltiSnipsSnippetDirectories=["snippets"]

" Enable settings specific to various file formats.
filetype on
filetype plugin on
filetype indent on

let g:tex_flavor="latex"
let g:tex_stylish=1

" Configure the LaTeX Box plugin.
let g:LatexBox_latexmk_options="-pvc"

" Tweak the indentation and wrapping settings a bit for certain file formats.
if has("autocmd")
  autocmd FileType css        setlocal tabstop=4 shiftwidth=4 textwidth=100
  autocmd FileType haskell    setlocal tabstop=4 shiftwidth=4
  autocmd FileType html       setlocal tabstop=4 shiftwidth=4 textwidth=0
  autocmd FileType java       setlocal tabstop=4 shiftwidth=4 textwidth=100
  autocmd FileType javascript setlocal tabstop=4 shiftwidth=4 textwidth=100
  autocmd FileType markdown   setlocal tabstop=4 shiftwidth=4 textwidth=0
  autocmd FileType php        setlocal tabstop=4 shiftwidth=4 textwidth=100
  autocmd FileType python     setlocal tabstop=4 shiftwidth=4
  autocmd FileType sql        setlocal tabstop=4 shiftwidth=4 textwidth=100
  autocmd FileType tex        setlocal                        textwidth=0
endif

" Enable fancy search settings.
if has("extra_search")
  set incsearch
  set hlsearch
endif

" Enable mouse support.
if has("mouse")
  set mouse=a
  set mousefocus
endif

" Enable syntax highlighting.
if has("syntax") && (&t_Co > 2 || has("gui_running"))
  syntax on
endif

" Set a custom dictionary for spell checking, and enable bad word by default.
if has("spell")
  set spellfile=~/.vim/spellfile.add
  set spell
endif

if has("gui_running")
  " Make the default gVim Window larger.
  set lines=50
  set columns=132

  " Kill off the gVim toolbar and scrollbar, and fix the tear-off menus.
  " See also: <http://vim.wikia.com/wiki/Hide_toolbar_or_menus_to_see_more_text>
  set guioptions-=t
  set guioptions-=T
  set guioptions-=r

  " Set a pretty font. :) To make things a bit more cross-platform, we
  " actually specific several fonts: a primary and a few fallbacks.
  " See also: <http://vim.wikia.com/wiki/Setting_the_font_in_the_GUI>.
  if has("gui_gtk2")
    set guifont=Envy\ Code\ R\ 10
    set guifont+=Consolas\ 10
    set guifont+=DejaVu\ Sans\ Mono\ 10
    set guifont+=Courier\ New\ 10
  else
    set guifont=Envy_Code_R:h10:cDEFAULT
    set guifont+=Consolas:h10:cDEFAULT
    set guifont+=DejaVu_Sans_Mono:h10:cDEFAULT
    set guifont+=Courier_New:h10:cDEFAULT
  endif
endif

" Set a nice color scheme.
if has("gui_running") || &t_Co >= 88
  colorscheme abbott
endif
