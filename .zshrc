#
# .zshrc is sourced in interactive shells.
# It should contain commands to set up aliases,
# functions, options, key bindings, etc.
#


# when lunced by "sudo -s", load .zprofile to set PATH
if [ x$SUDO_USER != "x" -a x$LOGNAME = "xroot" ]; then
    source ~/.zprofile
fi

autoload -U colors
colors

# load host specific zshrc file
HOST_RC=~/.dotfiles.priv/`hostname -s`/.zshrc
function pre_rc() {}
function post_rc() {}
if [ -f $HOST_RC ]; then
    source $HOST_RC
fi

# default variables
user_color=$fg[yellow]
host_color=$fg_bold[yellow]$bg[cyan]
prompt_color=$fg[red]

# call host specific setting
pre_rc


setopt print_eight_bit

# colors
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jpg=01;35:*.png=01;35:*.gif=01;35:*.bmp=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.png=01;35:*.mpg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:'
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}


# prompt
setopt prompt_subst
PROMPT="%{%(!.%{$fg[white]%}.$user_color)%}${USER}%{$host_color%}@${HOST%%.*}%{$reset_color%}%{%(!.$fg_bold[white].$prompt_color)%}%(!.#.%%)%{$reset_color%} "
RPROMPT="%1(v|%F{green}%1v%f|)%{%(!.$fg_bold[white].$fg[yellow])%}[%~]%{$reset_color%}"

function chpwd() {
    update_title $last_command1
    # cdd
    _reg_pwd_screennum_ruby
}

# title
function update_title() {
    cmd=(${(z)1})
    case $cmd[1] in
        fg)
            if (( $#cmd == 1)); then
                cmd=(builtin jobs -l %+)
            else
                cmd=(builtin jobs -l $cmd[2])
            fi
            ;;
        sudo)
            cmd="$cmd[1] $cmd[2]"
            ;;
        ssh)
            cmd="$cmd[1] $cmd[2]"
            ;;
        *)
            cmd=$cmd[1]
            ;;
    esac
    if [ x"$STY" != x"" ]; then # for screen hack
        title="[$(basename $(pwd))] $cmd"
        echo -ne "\ek$title\e\\"
        print -n "\e]0;$title\a"
    elif [ x"${TERM%%-*}" = x"xterm" ]; then
        title="[$(basename $(pwd))@${HOST%%.}] $cmd"
        print -n "\e]0;$title\a"
    fi
}
preexec () {
    update_title $1
    last_command1=$1
}
last_command1=zsh
update_title last_command1


# VCS
autoload -Uz vcs_info
zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr "# "
zstyle ':vcs_info:*' unstagedstr "+ "
zstyle ':vcs_info:*' formats '(%c%u%s:%b@%10.10i)'
zstyle ':vcs_info:*' actionformats '(%c%u%s:%b@i|%a)'

