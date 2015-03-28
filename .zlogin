HOST_LOGIN=~/.dotfiles.priv/`hostname -s`/.zlogin
if [ -f $HOST_LOGIN ]; then
    source $HOST_LOGIN
fi
