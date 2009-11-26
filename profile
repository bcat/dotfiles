# Make sure the home bin directory is referenced in the search path.
if [ -d ~/bin ] &&
   ! printf '%s\n' "$PATH" | grep -E "(^|:)$HOME/bin($|:)" >/dev/null
then
  export PATH=$HOME/bin:$PATH
fi

# Set the preferred editor.
if command -v nano >/dev/null; then
  export EDITOR=$(command -v nano)
  export FCEDIT=$(command -v nano)
  export VISUAL=$(command -v nano)
elif command -v pico >/dev/null; then
  export EDITOR=$(command -v pico)
  export FCEDIT=$(command -v pico)
  export VISUAL=$(command -v pico)
elif command -v vim >/dev/null; then
  export EDITOR=$(command -v vim)
  export FCEDIT=$(command -v vim)
  export VISUAL=$(command -v vim)
elif command -v vi >/dev/null; then
  export EDITOR=$(command -v vi)
  export FCEDIT=$(command -v vi)
  export VISUAL=$(command -v vi)
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

# Eclipse on Ubuntu doesn't respect the user's default JVM setting, so we have
# to manually set JAVA_HOME.
if [ -d /usr/lib/jvm/java-6-openjdk ]; then
  export JAVA_HOME=/usr/lib/jvm/java-6-openjdk
elif [ -d /usr/lib/jvm/java-6-sun ]; then
  export JAVA_HOME=/usr/lib/jvm/java-6-sun
elif [ -d /usr/lib/jvm/java-gcj ]; then
  export JAVA_HOME=/usr/lib/jvm/java-gcj
fi

# If we have fortune and this is an interactive shell, print a fortune cookie.
if type fortune >/dev/null 2>&1; then
  case "$-" in *i*)
    printf '\n'
    fortune
    printf '\n'
  ;; esac
fi

# If we're running bash, source ~/.bashrc now.
[ -n "$BASH" ] && [ -f ~/.bashrc ] && . ~/.bashrc
