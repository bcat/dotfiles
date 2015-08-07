" This configuration is based on the example vimrc included with Arch Linux,
" the Vim Tips Wiki, and the vimrc file Ben Breedlove sent me to look at.
" (Thanks, Ben!)

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

" Open new windows below and to the right of existing ones.
set splitbelow
set splitright

" Maintain equal-sized windows when new windows are open or old ones closed.
set equalalways

" Don't show the stupid preview window for completions, and narrow down
" available completions as characters are typed. Also use Readline-style
" completion for the command line.
set completeopt=menu,longest
set wildmode=longest,list

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
  augroup vimrc
    autocmd!

    " Equalize window sizes when Vim is resized
    autocmd VimResized * wincmd =

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

    " Highlight Bazel build system stuff as Python.
    autocmd BufNewFile,BufRead BUILD setlocal filetype=python
    autocmd BufNewFile,BufRead build_defs setlocal filetype=python
  augroup END
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

" Enable fancy search settings. Don't set hlsearch if it's already set since
" this reverses the effects on :hlnosearch and forces highlighting the last
" search when the vimrc file is sourced.
if has('extra_search') && !&hlsearch
  set hlsearch
endif

" Set a custom dictionary for spell checking, enabling bad word highlighting by
" default, but don't check spelling in quickfix windows, 'cause that's silly.
if has('spell')
  set spellfile=~/.vim/spellfile.add
  set spell

  if has('autocmd')
    augroup vimrc_spell
      autocmd!
      autocmd FileType qf setlocal nospell
    augroup END
  endif
endif

if has('mouse')
  " Enable mouse support for GUI Vim and terminal Vim (if supported).
  set mouse=a
  set mousefocus

  " urxvt implements a nonstandard mouse protocol (1015) that supports faster
  " dragging and terminals wider than 223 columns, but Vim doesn't know this.
  if &term =~# '\v^rxvt-unicode%(-|$)'
    set ttymouse=urxvt
  endif

  " tmux implements an upgraded xterm mouse protocol (1006) that supports faster
  " dragging and terminals wider than 223 columns, but it doesn't implement the
  " xterm escape sequence that would allow Vim to autodetect this.
  if &term =~# '\v^screen%(-|$)' && !empty($TMUX)
    set ttymouse=sgr
  endif
endif

" Always allow Vim to set the window title even if the terminal can't report the
" old title to restore on exit since our shell prompt resets the title itself.
set title

" GNU Screen and tmux support setting the window title, but don't declare that
" in their terminfo entry.
if &term =~# '\v^screen%(-|$)'
  " Set window title start: OSC 2 ;
  let &t_ts = "\e]2;"

  " Set window title end:   BEL
  let &t_fs = "\7"
endif

" Set the cursor to a blinking underline when entering insert mode and restore
" it to a blinking block when leaving insert mode, if the terminal supports it.
" Additionally, enable bracketed paste mode if the terminal supports it.
if &term =~# '\v^%(rxvt-unicode|xterm)%(-|$)' ||
    \ &term =~# '\v^screen%(-|$)' && !empty($TMUX)
  " Start insert mode:
  "
  " Set cursor style to blinking underline: CSI 3 SP q
  " Set bracketed paste mode:               CSI ? 2 0 0 4 h
  let &t_SI = "\e[3 q\e[?2004h"

  " End insert mode:
  "
  " Reset bracketed paste mode:             CSI ? 2 0 0 4 l
  " Set cursor style to blinking block:     CSI 1 SP q
  let &t_EI = "\e[?2004l\e[1 q"

  " Map unused function keys for bracketed paste:
  "
  " Pasted text start:                      ESC [ 2 0 0 ~
  " Pasted text end:                        ESC [ 2 0 1 ~
  execute "set" "<F20>=\e[200~"
  execute "set" "<F21>=\e[201~"

  " Listen for bracketed paste control sequences to update Vim's paste setting.
  inoremap <silent> <F20> <C-O>:set paste<CR>
  set pastetoggle=<F21>
