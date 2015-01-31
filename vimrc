" This configuration is based on the example vimrc included with Arch Linux,
" the Vim Tips Wiki, and the vimrc file Ben Breedlove sent me to look at.
" (Thanks, Ben!)

" Enable Vim improvements at the expense of losing full vi compatibility.
set nocompatible

" Disable swap files. (Not sure if this is wise or not.)
set noswapfile

" Allow modified buffers to live in the background.
set hidden

" Make the ~ (switch case) command accept movement like a real operator.
set tildeop

" Set display options.
set lazyredraw
set number
set numberwidth=5
if exists("&colorcolumn")
  set colorcolumn=+2
  if has("autocmd")
    autocmd FileType qf setlocal colorcolumn=
  endif
endif
set linebreak
set scrolloff=4

" Don't show the stupid preview window for completions, and narrow down
" available completions as characters are typed.
set completeopt=menu,longest

" Make indentation and wrapping behave in a civilized manner.
set expandtab

set tabstop=2
set shiftwidth=2

set textwidth=80

" Make indentation smarter.
if has("smartindent")
  set smartindent
endif

" Set up custom key bindings.
" See also: <http://vimcasts.org/episodes/creating-colorschemes-for-vim/>
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

nnoremap <silent> <Leader>aj :LustyJuggler<CR>
nnoremap <silent> <Leader>af :LustyFilesystemExplorer<CR>
nnoremap <silent> <Leader>ar :LustyFilesystemExplorerFromHere<CR>
nnoremap <silent> <Leader>ab :LustyBufferExplorer<CR>
nnoremap <silent> <Leader>ag :LustyBufferGrep<CR>

nnoremap <silent> <Leader>ea :ProjectTreeToggle<CR>
nnoremap <silent> <Leader>ee :JavaSearchContext<CR>
nnoremap <silent> <Leader>ef :LocateFile<CR>
nnoremap <silent> <Leader>eh :JavaCallHierarchy<CR>
nnoremap <silent> <Leader>eo :JavaImportOrganize<CR>
nnoremap <silent> <Leader>ep :ProjectProblems!<CR>

" Load plugins 'n' stuff with Pathogen.
runtime bundle/pathogen/autoload/pathogen.vim
call pathogen#infect()
call pathogen#helptags()

" Customize the UltiSnips search path to avoid default snippets. We can't just
" call this directory "snippets" since that name is reserved for snipMate.
let g:UltiSnipsSnippetDirectories=["ultisnips"]

" Configure the LaTeX Box plugin.
let g:LatexBox_latexmk_options="-pvc"

" Disable default mappings for the LustyExplorer and LustyJuggler plugins to
" avoid conflicts with LaTeX Box.
let g:LustyExplorerDefaultMappings=0
let g:LustyJugglerDefaultMappings=0

" Configure the Eclim plugin.
let g:EclimBuffersDefaultAction="edit"
let g:EclimDefaultFileOpenAction="edit"
let g:EclimJavaCallHierarchyDefaultAction="edit"
let g:EclimJavaHierarchyDefaultAction="edit"
let g:EclimLocateFileDefaultAction="edit"
let g:EclimLoggingDisabled=1
let g:EclimProjectTreeExpandPathOnOpen=1
let g:EclimPythonValidate=0
let g:EclimTempFilesEnable=0

" Enable settings specific to various file formats.
let g:tex_indent_and=0
let g:tex_flavor="latex"
let g:tex_stylish=1

if has("autocmd")
  " Don't show quickfix in buffer listings.
  autocmd FileType qf setlocal nobuflisted

  " Tweak the indentation and wrapping settings a bit for certain file formats.
  autocmd FileType css        setlocal tabstop=2 shiftwidth=2 textwidth=80
  autocmd FileType haskell    setlocal tabstop=4 shiftwidth=4
  autocmd FileType html       setlocal tabstop=2 shiftwidth=2 textwidth=80
  autocmd FileType java       setlocal tabstop=2 shiftwidth=2 textwidth=100
  autocmd FileType markdown   setlocal tabstop=4 shiftwidth=4 textwidth=0
  autocmd FileType php        setlocal tabstop=4 shiftwidth=4 textwidth=100
  autocmd FileType python     setlocal tabstop=4 shiftwidth=4
  autocmd FileType sql        setlocal tabstop=4 shiftwidth=4 textwidth=100
  autocmd FileType tex        setlocal                        textwidth=0

  " Highlight Google Apps Script source files as JavaScript.
  autocmd BufNewFile,BufRead *.gs set filetype=javascript

  " Highlight build system stuff as Python.
  autocmd BufNewFile,BufRead BUILD set filetype=python
  autocmd BufNewFile,BufRead build_defs set filetype=python
endif

" Enable fancy search settings.
if has("extra_search")
  set hlsearch
endif

" Enable mouse support.
if has("mouse")
  set mouse=a
  set mousefocus
endif

" Set a custom dictionary for spell checking, enabling bad word highlighting by
" default, but don't check spelling in quickfix windows, 'cause that's silly.
if has("spell")
  set spellfile=~/.vim/spellfile.add
  set spell

  if has("autocmd")
    autocmd FileType qf setlocal nospell
  endif
endif

" GNU Screen and tmux support setting the window title, but don't declare that
" in their terminfo entry.
if &term =~ "^screen-\\?"
  set t_ts=]2;
  set t_fs=
endif

" urxvt implements a nonstandard mouse protocol (1015).
if &term =~ "^rxvt-unicode-\\?"
  set ttymouse=urxvt
endif

if has("gui_running")
  " Make the default gVim Window larger.
  set lines=50
  set columns=132

  " Kill off the gVim toolbar and scrollbar, and fix the tear-off menus.
  " See also: <http://vim.wikia.com/wiki/Hide_toolbar_or_menus_to_see_more_text>
  set guioptions-=m
  set guioptions-=L
  set guioptions-=r
  set guioptions-=t
  set guioptions-=T

  " Set a pretty font. :) To make things a bit more cross-platform, we
  " actually specify several fonts: a primary and a few fallbacks.
  " See also: <http://vim.wikia.com/wiki/Setting_the_font_in_the_GUI>.
  if has("gui_gtk2")
    set guifont=GohuFont\ 7
    set guifont+=Envy\ Code\ R\ 10
    set guifont+=Consolas\ 10
    set guifont+=DejaVu\ Sans\ Mono\ 10
    set guifont+=Courier\ New\ 10
  else
    set guifont=GohuFont:h10:cDEFAULT
    set guifont+=Envy_Code_R:h10:cDEFAULT
    set guifont+=Consolas:h10:cDEFAULT
    set guifont+=DejaVu_Sans_Mono:h10:cDEFAULT
    set guifont+=Courier_New:h10:cDEFAULT
  endif
endif

" Set a nice color scheme.
if has("gui_running") || &t_Co >= 88
  colorscheme abbott
endif
