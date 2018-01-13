HOST_PROFILE=~/.dotfiles.priv/`hostname -s`/.zprofile
if [ -f $HOST_PROFILE ]; then
    source $HOST_PROFILE
fi

dotfile-checker
export PATH="$HOME/.cargo/bin:$PATH"
