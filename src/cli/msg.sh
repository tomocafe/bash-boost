# @package: cli/msg
# Messaging routines

_bb_onfirstload "bb_cli_msg" || return

bb_load "cli/color"

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# bb_info MESSAGE
# Prints an informational message to stderr
# @arguments:
# - MESSAGE: message to be printed
function bb_info () {
    echo "info: $1" 1>&2
}

# bb_warn MESSAGE
# Prints a warning message to stderr
# @arguments:
# - MESSAGE: message to be printed
function bb_warn () {
    bb_colorize 'yellow' 'warning:' 1>&2
    echo " $1" 1>&2
}

# bb_error MESSAGE
# Prints an error message to stderr
# @arguments:
# - MESSAGE: message to be printed
function bb_error () {
    bb_colorize 'bright_red' 'error:' 1>&2
    echo " $1" 1>&2
}

# bb_fatal MESSAGE [RETURNCODE]
# Prints an error message to stderr and then exits the shell
# @arguments:
# - MESSAGE: message to be printed
# - RETURNCODE: return code to exit with (defaults to 1)
function bb_fatal () {
    bb_colorize 'bright_red' 'fatal error:' 1>&2
    echo " $1" 1>&2
    bb_issourced && return ${2:-1} || exit ${2:-1}
}

# bb_expect VAL1 VAL2 [MESSAGE] [RETURNCODE]
# Issues a fatal error if two given values are not equal
# @arguments:
# - VAL1: value to check
# - VAL2: value to check against (golden answer)
# - MESSAGE: optional prefix to the error message
# - RETURNCODE: return code to exit with (defaults to 1)
function bb_expect () {
    [[ "$1" == "$2" ]] || bb_fatal "${3:+$3: }expected $2 got $1" $4
}

# bb_expectsubstr VAL1 VAL2 [MESSAGE] [RETURNCODE]
# Issues a fatal error if a given substring is not found in some given text
# @arguments:
# - VAL1: text to check
# - VAL2: substring to be found
# - MESSAGE: optional prefix to the error message
# - RETURNCODE: return code to exit with (defaults to 1)
function bb_expectsubstr () {
    [[ "$1" =~ "$2" ]] || bb_fatal "${3:+$3: }expected substring $2 got $1" $4
}
