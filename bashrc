# If this isn't an interactive shell, bail out now.
case $- in
  *i*) ;;
  *) return ;;
esac

# All our xterm-like terminals support 256 colors, so let's select the right
# terminal type.
[ "$TERM" = xterm ] && export TERM=xterm-256color

# If we have fortune, print a fortune cookie.
if type fortune >/dev/null 2>&1; then
  if type cowsay >/dev/null 2>&1; then
    fortune ~/fortunes/hitchhiker | cowsay -n
  else
    printf '\n'
    fortune ~/fortunes/hitchhiker
    printf '\n'
  fi
fi

# Set shell options and variables.
set -o emacs     # Use emacs-style editing commands.
set -o noclobber # Don't allow redirections to overwrite existing files.

shopt -s cdspell      # Perform typo-correction on `cd` destinations.
shopt -s checkhash    # Confirm locations of hashed commands.
shopt -s checkwinsize # Update LINES and COLUMNS variables after each command.
shopt -s cmdhist      # Save multi-line commands in a single history entry.
shopt -s extglob      # Enable extended pattern matching features.
shopt -s globstar     # Match subdirectories with `**` pattern.
shopt -s histappend   # Append to history file instead of overwriting it.
shopt -s histverify   # Verify history substitutions before executing them.
shopt -s huponexit    # Send SIGHUP to background jobs on exit.
shopt -s xpg_echo     # Make echo POSIX-compliant w.r.t. escape sequences.

HISTCONTROL=ignoreboth:erasedups # Remove duplicate history entries and don't
                                 # save commands beginning with spaces.
HISTFILESIZE=1000                # Increase command history size on disk...
HISTSIZE=1000                    # ... and in memory.
unset HISTTIMEFORMAT             # Remove dumb history timestamps people set.

# Emulate ZSH's `precmd` and `preexec` functions. Credit for the technique
# goes to Glyph Lefkowitz. See also: <http://glyf.livejournal.com/63106.html>.
_bashrc_prompt_command () {
  [ "$(type -t precmd)" = function ] && precmd

  _bashrc_run_preexec=1
}

_bashrc_debug_trap () {
  if [ -n "$_bashrc_run_preexec" ] && [ -z "$COMP_LINE" ]; then
    [ "$BASH_COMMAND" != _bashrc_prompt_command ] &&
      [ "$(type -t preexec)" = function ] && preexec "$(history 1 |
      sed 's/^[[:space:]]*[[:digit:]]\{1,\}[[:space:]]*//')"

    unset _bashrc_run_preexec
  fi

  return 0
}

PROMPT_COMMAND=_bashrc_prompt_command
trap _bashrc_debug_trap DEBUG

set -o functrace
shopt -s extdebug

# Give certain commands some color.
alias grep='grep --color=auto'

type dircolors >/dev/null 2>&1 && eval $(dircolors ~/.config/lscolors/LS_COLORS)

if ls --color / >/dev/null 2>&1; then
  alias ls='ls --color=auto'  # GNU ls
else
  alias ls='CLICOLOR=1 ls'  # BSD ls
fi

# Customize the prompt. (The prompt code is quite long, so it lives in a
# separate file.)
[ -f ~/.bash_prompt.sh ] && . ~/.bash_prompt.sh

# Set up some fancy auto-completion.
[ -f /etc/bash_completion ] && . /etc/bash_completion

# If there is a local .bashrc file, source that now.
[ -f ~/.bashrc.local ] && . ~/.bashrc.local
