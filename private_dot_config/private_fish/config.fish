if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
end

set -g fish_greeting
set -Ux EDITOR nvim

function fish_hybrid_key_bindings --description \
"Vi-style bindings that inherit emacs-style bindings in all modes"
    for mode in default insert visual
        fish_default_key_bindings -M $mode
    end
    fish_vi_key_bindings --no-erase
end
set -g fish_key_bindings fish_hybrid_key_bindings

function multicd
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
abbr --add dotdot --regex '^\.\.+$' --function multicd


# NeoVim Switcher for different configs
function nvims
    set items (find $HOME/.config -maxdepth 2 -name "init.lua" -type f -execdir sh -c 'pwd | xargs basename' \;)
    set selected (printf "%s\n" $items | env FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --preview-window 'right:border-left:50%:<40(right:border-left:50%:hidden)' --preview 'lsd -l -A --tree --depth=1 --color=always --blocks=size,name ~/.config/{} | head -200'" fzf)
    
    if test -z "$selected"
        return 0
    else if test "$selected" = "nvim"
        set selected ""
    end
    
    env NVIM_APPNAME=$selected nvim $argv
end
alias nvs 'nvims'

abbr -a -- g git
abbr -a -- vim nvim
abbr -a -- vimdiff 'nvim -d'
abbr -a -- cm chezmoi
abbr -a -- ssh ssh.exe
abbr -a -- ssh-add ssh-add.exe
abbr -a -- op op.exe

complete -f -c dotnet -a "(dotnet complete (commandline -cp))"

# Python config
set -g -x PIP_REQUIRE_VIRTUALENV true

pyenv init - | source
direnv hook fish | source
fzf --fish | source

function __nvm_auto --on-variable PWD
  nvm use --silent 2>/dev/null
end
__nvm_auto
