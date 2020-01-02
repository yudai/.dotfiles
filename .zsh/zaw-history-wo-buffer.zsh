zmodload zsh/parameter

function zaw-src-history-wo-buffer() {
    if zstyle -t ':filter-select' hist-find-no-dups ; then
        candidates=(${(@vu)history})
        src_opts=("-m")
    else
        cands_assoc=("${(@kv)history}")
        # have filter-select reverse the order (back to latest command first).
        # somehow, `cands_assoc` gets reversed while `candidates` doesn't.
        src_opts=("-r" "-m")
    fi
    actions=("zaw-callback-append-to-buffer" "zaw-callback-execute" "zaw-callback-replace-buffer")
    act_descriptions=("append to edit buffer" "execute" "replace edit buffer")

    if (( $+functions[zaw-bookmark-add] )); then
        # zaw-src-bookmark is available
        actions+="zaw-bookmark-add"
        act_descriptions+="bookmark this command line"
    fi
}

zaw-register-src -n history-wo-buffer zaw-src-history-wo-buffer
