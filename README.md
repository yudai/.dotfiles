Some dotfiles for GNU screen + zsh + emacs.

How To Use
----------

    $ git clone <URL here>
    $ mv dotfiles .dotfiles
    $ cd .dotfiles
    $ ./ln

The 'ln' command makes symbolic links of the dotfiles in your home directory.

GNU screen
----------
I'm using two screens to save task states.

The outer screen has '^l'(control + l) prefix.
The inner (and for single use) one has '^z'(control + z) prefix.

For detail, see '.screen.parent' for the outer screen and '.screen' for the inner screen.

Useful remote command (like screenshots):
    screen -c .screenrc.parent -AxRU  -S parent  "/<your_home_dir_path>/bin/screen_child"

