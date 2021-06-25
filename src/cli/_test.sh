testcmd() {
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

    nums=( $(bb_cli_arg_getpositionals) )
    for pos in "${nums[@]}"; do
        echo "posarg=$pos"
    done
}

call1="$(testcmd)"
bb_expect "$call1" "foo=bar"

call2="$(testcmd -f call2)"
bb_expect "$call2" "foo=call2"

call3="$(testcmd --foo call3)"
bb_expect "$call3" "foo=call3"

call4="$(testcmd --foo=call4)"
bb_expect "$call4" "foo=call4"

call5="$(testcmd --foo=call5)"
bb_expect "$call5" "foo=call5"

call6="$(testcmd -x)"
bb_expect "$call6" "foo=call6\nsaw extra"

