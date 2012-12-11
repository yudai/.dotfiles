if which ruby >/dev/null 2>&1;then
    clear_cdd
fi
HOST_LOGIN=~/.dotfiles.priv/`hostname -s`/.zlogin
if [ -f $HOST_LOGIN ]; then
    source $HOST_LOGIN
fi
