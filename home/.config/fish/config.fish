set -g fish_greeting
set RED (set_color -o red)
set ORANGE (set_color -o yellow)
set BLUE (set_color -o blue)
set GREEN (set_color -o green)
set STOP (set_color normal)

function print_info
if test -n "$SSH_CLIENT" -o -n "$SSH_TTY"
    printf "%s" $ORANGE
    toilet -d /usr/share/figlet/fonts -f 3d "ssh connection" -t -F border -SWk
    else
    #fastfetch
end
end
function clear_fastfetch
    command clear
    print_info
end
if status is-interactive
    print_info
end

# List Directory
alias ls="lsd"
alias l="ls -l"
alias la="ls -a"
alias lla="ls -la"
alias lt="ls --tree"
alias clear clear_fastfetch
alias emacs="emacs -nw"
# Handy change dir shortcuts
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .3 'cd ../../..'
abbr .4 'cd ../../../..'
abbr .5 'cd ../../../../..'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
