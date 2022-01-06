################################################################################
# cli/arg
################################################################################

function testcmd () {
    bb_addopt "f:foo" "This is the foo arg (default: bar)" "bar"
    bb_addflag "x:extra" "Use this to print an extra message"

    bb_setprog "testcmd"
    bb_setpositional "NUMS" "List of integers"
    bb_parseargs "$@"

    foo="$(bb_getopt foo)"
    echo "foo=$foo"

    if bb_checkopt "extra"; then
        echo "saw extra"
    fi

    for pos in "${BB_POSARGS[@]}"; do
        echo "posarg=$pos"
    done
}

bb_expectsubstr "$(testcmd --help 2>&1)" "testcmd [-f|--foo FOO] [-x|--extra] [NUMS ...]"

bb_expect "$(testcmd)" "foo=bar"
bb_expect "$(testcmd -f call2)" "foo=call2"
bb_expect "$(testcmd --foo call3)" "foo=call3"
bb_expect "$(testcmd --foo=call4)" "foo=call4"
bb_expect "$(testcmd --foo=call5)" "foo=call5"

bb_expect "$(testcmd -x)" "foo=bar
saw extra"

bb_expect "$(testcmd --extra)" "foo=bar
saw extra"

bb_expect "$(testcmd --foo=call8 hello world)" "foo=call8
posarg=hello
posarg=world"

################################################################################
# cli/color
################################################################################

__bb_tmp_colorized="$(bb_colorize red hello)"
bb_expect "${#__bb_tmp_colorized}" "5" "colorize"
__bb_tmp_colorized="$(bb_rawcolor red hello)"
bb_expect "${#__bb_tmp_colorized}" "14" "rawcolor"
__bb_tmp_colorstripped="$(bb_colorstrip "$__bb_tmp_colorized")"
bb_expect "${#__bb_tmp_colorstripped}" "5" "colorstrip"
bb_expect "$(bb_colorstrip "$(bb_promptcolor red hello)")" "hello"
unset __bb_tmp_colorized
unset __bb_tmp_colorstripped

################################################################################
# cli/input
################################################################################

yes | bb_yn
bb_expect "$?" "$__bb_true" "bb_yn y"
yes n | bb_yn
bb_expect "$?" "$__bb_false" "bb_yn n"
