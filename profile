# Set the correct UTF-8/English (US) locale and language if not already done.
[ -z "$LANG" ] && locale -a | grep -i -q ^en_US.UTF8$ && export LANG=en_US.UTF8
[ -z "$LANGUAGE" ] && export LANGUAGE=en_US:en

# Make sure various directories are referenced in the search path.
_profile_prepend_to_path () {
  [ -d "$1" ] && case :$PATH: in
    *:$1:*) ;;
    *) export PATH=$1:$PATH ;;
  esac
}

_profile_prepend_to_path /sbin
_profile_prepend_to_path /usr/games
_profile_prepend_to_path /usr/local/sbin
_profile_prepend_to_path /usr/sbin

_profile_prepend_to_path ~/bin
_profile_prepend_to_path ~/.cabal/bin

# Set the preferred editor.
if which vim >/dev/null 2>&1; then
  export EDITOR=$(which vim)
  export FCEDIT=$(which vim)
  export VISUAL=$(which vim)
elif which vi >/dev/null 2>&1; then
  export EDITOR=$(which vi)
  export FCEDIT=$(which vi)
  export VISUAL=$(which vi)
elif which nano >/dev/null 2>&1; then
  export EDITOR=$(which nano)
  export FCEDIT=$(which nano)
  export VISUAL=$(which nano)
elif which pico >/dev/null 2>&1; then
  export EDITOR=$(which pico)
  export FCEDIT=$(which pico)
  export VISUAL=$(which pico)
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
[ -r ~/.profile.local ] && . ~/.profile.local

# If we're running bash, source ~/.bashrc now.
[ -n "$BASH" ] && [ -r ~/.bashrc ] && . ~/.bashrc
