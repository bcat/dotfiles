# Make sure various directories are referenced in the search path.
_profile_add_to_path () {
  if [ -d "$1" ] &&
     ! printf '%s\n' "$PATH" | grep -E "(^|:)$1($|:)" /dev/null
  then
    export PATH=$1:$PATH
  fi
}

_profile_add_to_path /usr/games
_profile_add_to_path /opt/haskell-platform/bin

_profile_add_to_path ~/bin
_profile_add_to_path ~/bin/gsutil
_profile_add_to_path ~/.cabal/bin

# Set the preferred editor.
if command -v vim >/dev/null; then
  export EDITOR=$(command -v vim)
  export FCEDIT=$(command -v vim)
  export VISUAL=$(command -v vim)
elif command -v vi >/dev/null; then
  export EDITOR=$(command -v vi)
  export FCEDIT=$(command -v vi)
  export VISUAL=$(command -v vi)
elif command -v nano >/dev/null; then
  export EDITOR=$(command -v nano)
  export FCEDIT=$(command -v nano)
  export VISUAL=$(command -v nano)
elif command -v pico >/dev/null; then
  export EDITOR=$(command -v pico)
  export FCEDIT=$(command -v pico)
  export VISUAL=$(command -v pico)
fi

# Set the preferred pager.
if command -v less >/dev/null; then
  export PAGER=$(command -v less)
elif command -v more >/dev/null; then
  export PAGER=$(command -v more)
fi

# Make less a little bit nicer.
type lesspipe >/dev/null 2>&1 && eval "$(lesspipe)"

export LESS='-M -R'

# If there is a local .profile file, source that now.
[ -f ~/.profile.local ] && . ~/.profile.local

# If we're running bash, source ~/.bashrc now.
[ -n "$BASH" ] && [ -f ~/.bashrc ] && . ~/.bashrc