endif

" Disable the help key in normal, visual, select, operator-pending, and insert
" modes. It's useless, and annoying when it gets hit on accident.
noremap <F1> <Nop>
inoremap <F1> <Nop>

" Disable arrow keys in normal, visual, select, and operator-pending modes to
" avoid the temptation to use them. :) Leave insert mode arrow keys alone.
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>
noremap <Up> <Nop>

" Define normal- and visual-mode mappings to enter command mode when the Enter
" key is pressed.
nnoremap <CR> :
nnoremap <kEnter> :

xnoremap <CR> :
xnoremap <kEnter> :

" Define normal- and visual-mode mappings for Ctrl-modified arrow keys to shift
" the current line or selection, updating indentation accordingly.
"
" <C-Down>    Move the current line/selection down
" <C-Left>    Dedent the current line/selection
" <C-Right>   Indent the current line/selection
" <C-Up>      Move the current line/selection up
nnoremap <silent> <C-Down> ]e==
nnoremap <silent> <C-Left> <<
nnoremap <silent> <C-Right> >>
nnoremap <silent> <C-Up> [e==

xnoremap <silent> <C-Down> ]egv=gv
xnoremap <silent> <C-Left> <gv
xnoremap <silent> <C-Right> >gv
xnoremap <silent> <C-Up> [egv=gv

" Define normal-mode mappings to swap linewise vertical movement keys with keys
" that use display lines (respecting wrapping). Don't swap these bindings for
" visual mode since doing so makes visual-line and visual-block selection weird.
nnoremap <silent> gj j
nnoremap <silent> gk k
nnoremap <silent> j gj
nnoremap <silent> k gk

" Define a normal-mode mapping to make Y before sensibly (yank to end of line).
nnoremap <silent> Y y$

" Define normal- and visual-mode mappings to move between windows, move windows
" around, and close windows:
"
" <M-h>           Focus window to the left of the current window
" <M-j>           Focus window below the current window
" <M-k>           Focus window above the current window
" <M-l>           Focus window to the right of the current window
" <M-H>           Move window to the left of the current window
" <M-J>           Move window below the current window
" <M-K>           Move window above the current window
" <M-L>           Move window to the right of the current window
" <M-q>           Close the current window
execute "set" "<M-h>=\eh"
execute "set" "<M-j>=\ej"
execute "set" "<M-k>=\ek"
execute "set" "<M-l>=\el"
execute "set" "<M-H>=\eH"
execute "set" "<M-J>=\eJ"
execute "set" "<M-K>=\eK"
execute "set" "<M-L>=\eL"
execute "set" "<M-q>=\eq"

nnoremap <silent> <M-h> <C-W>h
nnoremap <silent> <M-j> <C-W>j
nnoremap <silent> <M-k> <C-W>k
nnoremap <silent> <M-l> <C-W>l
nnoremap <silent> <M-H> <C-W>H
nnoremap <silent> <M-J> <C-W>J
nnoremap <silent> <M-K> <C-W>K
nnoremap <silent> <M-L> <C-W>L
nnoremap <silent> <M-q> <C-W>q

xnoremap <silent> <M-h> <C-W>h
xnoremap <silent> <M-j> <C-W>j
xnoremap <silent> <M-k> <C-W>k
xnoremap <silent> <M-l> <C-W>l
xnoremap <silent> <M-H> <C-W>H
xnoremap <silent> <M-J> <C-W>J
xnoremap <silent> <M-K> <C-W>K
xnoremap <silent> <M-L> <C-W>L
xnoremap <silent> <M-q> <C-W>q

" Define normal- and visual-mode mappings for some other keys whose default
" bindings I don't find useful:
"
" H               Go to the first non-blank character of the current line
" L               Go to the last character of the current line
" M               Go to the first character of the current line
nnoremap <silent> H ^
nnoremap <silent> L $
nnoremap <silent> M 0

xnoremap <silent> H ^
xnoremap <silent> L $
xnoremap <silent> M 0

" Begin custom keybindings with the space key.
noremap <Space> <Nop>
let mapleader = ' '
let maplocalleader = ' '

" Configure keybindings for partial commands (intentionally not silent):
"
" <Space>r        Edit file relative to current directory
nnoremap <Leader>r
    \ :e <C-R>=substitute(expand('%:~:.:h') . '/', '^\./$', '', '')<CR>

" Configure keybindings for basic editor functionality:
"
" <Space><Space>  Switch current buffer with alternate file
" <Space>-        Split the current window horizontally
" <Space>/        Clear search highlighting and redraw the screen
" <Space>\        Split the current window vertically
" <Space>s        Toggle spell checking in the current buffer
" <Space>w        Remove trailing whitespace from the current buffer
nnoremap <silent> <Leader><Leader> <C-^>
nnoremap <silent> <Leader>- :split<CR>
nnoremap <silent> <Leader>/ :nohlsearch<CR><C-L>
nnoremap <silent> <Leader>\ :vsplit<CR>
nnoremap <silent> <Leader>s :setlocal spell!<CR>
nnoremap <silent> <Leader>w :EraseBadWhitespace<CR>

" Configure keybindings for working with configuration files:
"
" <Space>cc       Edit current color scheme in a new horizontal split
" <Space>cg       Edit gvimrc file in a new horizontal split
" <Space>cs       Edit spelling dictionary in a new horizontal split
" <Space>cv       Edit vimrc file in a new horizontal split
"
" <Space>dc       Reload current color scheme
" <Space>dg       Reload gvimrc file
" <Space>ds       Reload spelling dictionary
" <Space>dv       Reload vimrc file
nnoremap <silent> <Leader>cc
    \ :execute 'Vsplit colors/' . g:colors_name . '.vim'<CR>
nnoremap <silent> <Leader>cg :split $MYGVIMRC<CR>
nnoremap <silent> <Leader>cs :execute 'split ' . &spellfile<CR>
nnoremap <silent> <Leader>cv :split $MYVIMRC<CR>

nnoremap <silent> <Leader>dc :execute 'colorscheme' g:colors_name<CR>
nnoremap <silent> <Leader>dg :source $MYGVIMRC<CR>
nnoremap <silent> <Leader>ds :execute 'mkspell!' &spellfile<CR>
nnoremap <silent> <Leader>dv :source $MYVIMRC<CR>

" Configure keybindings for CtrlP plugin:
"
" <Space>ab       Perform fuzzy buffer search by name
" <Space>af       Perform fuzzy file search for files starting in VCS root
" <Space>ag       Perform fuzzy buffer search by contents
" <Space>ar       Perform fuzzy file search for files starting next to buffer
nnoremap <silent> <Leader>ab :CtrlPBuffer<CR>
nnoremap <silent> <Leader>af :CtrlPRoot<CR>
nnoremap <silent> <Leader>ag :CtrlPLine<CR>
nnoremap <silent> <Leader>ar :CtrlP<CR>

" Configure keybindings for Eclim plugin:
"
" <Space>ea       Open or close buffer with tree view of current project
" <Space>ee       Search project for source element under the cursor
" <Space>ef       Open fuzzy search tool for Java classes, source files, etc.
" <Space>eh       Open Java call hierarchy for method under cursor
" <Space>eo       Remove unused Java imports and organize remaining imports
" <Space>ep       Show compilation errors in quickfix buffer
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

" Configure the standard shell plugin.
let g:is_bash = 1

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
let g:ctrlp_switch_buffer = ''
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

" Configure the vim-go plugin.
let g:go_highlight_operators = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_build_constraints = 1

" Set a nice color scheme that behaves well on 8-, 88-, and 256-color terminals.
" Must be done after we call Pathogen since the color scheme lives in a bundle.
colorscheme abbott
