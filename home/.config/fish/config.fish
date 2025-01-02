set -g fish_greeting
fish_vi_key_bindings
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
alias gitsync='git status; git add .; git commit -m "Sync"; git push origin main'
alias snvim='sudo -E nvim'
# Source cargo environment
# Source .cargo/env
set -gx CARGO_HOME "$HOME/.cargo"
set -gx PATH $CARGO_HOME/bin $PATH
# Set PATH and LD_LIBRARY_PATH
set -Ux PATH /opt/cuda/bin $PATH
set -Ux LD_LIBRARY_PATH /opt/cuda/lib64 $LD_LIBRARY_PATH
# Add pipx bin directory to PATH
set -gx PATH $PATH /home/user/.local/bin
# Handy change dir shortcuts
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .3 'cd ../../..'
abbr .4 'cd ../../../..'
abbr .5 'cd ../../../../..'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
