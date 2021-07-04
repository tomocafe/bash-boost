_bb_on_first_load "bb_cli_msg" || return

bb_load "cli/color"

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# info MESSAGE
bb_cli_msg_info () {
    echo "info: $1" 1>&2
}

# warn MESSAGE
bb_cli_msg_warn () {
    bb_cli_color_colorize 'yellow' 'warning:' 1>&2
    echo " $1" 1>&2
}

# error MESSAGE
bb_cli_msg_error () {
    bb_cli_color_colorize 'bright_red' 'error:' 1>&2
    echo " $1" 1>&2
}

# fatal MESSAGE [RETURNCODE]
bb_cli_msg_fatal () {
    bb_cli_color_colorize 'bright_red' 'fatal error:' 1>&2
    echo " $1" 1>&2
    exit ${2:-1}
}

# expect VAL1 VAL2 [MESSAGE] [RETURNCODE]
bb_cli_msg_expect () {
    [[ "$1" == "$2" ]] || bb_cli_msg_fatal "${3:+$3: }expected $2 got $1" $4
}

# expectsubstr VAL1 VAL2 [MESSAGE] [RETURNCODE]
bb_cli_msg_expectsubstr () {
    [[ "$1" =~ "$2" ]] || bb_cli_msg_fatal "${3:+$3: }expected substring $2 got $1" $4
}
