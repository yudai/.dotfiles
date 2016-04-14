# env
export LANG=en_US.UTF-8
export PATH=~/.dotfiles/bin:$PATH
export PATH=~/.dotfiles/bin/`uname -sm | sed "s/ /-/"`:$PATH
export PATH=~/.dotfiles.priv/bin:$PATH
export PATH=~/.dotfiles.priv/`hostname -s`/bin:$PATH

HOST_ENV=~/.dotfiles.priv/`hostname -s`/.zshenv
if [ -f $HOST_ENV ]; then
    source $HOST_ENV
fi

if [ -d ~/.rbenv ]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi

if [ -d ~/.pyenv ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
