# -------------------------------------------------------------------------- #
#         BASH COMMANDS
# -------------------------------------------------------------------------- #

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias l='ls -CF --color=auto'
    alias ll='ls -alF --color=auto'
    alias la='ls -Aa --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias paunt='sudo netstat -paunt' # Show all processes bound to TCP ports.
alias allusers='cut -d: -f1 /ect/passwd' # Show all users in the system.
alias killcache='git credential-cache exit' # Reset git credentials.
