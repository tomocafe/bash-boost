# @package: cli/msg
# Messaging routines

_bb_onfirstload "bb_cli_msg" || return

bb_load "cli/color"
bb_load "util/time"
bb_load "util/string"

################################################################################
# Globals
################################################################################

__bb_cli_msg_log_level=0

declare -Ag __bb_cli_msg_log_level_names

################################################################################
# Functions
################################################################################

# function: bb_info MESSAGE
# Prints an informational message to stderr
# @arguments:
# - MESSAGE: message to be printed
function bb_info () {
    bb_colorize 'cyan' 'info:' 1>&2
    echo " $1" 1>&2
}

# function: bb_warn MESSAGE
# Prints a warning message to stderr
# @arguments:
# - MESSAGE: message to be printed
function bb_warn () {
    bb_colorize 'yellow' 'warning:' 1>&2
    echo " $1" 1>&2
}

# function: bb_error MESSAGE
# Prints an error message to stderr
# @arguments:
# - MESSAGE: message to be printed
function bb_error () {
    bb_colorize 'bright_red' 'error:' 1>&2
    echo " $1" 1>&2
}

# function: bb_fatal MESSAGE [RETURNCODE]
# Prints an error message to stderr and then exits the shell
# @arguments:
# - MESSAGE: message to be printed
# - RETURNCODE: return code to exit with (defaults to 1)
function bb_fatal () {
    bb_colorize 'bright_red' 'fatal error:' 1>&2
    echo " $1" 1>&2
    bb_issourced && return "${2:-1}" || exit "${2:-1}"
}

# function: bb_expect VAL1 VAL2 [MESSAGE] [RETURNCODE]
# Issues a fatal error if two given values are not equal
# @arguments:
# - VAL1: value to check
# - VAL2: value to check against (golden answer)
# - MESSAGE: optional prefix to the error message
# - RETURNCODE: return code to exit with (defaults to 1)
function bb_expect () {
    [[ "$1" == "$2" ]] || bb_fatal "${3:+$3: }expected \`$2' got \`$1'" "$4"
}

# function: bb_expectsubstr TEXT PATTERN [MESSAGE] [RETURNCODE]
# Issues a fatal error if a given substring is not found in some given text
# @arguments:
# - TEXT: text to check
# - PATTERN: substring to be found
# - MESSAGE: optional prefix to the error message
# - RETURNCODE: return code to exit with (defaults to 1)
function bb_expectsubstr () {
    [[ "$1" == *"$2"* ]] || bb_fatal "${3:+$3: }expected substring \`$2' got \`$1'" "$4"
}

# function: bb_expectre TEXT PATTERN [MESSAGE] [RETURNCODE]
# Issues a fatal error if text does not match the given regular expression
# @arguments:
# - TEXT: text to check
# - PATTERN: regular expression
# - MESSAGE: optional prefix to the error message
# - RETURNCODE: return code to exit with (defaults to 1)
function bb_expectre () {
    [[ "$1" =~ $2 ]] || bb_fatal "${3:+$3: }expected match \`$2' got \`$1'" "$4"
}

# function: bb_loglevel [LEVEL]
# Sets the current log level
# @arguments:
# - LEVEL: integer representing the current log verbosity level (default: 0)
function bb_loglevel () {
     __bb_cli_msg_log_level="${1:-0}"
}

# function: bb_setloglevelname LEVEL NAME
# Assigns a name to the given log level
# @arguments:
# - LEVEL: integer representing the current log verbosity level 
# - NAME: name to be assigned
function bb_setloglevelname () {
    __bb_cli_msg_log_level_names["$1"]="$2"
}

# function: bb_log LEVEL MESSAGE
# Issues a message at a certain log level
# @arguments:
# - LEVEL: minimum logging level required to print the message
# - MESSAGE: message to be printed
# @notes:
#   Set BB_LOG_TIMEFMT to a valid time format string to override the default
function bb_log () {
    [[ $1 -gt $__bb_cli_msg_log_level ]] && return
    local ts
    bb_timefmt -v ts "${BB_LOG_TIMEFMT:-%c}"
    local lvlname="${__bb_cli_msg_log_level_names[$1]}"
    local header="[$ts]${lvlname:+ $lvlname:}"
    bb_colorize "blue" "$header"
    echo " $2"
}
