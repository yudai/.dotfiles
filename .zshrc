# when launced by "sudo -s", load .zprofile to set PATH
if [ x$SUDO_USER != "x" -a x$LOGNAME = "xroot" ]; then
    source ~/.zprofile
fi

# default prompt colors
autoload -U colors && colors
user_color=$fg[yellow]
host_color=$fg_bold[yellow]$bg[cyan]
prompt_color=$fg[red]

# load host specific zshrc file
HOST_RC=~/.dotfiles.priv/`hostname -s`/.zshrc
function pre_rc() {}
function post_rc() {}
if [ -f $HOST_RC ]; then
    source $HOST_RC
fi

# call host specific setting
pre_rc

# colors
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jpg=01;35:*.png=01;35:*.gif=01;35:*.bmp=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.png=01;35:*.mpg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:'

# prompt
setopt PROMPT_SUBST
PROMPT="%{%(!.%{$fg[white]%}.$user_color)%}%n%{$host_color%}@%m%{$reset_color%}%{%(!.$fg_bold[white].$prompt_color)%}%(!.#.%%)%{$reset_color%} "
RPROMPT="%1(v|%F{green}%1v%f|)%{%(!.$fg_bold[white].$fg[yellow])%}[%~]%{$reset_color%}(%(?.%?.%{$fg[red]%}%?%{$reset_color%}))"

# VCS
fpath=(~/.zsh $fpath)
autoload -Uz vcs_info
autoload -Uz VCS_INFO_get_data_git
zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr "# "
zstyle ':vcs_info:*' unstagedstr "+ "
zstyle ':vcs_info:*' formats '(%m%c%u%s:%b@%10.10i)'
zstyle ':vcs_info:*' actionformats '(%m%c%u%s:%b@i|%a)'

