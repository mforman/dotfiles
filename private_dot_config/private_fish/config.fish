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

nvm use latest --silent
