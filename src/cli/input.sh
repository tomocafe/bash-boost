# @package: cli/input
# Routines for handling user input

_bb_onfirstload "bb_cli_input" || return

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# getinput VAR PROMPT
# Prompts for input and saves the response to VAR
# @arguments:
# - VAR: variable to store response into (do not include $)
# - PROMPT: text displayed to the user
function bb_cli_input_getinput () {
    eval "read -r -p \"${2% }${2:+ }$PS2\" $1"
}

# yn PROMPT
# Prompts user to confirm an action by pressing Y
# @arguments:
# - PROMPT: text displayed to the user
# @returns: 0 if yes, 1 otherwise
# @notes:
#   If you want the user to type "yes", use getinput
#   and check their response
function bb_cli_input_yn () {
    local resp
    read -r -n 1 -p "${1% }${1:+ }(Yy) $PS2" resp
    [[ $resp =~ [Yy] ]]
}

# pause PROMPT
# Prompts user to press a key to continue
# @arguments:
# - PROMPT: text displayed to the user
#           Default: Press any key to continue
function bb_cli_input_pause () {
    local resp
    read -r -n 1 -s -p "${1:-Press any key to continue}" resp
}
