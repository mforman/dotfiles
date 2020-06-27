
if [[ ! -d $HOME/powerlevel10k ]]
then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
else
    git -C ~/powerlevel10k pull
fi
