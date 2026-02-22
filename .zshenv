# env
export LANG=en_US.UTF-8
export PATH=~/.dotfiles/bin:$PATH
export PATH=~/.dotfiles/bin/`uname -sm | sed "s/ /-/"`:$PATH
export PATH=~/.dotfiles.priv/bin:$PATH
export PATH=~/.dotfiles.priv/`hostname -s`/bin:$PATH

export PATH="$HOME/.local/bin:$PATH"

HOST_ENV=~/.dotfiles.priv/`hostname -s`/.zshenv
if [ -f $HOST_ENV ]; then
    source $HOST_ENV
fi

if [ -d ~/.rbenv ]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi

if [ -d "$HOME/.pyenv" ] && [ -n "$PYENV_ROOT" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

if [ -d ~/.nvm ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi
