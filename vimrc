" This configuration is based on the example vimrc included with Arch Linux, the
" Vim Tips Wiki, and the vimrc Ben Breedlove (https://github.com/benbreedlove)
" sent me to look at. (Thanks, Ben!)

" Certain enviroments feature only a minimal set of Vim features (e.g.,
" Debian's vim-tiny package). When the eval feature is disabled, almost all
" Vimscript commands fail with errors.
"
" We use the `while 0` trick (see `:help no-eval-feature`) to set some basic
" quality of life options we'd normally get from sensible.vim.
"
" Additionally, when the eval feature is unavailable, Vim ignores all if
" statements, so we use `if 1` conditionals to guard commands not supported by
" eval-less Vim binaries.
silent! while 0
  set nocompatible

  set backspace=indent,eol,start
  set history=1000
  set laststatus=2
  set nrformats-=octal
  set ruler
  set smarttab
  set ttimeout
silent! endwhile

" Patch up termcap capabilities and other terminal-specific settings.
if 1
  source ~/.term.vim
endif

" Hide the intro screen
set shortmess+=I

" Disable swap files. Vim almost never crashes, and they clutter up directories.
set noswapfile

" Allow modified buffers to live in the background.
set hidden

" Make the ~ (switch case) command accept movement like a real operator.
set tildeop

" Keep the join and gq (format) commands from putting two spaces after periods.
set nojoinspaces

" All our connections are speedy, so let Vim know that.
set ttyfast

" Don't redraw the screen during macro execution (big speedup for slow terms).
set lazyredraw

" Show line numbers.
set number
set numberwidth=5

" Prefer to break lines at punctuation when soft wrapping.
set linebreak

" Scroll smoothly at the left and right edges of the screen.
set sidescroll=1

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
" automatically take the value from tabstop; however, that wouldn't work
" properly before Vim 7.3.694.
set tabstop=2
set shiftwidth=2

" Wrap files at 80 characters by default. (Overridden for some languages below.)
set textwidth=80

" Always allow Vim to set the window title even if the old can't be restored on
" exit since our shell prompt resets the title itself. Also prevent the silly
" "Thanks for flying Vim" message from flashing on exit.
set title
set titleold=

" For buffers where textwidth is nonzero, show a right-margin two characters
" *after* the wrapping point. Not available before Vim 7.3.
if exists('&colorcolumn')
  set colorcolumn=+2
endif

