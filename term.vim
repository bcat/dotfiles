" Vim uses the system terminfo for most configuration, augmented with some
" extensions from its builtin XTerm termcap. Likewise, Vim parses v:termresponse
" from the terminal to selectively enable features only supported in certain
" versions of certain terminals. Sometimes this fails and overrides are needed.

" Try the XTVERSION escape sequence to read the terminal name and version (e.g.,
" "mintty 3.2.0". We time out after 50 milliseconds so we don't slow down
" startup too much if the terminal doesn't support this escape sequence.
let g:term_version = substitute(system("printf '\e[>0q' >/dev/tty;"
    \ . "read -sr -d '\\' -t 0.05 </dev/tty;"
    \ . "printf %s \"$REPLY\""), "\\C^\eP>|\\([^\e]*\\)\e$", '\1', '')

let s:is_hterm = v:termresponse ==# "\e[>0;256;0c"
let s:is_mintty = g:term_version =~# '\v^mintty' || &term =~# '\vmintty%(-|$)'
let s:is_tmux = $TMUX || &term =~# '\v^tmux%(-|$)'
let s:is_urxvt = &term =~# '\v^rxvt-unicode%(-|$)'
let s:is_xterm = (g:term_version =~# '\v^XTerm' || &term =~# '\vxterm%(-|$)')
    \ && !s:is_hterm && !s:is_mintty && !s:is_tmux

" When vim_is_xterm returns false, Vim's builtin XTerm termcap isn't applied, so
" several Vim-specific termcap extensions go missing. For terminals we know
" behave like XTerm, manually set these values.
"
" See https://github.com/vim/vim/issues/6609 for more details.
if (s:is_hterm || s:is_mintty || s:is_tmux) && &term !~# '\vxterm%(-|$)'
  " SGR (character attributes): set underline color, indexed (kitty extension)
  "   CSI 58 : 5 : Ps m
  "
  " Use colon instead of semicolon as subparameter delimiter or else mintty
  " parses this as two separate SGR codes: 58 and 5).
  let &t_AU="\e[58:5:%dm"

  " Send device attributes (secondary DA): request terminal identification
  "   CSI > c
  let &t_RV = "\e[>c"

  " SGR (character attributes): set foreground color, RGB
  "   CSI 38 ; 2 ; Pr ; Pg ; Pb m
  let &t_8f = "\e[38;2;%lu;%lu;%lum"

  " SGR (character attributes): set foreground color, RGB
  "   CSI 48 ; 2 ; Pr ; Pg ; Pb m
  let &t_8b = "\e[48;2;%lu;%lu;%lum"

  " SGR (character attributes): set underline color, RGB (kitty extension)
  "   CSI 58 : 2 : : Pr : Pg : Pb m
  "
  " Use colon instead of semicolon as subparameter delimiter or else mintty
  " parses this as two separate SGR codes: 58 and 2).
  let &t_8u="\e[58:2::%lu:%lu:%lum"

  " DECSET (DEC private mode set): bracketed paste mode
  "   CSI ? 2 0 0 4 h
  let &t_BE = "\e[?2004h"

  " DECRST (DEC private mode reset): bracketed paste mode
  "   CSI ? 2 0 0 4 l
  let &t_BD = "\e[?2004l"

  " DECSCUSR (set cursor style)
  "   CSI Ps SP q
  let &t_SH = "\e[%p1%d q"

  " XTWINOPS (save title): window title
  "   CSI 2 2 ; 2 t
  let &t_ST = "\e[22;2t"

  " XTWINOPS (restore title): window title
  "   CSI 2 3 ; 2 t
  let &t_RT = "\e[23;2t"

  " Start of bracketed paste
  "   ESC [ 2 0 0 ~
  let &t_PS = "\e[200~"

  " End of bracketed paste
  "   ESC [ 2 0 1 ~
  let &t_PE = "\e[201~"
endif

" Vim uses the nonstandard Cs termcap entry to mean "undercurl mode", but it's
" already used as an extension in terminfo meaning "set cursor color". We
" override it to have Vim's intended meaning, as well as setting the equivalent
" Ce termcap entry for XTerm-like terminals where vim_is_xterm returns false.
"
" See https://github.com/vim/vim/issues/3471 for more details.
if s:is_hterm || s:is_mintty || s:is_tmux
  " SGR (character attributes): curly underline (kitty extension)
  "   CSI 4 : 3 m
  let &t_Cs = "\e[4:3m"

  " SGR (character attributes): normal
  "   CSI m
  let &t_Ce = "\e[m"
elseif s:is_xterm
  " Real XTerm doesn't support underline style at all.
  let &t_Cs = ""
  let &t_Ce = ""
endif

" If the terminal supports it, set the cursor to a blinking bar in insert mode
" and a blinking underline in replace mode. (This matches the default behavior
" of the gVim cursor.)
if s:is_hterm || s:is_mintty || s:is_urxvt || s:is_tmux || s:is_xterm
  " Set cursor to blinking bar when entering insert mode.
  "
  " DECSCUSR (set cursor style): blinking bar
  "   CSI 5 SP q
  let &t_SI = "\e[5 q"

  " Set cursor to blinking underline when entering replace mode.
  "
  " DECSCUSR (set cursor style): blinking underline
  "   CSI 3 SP q
  let &t_SR = "\e[3 q"

  " Reset cursor to blinking block when leaving insert or replace mode.
  "
  " DECSCUSR (set cursor style): blinking block (in XTerm) or reset to default
  " cursor style (in VTE: https://bugzilla.gnome.org/show_bug.cgi?id=720821)
  "   CSI 0 SP q
  let &t_EI = "\e[0 q"
endif

if has('mouse')
  " tmux implements the SGR mouse protocol (DECSET 1006) that supports terminals
  " wider than 223 columns, but as of Vim 8.2, this isn't autodetected.
  "
  " hterm also supports the SGR mouse protocol, but as of August 2020, it
  " claims to be XTerm Patch #256 (from 2012) too old to support SGR.
  if s:is_hterm || s:is_tmux
    set ttymouse=sgr
  endif

  " urxvt implements its own mouse protocol (DECSET 1015) that also supports
  " terminals wider than 223 columns, but as of Vim 8.2, this isn't
  " autodetected.
  if s:is_urxvt
    set ttymouse=urxvt
  endif
endif

" Detecting true-color support is tricky. Some terminfo entries (such as
" xterm-direct) declare support for 16 million colors, but this isn't common.
" Other terminals set the COLORTERM environment variable, but again, this isn't
" common. See https://github.com/termstandard/colors for more details.
if has('termguicolors') && (&t_Co == 16777216
    \ || $COLORTERM =~# '\v^%(truecolor|24bit)$' || s:is_hterm || s:is_mintty)
  set termguicolors
endif
