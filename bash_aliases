# -------------------------------------------------------------------------- #
#         BASH COMMANDS
# -------------------------------------------------------------------------- #

# enable color support of ls and also add handy aliases

alias ll='ls -CFG'
alias l='ls -alFG'
alias la='ls -AaG'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias paunt='sudo netstat -paunt' # Show all processes bound to TCP ports.
alias allusers='cut -d: -f1 /ect/passwd' # Show all users in the system.
alias killcache='git credential-cache exit' # Reset git credentials.
alias maws='/Users/simone/CS/bynd-aws-cli/bin/saws'
