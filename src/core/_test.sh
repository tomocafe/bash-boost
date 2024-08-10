################################################################################
# core
################################################################################

showargs () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    echo "$*"
}

bb_expect "$(showargs -- "hello" -)" "hello -"

bb_expect "$(printf "foo\nbar\nbaz\n" | showargs "hello" "world" -)" "hello world foo bar baz"

__bb_glopts_no_trailing_dash=1
bb_expect "$(showargs "hello" "world" -)" "hello world -"

