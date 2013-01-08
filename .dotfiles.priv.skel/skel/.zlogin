# keychain
if (which keychain > /dev/null); then
    /usr/bin/keychain -q ~/.ssh/id_rsa
    source ~/.keychain/$HOST-sh
fi