# http://www.opensource.apple.com/source/zsh/zsh-55/zsh/Misc/vcs_info-examples
zstyle ':vcs_info:git*+set-message:*' hooks git-st git-untracked
function +vi-git-st() {
    local ahead behind
    local -a gitstatus

    ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
    (( $ahead )) && gitstatus+=( "+${ahead}" )

    behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)
    (( $behind )) && gitstatus+=( "-${behind}" )

    hook_com[misc]+="${(j:/:)gitstatus}"
    if [ ${#gitstatus} -gt 0 ]; then hook_com[misc]+=' '; fi
}

# http://www.zsh.org/mla/workers/2011/msg00554.html
function +vi-git-untracked() {
    if (git status --porcelain | grep '??' &> /dev/null) ; then
        hook_com[staged]+='? '
    fi
}

function chpwd() {
    update_title 1 $last_command1
    _reg_pwd_screennum_ruby # cdd
}

# title
function update_title() {
    cmd=(${(z)2})
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

    dirname=$(basename $(pwd))
    dirname_len=${#dirname}
    if [ $dirname_len -gt 14 ]; then
        short_dirname=${dirname:0:6}..${dirname:$(( $dirname_len - 6 )):6}
    else
        short_dirname=$dirname
    fi
    paren=(\[ \* \] \*)
    paren_left=$1
    paren_right=$(($paren_left + 2))
    if [ x"$STY" != x"" ]; then # for screen hack
        echo -ne "\e]0;$paren[$paren_left]${short_dirname}$paren[$paren_right] $cmd\a"
        print -n "\ek$paren[$paren_left]${dirname}$paren[$paren_right] $cmd\e\\"
    elif [ x"${TERM%%-*}" = x"xterm" ]; then
        title="$paren[$paren_left]${short_dirname}@${HOST%%.}$paren[$paren_right] $cmd"
        print -n "\e]0;$title\a"
    fi
}
preexec () {
    update_title 2 $1
    last_command1=$1
}
last_command1=zsh
update_title 1 last_command1

# dattetime
zmodload zsh/datetime
pre_time=$EPOCHSECONDS

precmd () {
    last_code=$?
    # auto reload .dotfiles
    cur_time=$EPOCHSECONDS
    duration=$(($cur_time - $pre_time))
    if [ ${duration} -gt 360 ]; then
        if [ -z "`jobs`" ]; then exec zsh -l; fi
    fi
    pre_time=$cur_time

    #title
    update_title 1 $last_command1 $last_command2
    #VCS
    psvar=()
    LANG=en_US.UTF-8 vcs_info
    [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"

    # when done in a background window
    if ( [ -n "$STY" ] && ( [ ${duration} -gt 5 ] || [ $last_code -ne 0  ] ) ); then
        parent_exist=no
        if (screen -ls | grep -q parent ); then
            parent_exist=yes
        fi
        parent_window=`screen -Q echo '$WINDOW'`
        if ( [ ${parent_exist} = "yes" ] && [ "${parent_window}" != "" ] && [ $(ruby -e "print '`screen -S parent -Q windows`'.split('  ').find { |t| t.match(/^\d+\*/)}.split('*')[0]") -ne ${parent_window} ] ) \
            || [ $(ruby -e "print '`screen -Q windows`'.split(/\s+?(?=\d[&*]*\\$)/).find { |t| t.match(/^\d+?\*/)}.split('*')[0]") -ne "$WINDOW" ]; then
            if [ ${parent_exist} = "yes" ]; then
                parent_flag=(-S parent)
            fi
            screen ${parent_flag} -X echo "!! Background command \`${cmd}\` completed at ${parent_window}/${WINDOW} !!"
            echo -ne "[$last_code] $cmd\a"
        fi
    fi
}

# complete
autoload -U compinit && compinit
setopt COMPLETE_IN_WORD
setopt GLOB_COMPLETE
setopt LIST_PACKED
setopt LIST_TYPES
setopt NOLISTBEEP
setopt MAGIC_EQUAL_SUBST
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# history
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE

# pushd
DIRSTACKSIZE=100
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# misc
setopt PRINT_EIGHT_BIT
setopt IGNORE_EOF
setopt EXTENDED_GLOB

# Emacs Keymap
bindkey -e
bindkey "^ " set-mark-command
bindkey "^w" kill-region
bindkey "\Mw" copy-region-as-kill
bindkey "/" expand-word
bindkey "[Z" reverse-menu-complete

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

alias gl="tig log"
alias gll="tig"
alias glla="tig --all"
alias glp="git log -p"
alias glg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow bold)%d%Creset %s %Cgreen(%ci, %cr) %C(cyan)<%an>%Creset' --abbrev-commit"
alias gllg="git log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow bold)%d%Creset %s %Cgreen(%ci, %cr) %C(cyan)<%an>%Creset' --abbrev-commit"
alias gco='git checkout'
alias gcot='git checkout -t'
alias gcob='git checkout -b'
alias gci='git commit --verbose'
alias gcimend='git status -sb; \
               if [ $(git status -s | grep -c -e "^[^ ]") -gt 0 ]; then; \
                  if [ -f $(git rev-parse --git-dir)/MERGE_MSG ]; then; \
                     echo $fg[red]Merge in progress. Aborting...$default_color; \
                  else; \
                     git commit --amend -C HEAD; \
                  fi; \
               else; \
                  echo $fg[red]Nothing changed. Aborting...$default_color; \
               fi;'
alias gcimendd='git commit --amend --verbose'
alias gbr='git branch'
alias ga='git add'
alias gaa='git add -u && git status -sb'
alias gaaa='git add . && git status -sb'
alias gap='git add -p'
alias gpu='git push'
gpuu() { git push -u ${@:-origin} `git rev-parse --abbrev-ref HEAD` }
gpuuf() { git push -f -u ${@:-origin} `git rev-parse --abbrev-ref HEAD` }
alias gpuf='git push -f'
alias gs='git status'
alias gsh='git stash'
alias gpp='git stash pop'
alias gsu='git submodule'
alias gsuu='git submodule sync && git submodule update --init --recursive'
alias gpl='git pull --ff-only'
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
alias grbonto='git rebase --onto'
alias grbco='git rebase --continue'
grbi() { git rebase -i HEAD~$1 }
alias grs='git reset'
alias grl='git reflog'
alias gbl='tig blame'
alias gmr='git merge'
alias gmrnf='git merge --no-ff'
alias gcl='git clean -f -d'

alias be='bundle exec'
alias reload='if [ -z "`jobs`" ]; then exec zsh -l; fi'
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
bindkey '^X^R' zaw-git-reflog
source ~/.zsh/zaw-git-log.zsh
bindkey '^X^L' zaw-git-log

# cdr
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-max 5000
zstyle ':chpwd:*' recent-dirs-default yes
zstyle ':completion:*' recent-dirs-insert both

# editor
export EDITOR=vi
