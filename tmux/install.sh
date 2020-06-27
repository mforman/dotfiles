if test ! $(which tmux)
then
    brew install tmux
fi

if [[ ! -d $HOME/.tmux/plugins/tpm ]]
then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi