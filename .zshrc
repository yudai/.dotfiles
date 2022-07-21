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
vcs_color="%{$reset_color%}%{$fg[green]%}"

function go_info() {
    if [ -n "$GVM_ROOT" ]; then
        pkgname=$gvm_pkgset_name
        if [ "$pkgname" = "__local__" ]; then
            pkgname="%{$fg_bold[blue]%}local"
        fi
        go_info_msg="%{$fg[blue]%}($gvm_go_name@$pkgname%{$reset_color%}%{$fg[blue]%})%{$reset_color%}"
    fi
}

function update_prompt_border() {
    if [ ${LAST_COLUMNS} != ${COLUMNS} ]; then
        prompt_border="%F{238}"
        for i in {1..$COLUMNS}; do prompt_border+="₋"; done
        prompt_border+="%f"
        LAST_COLUMNS=$COLUMNS
    fi
}
LAST_COLUMNS=0

# prompt
setopt PROMPT_SUBST
PROMPT="%{%(!.%{$fg[white]%}.$user_color)%}%n%{$host_color%}@%m%{$reset_color%}%{%(!.$fg_bold[white].$prompt_color)%}%(!.#.%%)%{$reset_color%} "

# VCS
fpath=(~/.zsh $fpath)
autoload -Uz vcs_info
zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr "%{$fg_bold[green]%}#${vcs_color}"
zstyle ':vcs_info:*' unstagedstr "%{$fg_bold[red]%}+${vcs_color}"
zstyle ':vcs_info:*' formats "${vcs_color}(%s:%b@%10.10i%m%c%u${vcs_color})"
zstyle ':vcs_info:*' actionformats "${vcs_color}(%s:%b@%10.10i|%{$fg[red]%}%a${vcs_color}%m%c%u${vcs_color})"

