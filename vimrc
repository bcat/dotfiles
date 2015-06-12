" This configuration is based on the example vimrc included with Arch Linux,
" the Vim Tips Wiki, and the vimrc file Ben Breedlove sent me to look at.
" (Thanks, Ben!)

" Enable Vim improvements at the expense of losing full vi compatibility.
set nocompatible

" Disable swap files. Vim almost never crashes, and they clutter up directories.
set noswapfile

" Allow modified buffers to live in the background.
set hidden

" Make the ~ (switch case) command accept movement like a real operator.
set tildeop

" Don't redraw the screen during macro execution (big speedup for slow terms).
set lazyredraw

" Show line numbers.
set number
set numberwidth=5

" Prefer to break lines at punctuation when soft wrapping.
set linebreak

" Keep a minimum of four lines and eight columns visible around the cursor.
set scrolloff=4
set sidescrolloff=8

" Don't show the stupid preview window for completions, and narrow down
" available completions as characters are typed.
set completeopt=menu,longest

" Uses spaces for indentation by default. (Overridden for some languages below.)
set expandtab

" Use two-space tabs by default. (Overridden for some languages below.)
"
" It'd be nice to just set shiftwidth=0 so plugins calling shiftwidth() would
" automatically take the value from tabstop; however, this isn't even respected
" by all the standard indent plugins as of Vim 7.4.622. :(
set tabstop=2
set shiftwidth=2

" Wrap files at 80 characters by default. (Overridden for some languages below.)
set textwidth=80

" For buffers where textwidth is nonzero, show a right-margin two characters
" *after* the wrapping point. Not available before Vim 7.3.
if exists('&colorcolumn')
  set colorcolumn=+2
endif

if has('autocmd')
  " Don't list quickfix buffer, and don't wrap it or show a right margin.
  autocmd FileType qf setlocal nobuflisted textwidth=0

  " Set C/C++ indentation to match Google C++ style:
  " http://google.github.io/styleguide/cppguide.html.
  autocmd FileType cpp setlocal cinoptions+=l1,g1,h1,N-s,(0,j1

  " Set Haskell indentation to match XMonad coding style:
  " http://xmonad.org/xmonad-docs/xmonad-contrib/XMonad-Doc-Developing.html.
  autocmd FileType haskell setlocal tabstop=4 shiftwidth=4

  " Wrap HTML files at 100 characters to match common conventions.
  autocmd FileType html setlocal textwidth=100

  " Set Go indentation and disable wrapping to match Go style:
  " http://golang.org/doc/effective_go.html.
  autocmd FileType go setlocal noexpandtab tabstop=8 shiftwidth=8 textwidth=0

  " Wrap Java files at 100 chars to match Google Java style:
  " http://google.github.io/styleguide/javaguide.html.
  autocmd FileType java setlocal textwidth=100

  " Set Markdown indentation to match syntactic requirements:
  " http://daringfireball.net/projects/markdown/syntax.
  autocmd FileType markdown setlocal tabstop=4 shiftwidth=4

  " Set PHP indentation to match Zend Framework coding standard:
  " http://framework.zend.com/manual/1.12/en/coding-standard.html.
  autocmd FileType php setlocal tabstop=4 shiftwidth=4

  " Use C-style indentation for protocol buffer definitions.
  autocmd FileType proto setlocal cindent

  " Set Python indentation to match Google Python style:
  " http://google.github.io/styleguide/pyguide.html.
  autocmd FileType python setlocal tabstop=4 shiftwidth=4

  " Disable wrapping for TeX to allow one line per sentence for clean diffs.
  autocmd FileType tex setlocal textwidth=0

  " Highlight Google Apps Script source files as JavaScript.
  autocmd BufNewFile,BufRead *.gs setlocal filetype=javascript

  " Highlight Blaze/Bazel build system stuff as Python.
  autocmd BufNewFile,BufRead BUILD setlocal filetype=python
  autocmd BufNewFile,BufRead build_defs setlocal filetype=python
endif

" Configure the standard Python plugin.
let g:pyindent_open_paren = 'exists("*shiftwidth") ? shiftwidth() : &shiftwidth'

" Configure the standard TeX plugin.
let g:tex_indent_and = 0
let g:tex_flavor = 'latex'
let g:tex_stylish = 1

" Configure the standard Vim plugin.
let g:vim_indent_cont = 4

" Configure the Eclim plugin.
let g:EclimBuffersDefaultAction = 'edit'
let g:EclimDefaultFileOpenAction = 'edit'
let g:EclimJavaCallHierarchyDefaultAction = 'edit'
let g:EclimJavaHierarchyDefaultAction = 'edit'
let g:EclimLocateFileDefaultAction = 'edit'
let g:EclimLoggingDisabled = 1
let g:EclimProjectTreeExpandPathOnOpen = 1
let g:EclimPythonValidate = 0
let g:EclimTempFilesEnable = 0

" Configure the haskell-vim plugin.
let g:haskell_indent_case = 5
let g:haskell_indent_in = 0

" Configure the LaTeX Box plugin.
let g:LatexBox_latexmk_options = '-pvc'

" Enable fancy search settings.
if has('extra_search')
  set hlsearch
endif

" Set a custom dictionary for spell checking, enabling bad word highlighting by
" default, but don't check spelling in quickfix windows, 'cause that's silly.
if has('spell')
  set spellfile=~/.vim/spellfile.add
  set spell

  if has('autocmd')
    autocmd FileType qf setlocal nospell
  endif
endif

if has('mouse')
  " Enable mouse support for GUI Vim and terminal Vim (if supported).
  set mouse=a
  set mousefocus

  " urxvt implements a nonstandard mouse protocol (1015).
  if &term =~# '^rxvt-unicode'
    set ttymouse=urxvt
  endif
endif

" GNU Screen and tmux support setting the window title, but don't declare that
" in their terminfo entry.
if &term =~# '^screen'
  set t_ts=]2;
  set t_fs=
endif

" Begin custom keybindings with the comma (,) key.
let mapleader = ','
let maplocalleader = ','

" Disable default mappings for the LustyExplorer and LustyJuggler plugins to
" avoid conflicts with LaTeX Box.
let g:LustyExplorerDefaultMappings = 0
let g:LustyJugglerDefaultMappings = 0

" Configure keybindings for basic editor functionality:
"
" ,,        Clear search highlight
" ,s        Toggle spell checker
" ,<Space>  Remove trailing whitespace
nnoremap <silent> <Leader><Leader> :nohlsearch<CR>
nnoremap <silent> <Leader>s :set spell!<CR>
noremap <silent> <Leader><Space> :EraseBadWhitespace<CR>

" Configure keybindings for working with color schemes:
"
" ,cc       Reload current color scheme
" ,ch       Highlight hexadecimal colors
" ,cr       Reload hexadecimal color highlights
" ,cs       Show highlight groups for character under the cursor
"
" (See also http://vimcasts.org/episodes/creating-colorschemes-for-vim/.)
nmap <silent> <Leader>cc <Plug>RefreshColorScheme
nmap <silent> <Leader>ch <Plug>HexHighlightToggle
nmap <silent> <Leader>cr <Plug>HexHighlightRefresh
noremap <silent> <Leader>cs
    \ :echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')<CR>

" Configure keybindings for LustyJuggler plugin:
"
" ,aj       LustyJuggler: Open quick buffer chooser
nnoremap <silent> <Leader>aj :LustyJuggler<CR>

" Configure keybindings for LustyExplorer plugin:
"
" ,ab       Open buffer chooser
" ,af       Open file chooser in working directory
" ,ag       Open buffer contents search tool
" ,ar       Open file chooser relative to file in current buffer
nnoremap <silent> <Leader>ab :LustyBufferExplorer<CR>
nnoremap <silent> <Leader>af :LustyFilesystemExplorer<CR>
nnoremap <silent> <Leader>ag :LustyBufferGrep<CR>
nnoremap <silent> <Leader>ar :LustyFilesystemExplorerFromHere<CR>

" Configure keybindings for Eclim plugin:
"
" ,ea       Open or close buffer with tree view of current project
" ,ee       Search project for source element under the cursor
" ,ef       Open fuzzy search tool for Java classes, source files, etc.
" ,eh       Open Java call hierarchy for method under cursor
" ,eo       Remove unused Java imports and organize remaining imports
" ,ep       Show compilation errors in quickfix buffer
nnoremap <silent> <Leader>ea :ProjectTreeToggle<CR>
nnoremap <silent> <Leader>ee :JavaSearchContext<CR>
nnoremap <silent> <Leader>ef :LocateFile<CR>
nnoremap <silent> <Leader>eh :JavaCallHierarchy<CR>
nnoremap <silent> <Leader>eo :JavaImportOrganize<CR>
nnoremap <silent> <Leader>ep :ProjectProblems!<CR>

if has('gui_running')
  " Make the default gVim Window larger.
  set lines=50
  set columns=132

  " Kill off the gVim toolbar and scrollbar, and fix the tear-off menus.
  set guioptions-=m
  set guioptions-=L
  set guioptions-=r
  set guioptions-=t
  set guioptions-=T

  " Set a pretty font. :) To make things a bit more cross-platform, we
  " actually specify several fonts: a primary and a few fallbacks.
  if has('gui_gtk2')
    set guifont=GohuFont\ 11px
    set guifont+=Envy\ Code\ R\ 10
    set guifont+=Consolas\ 10
    set guifont+=DejaVu\ Sans\ Mono\ 10
    set guifont+=Courier\ New\ 10
  elseif has('gui_win32')
    set guifont=GohuFont:h8:cDEFAULT
    set guifont+=Envy_Code_R:h10:cDEFAULT
    set guifont+=Consolas:h10:cDEFAULT
    set guifont+=DejaVu_Sans_Mono:h10:cDEFAULT
    set guifont+=Courier_New:h10:cDEFAULT
  endif
endif

" Load plugins 'n' stuff with Pathogen. We do this at the end of the vimrc file
" since plugin code isn't actually executed by Vim until after vimrc completes.
runtime bundle/pathogen/autoload/pathogen.vim
call pathogen#infect()
call pathogen#helptags()

" Set a nice color scheme that behaves well on 8-, 88-, and 256-color terminals.
" Must be done after we call Pathogen since the color scheme lives in a bundle.
colorscheme abbott