" Highlight the current line number. Not available before Vim 8.1.2019.
if exists('&cursorlineopt')
  set cursorline
  set cursorlineopt=number
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
    autocmd FileType c,cpp setlocal cinoptions+=l1,g1,h1,N-s,(0,j1
    autocmd FileType c,cpp AutoFormatBuffer

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

    " Highlight Bazel build system stuff as Python.
    autocmd BufNewFile,BufRead BUILD setlocal filetype=python
    autocmd BufNewFile,BufRead build_defs setlocal filetype=python
  augroup END
endif

" Use ripgrep (a faster replacement for grep that behaves better in Git
" repositories) if available.
if executable('rg')
  set grepprg=rg\ --vimgrep
  set grepformat=%f:%l:%c:%m
endif

" Turn off folding, which is obnoxious and which I never use.
if has('folding')
  set nofoldenable
endif

" Enable fancy search settings. Don't set hlsearch if it's already set since
" this reverses the effects on :nohlsearch and forces highlighting the last
" search whenever the vimrc file is sourced.
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

" Yank to the clipboard via xterm's OSC 52 (manipulate selection data) sequence
" in supporting terminals. This requires Vim to be compiled with clipboard
" support or else the "+ register is not defined.
if has('clipboard') && exists('##TextYankPost')
    \ && &term =~# '\v^%(hterm|tmux|xterm)%($|-)'
  function! s:TextYankPost()
    " When yanking to "+, v:register is always '+', but v:event.regname is only
    " set to '+' if Vim successfully yanked to the X11 clipboard. This lets us
    " use OSC 52 only if Vim's native clipboard support can't handle the yank.
    if v:register ==# '+' && v:event.regname ==# ''
      call SendViaOSC52(join(v:event.regcontents, "\n"))
    endif
  endfunction

  augroup vimrc_clipboard
    autocmd!
    autocmd TextYankPost * call s:TextYankPost()
  augroup END
endif

if has('mouse')
  " Enable mouse support for GUI Vim and terminal Vim (if supported).
  set mouse=a
  set mousefocus
endif

" Reduce key sequence timeout to 50 ms. This is still long enough for modern
" connections, and it helps prevent characters typed after pressing escape from
" accidentally registering as Meta modified.
set ttimeoutlen=50

" Set Meta-modified keys we wish to use in mappings to use the Esc prefix since
" that's what most terminals use. (Once Vim 8.2 rolls out with modifyOtherKeys
" support and more terminals handle XTMODKEYS, we can remove this.)
if 1
  execute "set <M-=>=\e="
  execute "set <M-h>=\eh"
  execute "set <M-j>=\ej"
  execute "set <M-k>=\ek"
  execute "set <M-l>=\el"
  execute "set <M-m>=\em"
  execute "set <M-q>=\eq"
  execute "set <M-H>=\eH"
  execute "set <M-J>=\eJ"
  execute "set <M-K>=\eK"
  execute "set <M-L>=\eL"
end

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

" Define normal- and visual-mode mappings for Ctrl-modified arrow keys to shift
" the current line or selection, updating indentation accordingly.
"
" <C-Down>   Move the current line/selection down
" <C-Left>   Dedent the current line/selection
" <C-Right>  Indent the current line/selection
" <C-Up>     Move the current line/selection up
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
" around, resize windows, and close windows:
"
" <M-=>  Equalize sizes of open windows
" <M-h>  Focus window to the left of the current window
" <M-j>  Focus window below the current window
" <M-k>  Focus window above the current window
" <M-l>  Focus window to the right of the current window
" <M-q>  Close the current window
" <M-H>  Move window to the left of the current window
" <M-J>  Move window below the current window
" <M-K>  Move window above the current window
" <M-L>  Move window to the right of the current window
nnoremap <silent> <M-=> <C-W>=
nnoremap <silent> <M-h> <C-W>h
nnoremap <silent> <M-j> <C-W>j
nnoremap <silent> <M-k> <C-W>k
nnoremap <silent> <M-l> <C-W>l
nnoremap <silent> <M-q> <C-W>q
nnoremap <silent> <M-H> <C-W>H
nnoremap <silent> <M-J> <C-W>J
nnoremap <silent> <M-K> <C-W>K
nnoremap <silent> <M-L> <C-W>L

xnoremap <silent> <M-=> <C-W>=
xnoremap <silent> <M-h> <C-W>h
xnoremap <silent> <M-j> <C-W>j
xnoremap <silent> <M-k> <C-W>k
xnoremap <silent> <M-q> <C-W>q
xnoremap <silent> <M-l> <C-W>l
xnoremap <silent> <M-q> <C-W>q
xnoremap <silent> <M-H> <C-W>H
xnoremap <silent> <M-J> <C-W>J
xnoremap <silent> <M-K> <C-W>K
xnoremap <silent> <M-L> <C-W>L

" Begin custom keybindings with the space key.
noremap <Space> <Nop>
if 1
  let mapleader = ' '
  let maplocalleader = ' '
end

" Configure keybindings for partial commands (intentionally not silent):
"
" <Space>r  Edit file relative to current directory
nnoremap <Leader>r
    \ :e <C-R>=substitute(expand('%:~:.:h') . '/', '^\./$', '', '')<CR>

" Configure keybindings for basic editor functionality:
"
" <Space><Space>  Switch current buffer with alternate file
" <Space>-        Split the current window horizontally
" <Space>\        Split the current window vertically
" <Space>s        Toggle spell checking in the current buffer
" <Space>w        Remove trailing whitespace from the current buffer
nnoremap <silent> <Leader><Leader> <C-^>
nnoremap <silent> <Leader>- :split<CR>
nnoremap <silent> <Leader>\ :vsplit<CR>
nnoremap <silent> <Leader>s :setlocal spell!<CR>
nnoremap <silent> <Leader>w :StripWhitespace<CR>

" Configure keybindings for working with configuration files:
"
" <Space>cc  Edit current color scheme in a new horizontal split
" <Space>cg  Edit gvimrc file in a new horizontal split
" <Space>cs  Edit spelling dictionary in a new horizontal split
" <Space>cv  Edit vimrc file in a new horizontal split
" <Space>cC  Reload current color scheme
" <Space>cG  Reload gvimrc file
" <Space>cS  Reload spelling dictionary
" <Space>cV  Reload vimrc file
nnoremap <silent> <Leader>cc
    \ :execute 'Vsplit colors/' . g:colors_name . '.vim'<CR>
nnoremap <silent> <Leader>cg :split $MYGVIMRC<CR>
nnoremap <silent> <Leader>cs :execute 'split' &spellfile<CR>
nnoremap <silent> <Leader>cv :split $MYVIMRC<CR>
nnoremap <silent> <Leader>cC :execute 'colorscheme' g:colors_name<CR>
nnoremap <silent> <Leader>cG :source $MYGVIMRC<CR>
nnoremap <silent> <Leader>cS :execute 'mkspell!' &spellfile<CR>
nnoremap <silent> <Leader>cV :source $MYVIMRC<CR>

" Configure keybindings for CtrlP plugin:
"
" <Space>ab  Perform fuzzy buffer search by name
" <Space>af  Perform fuzzy file search for files starting in VCS root
" <Space>ag  Perform fuzzy buffer search by contents
" <Space>ar  Perform fuzzy file search for files starting next to buffer
nnoremap <silent> <Leader>ab :CtrlPBuffer<CR>
nnoremap <silent> <Leader>af :CtrlPRoot<CR>
nnoremap <silent> <Leader>ag :CtrlPLine<CR>
nnoremap <silent> <Leader>ar :CtrlP<CR>

" Configure keybindings for vim-zoom plugin:
"
" <Space>z  Zoom in on current window, or zoom out if already zoomed in
nmap <silent> <Leader>z <Plug>(zoom-toggle)

if 1
  " Configure the standard Java plugin.
  let g:java_highlight_functions = 'style'

  " Configure the standard Python plugin.
  let g:pyindent_open_paren
      \ = 'exists("*shiftwidth") ? shiftwidth() : &shiftwidth'

  " Configure the standard shell plugin.
  let g:is_bash = 1

  " Configure the standard TeX plugin.
  let g:tex_indent_and = 0
  let g:tex_flavor = 'latex'
  let g:tex_stylish = 1

  " Configure the standard Vim plugin.
  let g:vim_indent_cont = 4

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

  " Set our personal color scheme, enabling preferences for fancy terminals.
  let g:abbott_set_term_ansi_colors = 1
  let g:abbott_term_set_underline_color = 1
  let g:abbott_term_use_italics = 1
  let g:abbott_term_use_undercurl = 1
  colorscheme abbott

  " Force plugins to load so we can configure Google plugins via Glaive. Eww.
  packloadall

  " Configure the codefmt plugin. Enable its default mappings.
  Glaive codefmt plugin[mappings]
end
