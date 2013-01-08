# keychain
if ((which keychain > /dev/null) && [ -f ~/.ssh/id_rsa ]); then
    /usr/bin/keychain -q ~/.ssh/id_rsa
    source ~/.keychain/$HOST-sh
fi

