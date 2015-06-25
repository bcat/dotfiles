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

" Keep the join and gq (format) commands from putting two spaces after periods.
set nojoinspaces

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

  " Set JavaScript indentation to match Google JavaScript style:
  " http://google.github.io/styleguide/javascriptguide.xml.
  autocmd FileType javascript setlocal cinoptions+=(0

  " Set Markdown indentation to match syntactic requirements:
  " http://daringfireball.net/projects/markdown/syntax.
  autocmd FileType markdown setlocal tabstop=4 shiftwidth=4

  " Set PHP indentation to match Zend Framework coding standard:
  " http://framework.zend.com/manual/1.12/en/coding-standard.html.
  autocmd FileType php setlocal tabstop=4 shiftwidth=4

  " Use C-style indentation for protocol buffer definitions.
  autocmd FileType proto setlocal cindent cinoptions+=(0

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

" If the Silver Search (Ag) is available, use it as a replacement for grep.
if executable('ag')
  set grepprg=ag\ --nocolor\ --nogroup\ --column\ $*\ /dev/null
  set grepformat=%f:%l:%c:%m
endif

" Turn off folding, which is obnoxious and which I never use.
if has('folding')
  set nofoldenable
endif

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

  " urxvt implements a nonstandard mouse protocol (1015) that supports faster
  " dragging and terminals wider than 223 columns, but Vim doesn't know this.
  if &term =~# '^rxvt-unicode'
    set ttymouse=urxvt
  endif

  " tmux implements an upgraded xterm mouse protocol (1006) that supports faster
  " dragging and terminals wider than 223 columns, but it doesn't implement that
  " xterm escape sequence that would allow Vim to autodetect this.
  if &term =~# '^screen' && !empty($TMUX)
    set ttymouse=sgr
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

" Configure keybindings for basic editor functionality:
"
" ,,        Clear search highlight
" ,r        Edit file relative to current directory
" ,s        Toggle spell checker
" ,<Space>  Remove trailing whitespace
nnoremap <silent> <Leader><Leader> :nohlsearch<CR>
nnoremap <silent> <Leader>r :e <C-R>=expand('%:p:~:h')<CR>/<C-D>
nnoremap <silent> <Leader>s :set spell!<CR>
noremap <silent> <Leader><Space> :EraseBadWhitespace<CR>

" Configure keybindings for working with color schemes:
"
" ,cc       Reload current color scheme
" ,cs       Show highlight groups for character under the cursor
"
" (See also http://vimcasts.org/episodes/creating-colorschemes-for-vim/.)
nmap <silent> <Leader>cc :execute "colorscheme" g:colors_name<CR>
noremap <silent> <Leader>cs
    \ :echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')<CR>

" Configure keybindings for CtrlP plugin:
"
" ,ab       Perform fuzzy buffer search by name
" ,af       Perform fuzzy file search for files starting in VCS root
" ,ag       Perform fuzzy buffer search by contents
" ,ar       Perform fuzzy file search for files starting in buffer's directory
nnoremap <silent> <Leader>ab :CtrlPBuffer<CR>
nnoremap <silent> <Leader>af :CtrlPRoot<CR>
nnoremap <silent> <Leader>ag :CtrlPLine<CR>
nnoremap <silent> <Leader>ar :CtrlP<CR>

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

" Load plugins 'n' stuff with Pathogen. We do this at the end of the vimrc file
" since plugin code isn't actually executed by Vim until after vimrc completes.
runtime bundle/pathogen/autoload/pathogen.vim
call pathogen#infect()
call pathogen#helptags()

" Enable configuration of Google plugins using Glaive (for no good reason).
call glaive#Install()

" Configure the standard Python plugin.
let g:pyindent_open_paren = 'exists("*shiftwidth") ? shiftwidth() : &shiftwidth'

" Configure the standard TeX plugin.
let g:tex_indent_and = 0
let g:tex_flavor = 'latex'
let g:tex_stylish = 1

" Configure the standard Vim plugin.
let g:vim_indent_cont = 4

" Configure the codefmt plugin. Enable its default mappings.
Glaive codefmt clang_format_style='Google' plugin[mappings]

" Configure the CtrlP plugin. Disable its default mapping.
let g:ctrlp_map = ''
let g:ctrlp_working_path_mode = 'c'
let g:ctrlp_root_markers = 'METADATA'
let g:ctrlp_open_new_file = 'r'
let g:ctrlp_open_multiple_files = 'h'

if executable('ag')
  let g:ctrlp_user_command = 'ag -g "" -l --hidden --nocolor %s'
endif

if exists('*pymatcher#PyMatch')
  let g:ctrlp_match_func = {'match': 'pymatcher#PyMatch'}
endif

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

" Set a nice color scheme that behaves well on 8-, 88-, and 256-color terminals.
" Must be done after we call Pathogen since the color scheme lives in a bundle.
colorscheme abbott
