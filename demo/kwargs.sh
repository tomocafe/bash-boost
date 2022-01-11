#!/usr/bin/env bash

# Demo: using keyword arguments (kwargs)

source ../latest/bash-boost.sh

bb_load util/kwargs
bb_load util/string

# Usage: listify [indent=2] [bullet=*] ITEMS ...
listify () {
    bb_kwparse opts "$@"
    set -- "${BB_OTHERARGS[@]}" # $@ now only contains non-kwargs

    local indent
    bb_repeatstr -v indent ${opts[indent]:-2} " "

    local bullet
    bullet="${opts[bullet]:-*}"

    echo "List"
    echo "----"

    local item
    for item in "$@"; do
        echo "$indent$bullet $item"
    done
}

# Using all defaults
listify milk eggs bread

# Using custom indent
listify indent=4 milk eggs bread

# Using custom indent and bullet
listify indent=4 bullet="-" milk eggs bread
