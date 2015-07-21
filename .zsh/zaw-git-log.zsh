#
# zaw-src-git-log
#
#   zaw source for git log.
#
#   zaw : https://github.com/nakamuray/zaw
#

# git log pretty format: For detail, refer to "man git-log"
ZAW_SRC_GIT_LOG_LOG_FORMAT=${ZAW_SRC_GIT_LOG_LOG_FORMAT:-'%ad | %s %d[%an]'}

# If true, print full SHA.
ZAW_SRC_GIT_LOG_NO_ABBREV=${ZAW_SRC_GIT_LOG_NO_ABBREV:-'false'}

# Limit the number of commits to output.
# If set the value less than 1, output unlimitedly.
ZAW_SRC_GIT_LOG_MAX_COUNT=${ZAW_SRC_GIT_LOG_MAX_COUNT:-100}

# Date style (relative, local, iso, rfc, short, raw, default)
ZAW_SRC_GIT_LOG_DATE_STYLE=${ZAW_SRC_GIT_LOG_DATE_STYLE:-'short'}

# The function to regiter to zaw.
function zaw-src-git-log () {
    # Check git directory.
    git rev-parse -q --is-inside-work-tree > /dev/null 2>&1 || return 1

    # Set up option.
    local -a opt
    opt=("--pretty=format:%h $ZAW_SRC_GIT_LOG_LOG_FORMAT")
    if [ "$ZAW_SRC_GIT_LOG_NO_ABBREV" != 'false' ]; then
        opt+=('--no-abbrev')
    fi
    if [ $ZAW_SRC_GIT_LOG_MAX_COUNT -gt 0 ]; then
        opt+=("--max-count=$ZAW_SRC_GIT_LOG_MAX_COUNT")
    fi
    if [ -n "$ZAW_SRC_GIT_LOG_DATE_STYLE" ]; then
        opt+=("--date=$ZAW_SRC_GIT_LOG_DATE_STYLE")
    fi

    git log "${opt[@]}" | \
            while read id desc; do
                candidates+=("${id}")
                cand_descriptions+=("${id} ${desc}")
            done

    # Set candidates.
    candidates+=(${(f)log})
    actions=(zaw-src-git-commit-checkout zaw-src-git-log-append-to-buffer zaw-src-git-commit-reset zaw-src-git-commit-reset-hard zaw-src-git-commit-rebase-interactive zaw-src-git-commit-log-amend)
    act_descriptions=("checkout" "append to edit buffer" "reset" "reset hard" "rebase interactive" "log amend")
    # Enale multi marker.
    options+=(-m)
}
# Action function.
function zaw-src-git-log-append-to-buffer () {
    local buf=
    if [ $# -eq 2 ]; then
        # To diff.
        buf+="$1..$2"
    else
        # 1 or 3 or more items.
        buf+="${(j: :)@}"
    fi
    # Append left buffer.
    LBUFFER+="$buf"
}

function zaw-src-git-commit-log-amend(){
    local hash_val=$(_zaw-src-git-log-strip $1)
    BUFFER="git-log-amend $hash_val"
    zle accept-line
}


# Register this src to zaw.
zaw-register-src -n git-log zaw-src-git-log

