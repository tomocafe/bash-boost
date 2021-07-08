################################################################################
# cli/arg
################################################################################

function testcmd () {
    bb_cli_arg_addopt "f:foo" "This is the foo arg (default: bar)" "bar"
    bb_cli_arg_addflag "x:extra" "Use this to print an extra message"

    bb_cli_arg_setprog "testcmd"
    bb_cli_arg_setpositional "NUMS" "List of integers"
    bb_cli_arg_parseargs "$@"

    foo="$(bb_cli_arg_getopt foo)"
    echo "foo=$foo"

    if bb_cli_arg_checkopt "extra"; then
        echo "saw extra"
    fi

    posargs=( $(bb_cli_arg_getpositionals) )
    for pos in "${posargs[@]}"; do
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

__bb_tmp_colorized="$(bb_cli_color_colorize red hello)"
bb_expect "${#__bb_tmp_colorized}" "5" "colorize"
__bb_tmp_colorized="$(bb_cli_color_rawcolor red hello)"
bb_expect "${#__bb_tmp_colorized}" "14" "rawcolor"
__bb_tmp_colorstripped="$(bb_cli_color_colorstrip "$__bb_tmp_colorized")"
bb_expect "${#__bb_tmp_colorstripped}" "5" "colorstrip"
unset __bb_tmp_colorized
unset __bb_tmp_colorstripped
