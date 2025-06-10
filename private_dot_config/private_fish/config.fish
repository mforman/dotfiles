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


if test -d /home/linuxbrew/.linuxbrew # Linux
	set -gx HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew"
	set -gx HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
	set -gx HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/Homebrew"
else if test -d /opt/homebrew # MacOS
	set -gx HOMEBREW_PREFIX "/opt/homebrew"
	set -gx HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
	set -gx HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/homebrew"
end
fish_add_path -gP "$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin";
! set -q MANPATH; and set MANPATH ''; set -gx MANPATH "$HOMEBREW_PREFIX/share/man" $MANPATH;
! set -q INFOPATH; and set INFOPATH ''; set -gx INFOPATH "$HOMEBREW_PREFIX/share/info" $INFOPATH;


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
abbr -a -- dcd 'docker compose down'
abbr -a -- dcu 'docker compose up -d'


complete -f -c dotnet -a "(dotnet complete (commandline -cp))"

test -x (which aws_completer); and complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'


# Python config
set -g -x PIP_REQUIRE_VIRTUALENV true

pyenv init - | source
status --is-interactive; and pyenv virtualenv-init - | source
direnv hook fish | source
fzf --fish | source

function __nvm_auto --on-variable PWD
  nvm use --silent 2>/dev/null
end
__nvm_auto

# pnpm
set -gx PNPM_HOME "/Users/mforman/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# Created by `pipx` on 2025-05-07 14:13:28
set PATH $PATH /Users/mforman/.local/bin