precmd () {
    #title
    update_title $last_command1 $last_command2
    #VCS
    psvar=()
    LANG=en_US.UTF-8 vcs_info
    [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
}


# history
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt hist_ignore_dups     # ignore duplication command history list
setopt share_history        # share command history data
setopt append_history
setopt extended_history
setopt hist_ignore_space

# Emacs
bindkey -e
bindkey "^ " set-mark-command
bindkey "^w" kill-region
bindkey "\Mw" copy-region-as-kill
bindkey "/" expand-word

# misc
setopt COMPLETE_IN_WORD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt PUSHD_TO_HOME

#setopt correct
setopt list_packed
setopt nolistbeep
setopt auto_param_slash
setopt ignore_eof

# 
autoload -U compinit
compinit
setopt extended_glob
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
setopt auto_menu
setopt magic_equal_subst
setopt list_types


# word defenition (remove / from default)
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'


# alias
alias emacs="LANG=ja_JP.utf8 emacs"
alias lv="LANG=ja_JP.utf8 lv"
alias pd='popd'
alias sc='screen -xRU -S'
alias rhino='java -jar /usr/share/java/js.jar'
alias irssi='LANG=ja_JP.utf8 irssi'
alias gmk='gnatmake -gnaty3abefhiklM120nprt'

alias ls='ls --color=auto'
alias la='ls -a  --color=auto'
alias ll='ls -al --color=auto'

alias gl="tig"
alias gll="tig --all"
alias glp="git log -p"
alias gco='git checkout'
alias gcot='git checkout -t'
alias gcob='git checkout -b'
alias gci='git commit --verbose'
alias gcimend='git status -sb; if [ $(git status -s | grep -c -e "^[^ ]") -gt 0  ]; then git commit --amend -C HEAD; else echo $fg[red]Nothing changed. Aborting...$default_color; fi;'
alias gcimendd='git commit --amend --verbose'
alias gbr='git branch'
alias ga='git add'
alias gaa='git add -u && git status -sb'
alias gaaa='git add . && git status -sb'
alias gap='git add -p'
alias gpu='git push'
gpuu() { git push -u $1 `git rev-parse --abbrev-ref HEAD` }
alias gpuf='git push -f'
alias gs='git status'
alias gsh='git stash'
alias gshp='git stash pop'
alias gsu='git submodule'
alias gsuu='git submodule sync && git submodule update --init --recursive'
alias gpl='git pull'
alias gplr='git pull --rebase'
alias gd='git diff'
alias gdw='git diff --word-diff'
alias gdd='git diff HEAD'
alias gddw='git diff HEAD --word-diff'
alias gdc='git diff --cached'
alias gdcw='git diff --cached --word-diff'
alias gddw='git diff HEAD --word-diff'
alias gdh='git diff HEAD\^ HEAD'
alias gdhw='git diff HEAD\^ HEAD --word-diff'
alias gg='git grep -i -n -F'
alias ggr='git grep -i -n -P'
alias gfe='git fetch'
alias gcp='git cherry-pick'
alias grb='git rebase'
alias grbco='git rebase --continue'
alias grs='git reset'
alias grl='git reflog'
alias gbl='tig blame'

alias be='bundle exec'
alias reload='exec zsh -l'
alias update-dotfiles='exec update-dotfiles'

alias tiga='tig --all'

# bundler exec
[ -f ~/.zsh/.bundler-exec.sh ] && source ~/.zsh/.bundler-exec.sh

# search
stty stop undef
bindkey '^R' history-incremental-pattern-search-backward
bindkey '^S' history-incremental-pattern-search-forward

autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
bindkey "^[r" history-beginning-search-backward-end
bindkey "^[s" history-beginning-search-forward-end

if [ "$SHLVL" != "1" ]; then
    alias screen='screen -c .screenrc.remote'
fi


# cdd
function _reg_pwd_screennum_ruby() {}
if which ruby >/dev/null 2>&1;then
    source ~/.zsh/cdd
    _reg_pwd_screennum
    function _reg_pwd_screennum_ruby() {
        _reg_pwd_screennum
    }
fi

# cd ../ with ^
function cdup-or-insert-circumflex() {
  if [[ -z "$BUFFER" ]]; then
    echo
    cd ..
    zle reset-prompt
  else
    zle self-insert '^'
  fi
}
zle -N cdup-or-insert-circumflex
bindkey '\^' cdup-or-insert-circumflex

export LESS='-R'
export LESSOPEN='| /usr/share/source-highlight/src-hilite-lesspipe.sh %s'
post_rc

# zaw
source ~/.zsh/zaw/zaw.zsh
zstyle ':filter-select' extended-search yes
zstyle ':filter-select:highlight' matched fg=yellow,standout
zstyle ':filter-select' max-lines -10
bindkey "^X:" zaw
bindkey "^X^H" zaw-history
bindkey "^X^B" zaw-git-branches
source ~/.zsh/zaw-git-log.zsh
bindkey '^X^L' zaw-git-log
source ~/.zsh/zaw-git-reflog.zsh
bindkey '^X^R' zaw-git-reflog

# cdr
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-max 5000
zstyle ':chpwd:*' recent-dirs-default yes
zstyle ':completion:*' recent-dirs-insert both