# http://www.opensource.apple.com/source/zsh/zsh-55/zsh/Misc/vcs_info-examples
zstyle ':vcs_info:git*+set-message:*' hooks git-stash-count  git-st git-untracked 
function +vi-git-st() {
    local ahead behind stash
    local -a gitstatus
    ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l | tr -d ' ')
    (( $ahead )) && gitstatus+=( "%{$fg[yellow]%}+${ahead}${vcs_color}" )

    behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l | tr -d ' ')
    (( $behind )) && gitstatus+=( "%{$fg[red]%}-${behind}${vcs_color}" )

    stash=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
    (( $stash )) && gitstatus+=( "%{$fg[cyan]%}@${stash}${vcs_color}" )

    hook_com[misc]+="${(j:/:)gitstatus}"
    if [ ${#hook_com[misc]} -ne 0 ]; then hook_com[misc]="|${hook_com[misc]}"; fi
}

# http://www.zsh.org/mla/workers/2011/msg00554.html
function +vi-git-untracked() {
    if (git status --porcelain | grep '??' &> /dev/null) ; then
        hook_com[unstaged]+="%{$fg_bold[cyan]%}?$vcs_color"
    fi
    if [ ${#hook_com[staged]} -ne 0 ] || [ ${#hook_com[unstaged]} -ne 0 ]; then
        hook_com[staged]="|${hook_com[staged]}"
    fi
}

function chpwd() {
    _cdd_chpwd
    update_title 0
}

function fix-title() {
    export FIX_TITLE=$1
    update_title 0
}

function unfix-title() {
    unset FIX_TITLE
    update_title 0
}


function update_title() {
    cargs=(${(z)LAST_COMMAND})
    cmd=$cargs[1]

    if [ "${cmd}" = "fg" -a "$(jobs | wc -l)" != 0 ]; then
        LAST_COMMAND=$(cat /proc/$(jobs -l | tail -n 1 | awk '{ print $3 }')/cmdline  | tr '\000' ' ' | sed 's/ $//')
        update_title $1
        return
    fi

    dirname="$(basename ${PWD})"
    dirname_len=${#dirname}
    if [ $dirname_len -gt 14 ]; then
        dirname=${dirname:0:6}..${dirname:$(( $dirname_len - 6 )):6}
    fi
    flag=
    if [ "$1" -eq 1 ]; then
        LAST_COMMAND_TIME=`date +%s`
        case "$cmd" in
            ls|cd)
                # too noisy
            ;;
            *)
                flag="*"
                ;;
        esac
    else
        NOW=`date +%s`
        if [ -n "${TMUX}" ] && (( ${NOW} - ${LAST_COMMAND_TIME} > 3 )); then
            if [ "$(tmux display -p '#{window_active}')" -eq "0" ]; then
                tmux display "${cmd} finished at #{window_index}"
                flag="!"
            fi

            if (tmux -L parent display -p "" 1>/dev/null 2>&1); then
                if [ "$(tmux -L parent display -p '#{window_name}')" != "$(tmux display -p '#{session_name}')" ]; then
                    tmux -L parent display "${cmd} finised at #{window_name}"
                fi
            fi
        fi
    fi

    title="[${dirname}]${flag}${cmd}"
    if [ -n "${FIX_TITLE}" ]; then
        title="${FIX_TITLE}"
    fi

    echo -ne "\e]0;$title\a"
}
LAST_COMMAND=zsh
LAST_COMMAND_TIME=`date +%s`
update_title 0

preexec () {
    LAST_COMMAND=$1
    update_title 1
}
LAST_PWD=
PWD_CHANGED=1

# dattetime
zmodload zsh/datetime

precmd () {
    last_code=$?

    if [ "$LAST_PWD" != "$PWD" ]; then
        PWD_CHANGED=1
    else
        PWD_CHANGED=0
    fi
    LAST_PWD=$PWD

    #VCS
    vcs_info
    go_info
    update_prompt_border

    update_title 0

    prop="${prompt_border}"
    prop+="["
    if [ "$last_code" != "0" ]; then
        prop+=$fg[red]
    else
        prop+=$fg[blue]
    fi
    prop+="${last_code}%{$reset_color%}][%{%(!.$fg_bold[white].$fg[yellow])%}$PWD%{$reset_color%}]"
    prop+="${vcs_info_msg_0_}${go_info_msg}${ruby_info_msg}"
    echo "${(%)prop}"
}

# complete
autoload -U compinit && compinit -u
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
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE

up-line-or-local-history() {
    zle set-local-history 1
    zle up-line-or-history
    zle set-local-history 0
}
zle -N up-line-or-local-history
down-line-or-local-history() {
    zle set-local-history 1
    zle down-line-or-history
    zle set-local-history 0
}
zle -N down-line-or-local-history
bindkey "^p" up-line-or-local-history
bindkey "^n" down-line-or-local-history

# pushd
DIRSTACKSIZE=100
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# misc
setopt PRINT_EIGHT_BIT
setopt IGNORE_EOF
setopt EXTENDED_GLOB

# last argument
autoload -Uz copy-earlier-word
zle -N copy-earlier-word
bindkey "^[m" copy-earlier-word

# Emacs Keymap
bindkey -e
bindkey "^ " set-mark-command
bindkey "^w" kill-region
bindkey "/" expand-word
bindkey "[Z" reverse-menu-complete
# http://qiita.com/takc923/items/35d9fe81f61436c867a8
function copy-region() {
    zle copy-region-as-kill
    REGION_ACTIVE=0
}
zle -N copy-region
bindkey "^[w" copy-region
function delete-region() {
    zle kill-region
    CUTBUFFER=$killring[1]
    shift killring
}
zle -N delete-region

function backward-delete-char-or-region() {
    if [ $REGION_ACTIVE -eq 0 ]; then
        zle backward-delete-char
    else
        zle delete-region
    fi
}
zle -N backward-delete-char-or-region
bindkey "^h" backward-delete-char-or-region

# word defenition (remove / from default)

# alias
alias emacs="emacs"
alias lv="LANG=ja_JP.UTF-8 lv"
alias pd='popd'
alias sc='screen -xRU -S'
alias rhino='java -jar /usr/share/java/js.jar'
alias irssi='LANG=ja_JP.UTF-8 irssi'
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
alias gcimend='git --no-pager diff --cached; git status -sb; \
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
alias gpuf='git push --force-with-lease'
alias gpuff='git push -f'
alias gs='git status'
alias gss='tig status'
alias gsb='git show-branch --sha1-name --topo-order'
alias gsbc='git show-branch --sha1-name --topo-order `git rev-parse --abbrev-ref HEAD`'
alias gsbm='git show-branch --sha1-name `git rev-parse --abbrev-ref HEAD` origin/master'
alias gsh='git stash'
alias gshh='tig stash'
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
alias gg='tig grep -i -n -F'
alias ggg='git grep -i -n -F'
ggp() { git grep -i -n -F $* | peco }
alias ggr='git grep -i -n -P'
alias gfe='git fetch'
alias gfea='git fetch --all'
alias gcp='git cherry-pick'
alias grb='git rebase'
alias grbonto='git rebase --onto'
alias grbco='git rebase --continue'
grbi() { git rebase -i HEAD~$1 }
alias grs='git reset'
alias grl='git reflog'
alias gre='git remote'
alias grev='git remote -v'
alias gbl='tig blame'
alias gmr='git merge --ff-only'
alias gmrnf='git merge --no-ff'
alias gcl='git clean -f -d'
alias gha='git-history-amend'
alias cdg='cd $(git rev-parse --show-toplevel)'

alias be='bundle exec'
alias reload='if [ -z "`jobs`" ]; then exec zsh -l; fi'
alias update-dotfiles='exec update-dotfiles'

alias tiga='tig --all'

# bundler exec
[ -f ~/.zsh/.bundler-exec.sh ] && source ~/.zsh/.bundler-exec.sh

stty stop undef


function peco-select-history() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi
    BUFFER=$(history -n 1 | \
        eval $tac | \
        peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history
bindkey '^x^s' peco-select-history

# cdd
. ~/.zsh/cdd

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
path=(/usr/share/source-highlight(N-/) $path)
export LESSOPEN='| src-hilite-lesspipe.sh %s'
post_rc

# cdr
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-max 5000
zstyle ':chpwd:*' recent-dirs-default yes
zstyle ':completion:*' recent-dirs-insert both

# zaw
source ~/.zsh/zaw/zaw.zsh
zstyle ':filter-select' hist-find-no-dups yes
zstyle ':filter-select' extended-search yes
zstyle ':filter-select' max-lines -10
bindkey "^X:" zaw
bindkey "^R" zaw-history
bindkey "^X^B" zaw-git-branches
bindkey '^X^R' zaw-git-reflog
source ~/.zsh/zaw-git-log.zsh
bindkey '^X^L' zaw-git-log
bindkey '^X^S' zaw-git-status
bindkey '^X^X' zaw-cdr

# editor
export EDITOR=vi

export GO111MODULE=on
export PATH=$HOME/go/bin:$PATH

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/yudai/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/yudai/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/yudai/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/yudai/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
