# _profile_prepend_to_path DIRECTORY
#
# Prepends DIRECTORY to the search path if it exists and isn't already present.
_profile_prepend_to_path () {
  [ -d "$1" ] && case :$PATH: in
    *:$1:*) ;;
    *) export PATH=$1:$PATH ;;
  esac
}

# Add system binaries to the search path since Debian no longer includes them by
# default (https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=918754).
_profile_prepend_to_path /sbin
_profile_prepend_to_path /usr/sbin
_profile_prepend_to_path /usr/local/sbin

# Add games to the search path since not all systems include them by default.
_profile_prepend_to_path /usr/games
_profile_prepend_to_path /usr/local/games

# Add per-user binaries from Cabal, pip, and other sources to the search path.
_profile_prepend_to_path ~/.cabal/bin
_profile_prepend_to_path ~/.local/bin

# Set the preferred editor.
if which vim >/dev/null 2>&1; then
  export EDITOR=$(which vim)
  export FCEDIT=$(which vim)
  export VISUAL=$(which vim)
elif which vi >/dev/null 2>&1; then
  export EDITOR=$(which vi)
  export FCEDIT=$(which vi)
  export VISUAL=$(which vi)
fi

# Set the preferred pager.
if which less >/dev/null 2>&1; then
  export PAGER=$(which less)
elif which more >/dev/null 2>&1; then
  export PAGER=$(which more)
fi

# Make less a little bit nicer.
type lesspipe >/dev/null 2>&1 && eval "$(lesspipe)"

export LESS='-M -R'

# If there is a local .profile file, source that now.
[ -f ~/.profile.local ] && . ~/.profile.local

# If we're running bash, source ~/.bashrc now.
[ -n "$BASH" ] && [ -f ~/.bashrc ] && . ~/.bashrc
