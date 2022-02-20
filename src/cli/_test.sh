################################################################################
# cli/arg
################################################################################

function test1 () {
    bb_setprog "test1"
    bb_addopt "f:foo" "This is the foo option (default: bar)" "bar"
    bb_addflag "x:extra" "Use this to print an extra message"
    bb_setpositional "NUMS" "List of integers"

    bb_parseargs "$@"

    local foo
    bb_getopt -v foo foo
    echo "foo=$foo"

    if bb_checkopt "extra"; then
        echo "saw extra"
    fi

    local pos
    for pos in "${BB_POSARGS[@]}"; do
        echo "posarg=$pos"
    done
}

bb_expectsubstr "$(test1 --help 2>&1)" "test1 [-f|--foo FOO] [-x|--extra] [NUMS ...]"

bb_expect "$(test1)" "foo=bar"
bb_expect "$(test1 -f call2)" "foo=call2"
bb_expect "$(test1 --foo call3)" "foo=call3"
bb_expect "$(test1 --foo=call4)" "foo=call4"
bb_expect "$(test1 --foo=call5)" "foo=call5"

bb_expect "$(test1 -x)" "foo=bar
saw extra"

bb_expect "$(test1 --extra)" "foo=bar
saw extra"

bb_expect "$(test1 --foo=call8 hello world)" "foo=call8
posarg=hello
posarg=world"

function test2 () {
    bb_setprog "test2"
    bb_addopt "B:baz" "This is the baz option"
    bb_addarg "x" "x coordinate"
    bb_addarg "y" "y coordinate"
    bb_setpositional "other" "other args"

    bb_parseargs "$@"

    local baz x y
    bb_getopt -v baz baz && echo "baz=$baz"
    bb_getopt -v x x || { bb_errusage "missing required x argument"; return; }
    bb_getopt -v y y || { bb_errusage "missing required y argument"; return; }

    echo "x=$x y=$y"

    local pos
    for pos in "${BB_POSARGS[@]}"; do
        echo "posarg=$pos"
    done
}

bb_expectsubstr "$(test2 --help 2>&1)" "test2 [-B|--baz BAZ] x y [OTHER ...]"
bb_expectsubstr "$(test2 2>&1)" "usage error: missing required x argument"
bb_expectsubstr "$(test2 0 2>&1)" "usage error: missing required y argument"

bb_expect "$(test2 1 2)" "x=1 y=2"

bb_expect "$(test2 3 -B something 4)" "baz=something
x=3 y=4"

bb_expect "$(test2 5 6 7 8)" "x=5 y=6
posarg=7
posarg=8"

################################################################################
# cli/color
################################################################################

__bb_tmp_colorized="$(bb_colorize red hello)"
bb_expect "${#__bb_tmp_colorized}" "5" "colorize"
__bb_tmp_colorized="$(bb_rawcolor red hello)"
bb_expect "${#__bb_tmp_colorized}" "14" "rawcolor"
__bb_tmp_colorstripped="$(bb_colorstrip "$__bb_tmp_colorized")"
bb_expect "${#__bb_tmp_colorstripped}" "5" "colorstrip"
bb_expect "$(bb_colorstrip "$(bb_rawcolor red hello)")" "hello"
bb_expect "$(bb_colorstrip "$(bb_rawcolor red a)b")" "ab"
bb_expect "$(bb_colorstrip "$(bb_promptcolor red world)")" "world"
bb_expect "$(bb_colorstrip "$(bb_promptcolor red x)y")" "xy"
unset __bb_tmp_colorized
unset __bb_tmp_colorstripped

################################################################################
# cli/input
################################################################################

yes | bb_yn
bb_expect "$?" "$__bb_true" "bb_yn y"
yes n | bb_yn
bb_expect "$?" "$__bb_false" "bb_yn n"

################################################################################
# cli/msg
################################################################################

BB_LOG_TIMEFMT="ts" # hardcode time
bb_setloglevelname 2 "special"
bb_expect "$(bb_log 1 "test1")" ""
bb_loglevel 2
bb_expect "$(bb_log 1 "test1")" "[ts] test1"
bb_expect "$(bb_log 2 "test2")" "[ts] special: test2"
