# _profile_prepend_to_path DIRECTORY
#
# Prepends DIRECTORY to the search path if it exists and isn't already present.
_profile_prepend_to_path () {
  case ":$PATH:" in
    *:"$1":*) ;;
    *) [ -d "$1" ] && export PATH="$1:$PATH" ;;
  esac
}

# Add system binaries to the search path since Debian no longer includes them by
# default (https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=918754).
_profile_prepend_to_path /usr/sbin
_profile_prepend_to_path /usr/local/sbin

# Add games to the search path since not all systems include them by default.
_profile_prepend_to_path /usr/games
_profile_prepend_to_path /usr/local/games

# Add per-user binaries from pip and other sources to the search path.
_profile_prepend_to_path ~/.local/bin
_profile_prepend_to_path ~/.gem
_profile_prepend_to_path ~/sdk/qmk/bin

# Work around Ruby's awful package management
# (https://felipec.wordpress.com/2022/08/25/fixing-ruby-gems-installation/).
export GEM_HOME="$HOME/.gem"

# Set the preferred editor.
if command -v vim >/dev/null; then
  EDITOR="$(command -v vim)"
  FCEDIT="$(command -v vim)"
  VISUAL="$(command -v vim)"
  export EDITOR FCEDIT VISUAL
elif command -v vi >/dev/null; then
  EDITOR="$(command -v vi)"
  FCEDIT="$(command -v vi)"
  VISUAL="$(command -v vi)"
  export EDITOR FCEDIT VISUAL
fi

# Set the preferred pager.
if command -v less >/dev/null; then
  PAGER="$(command -v less)"
  export PAGER
fi

# Make less a little bit nicer.
if command -v lesspipe >/dev/null; then
  eval "$(lesspipe)"
fi

export LESS='-M -R'

# If there is a local .profile file, source that now.
[ -f ~/.profile.local ] && . ~/.profile.local

# If we're running bash, source ~/.bashrc now.
[ -n "$BASH" ] && [ -f ~/.bashrc ] && . ~/.bashrc
