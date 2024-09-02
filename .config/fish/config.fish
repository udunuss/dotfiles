set -g fish_greeting

function print_info
if test -n "$SSH_CLIENT" -o -n "$SSH_TTY"
    toilet -d /usr/share/figlet/fonts -f 3d "ssh connection" -t -F border -SWk
    else
    fastfetch
end
end
function clear_fastfetch
    command clear
    print_info
end
if status is-interactive
    #starship init fish | source
    print_info
end

# List Directory
alias ls="lsd"
alias l="ls -l"
alias la="ls -a"
alias lla="ls -la"
alias lt="ls --tree"
alias clear clear_fastfetch
# Handy change dir shortcuts
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .3 'cd ../../..'
abbr .4 'cd ../../../..'
abbr .5 'cd ../../../../..'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
abbr mkdir 'mkdir -p'
