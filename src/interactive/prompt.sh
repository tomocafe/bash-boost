_bb_on_first_load "bb_interactive_prompt" || return

bb_load "cli/color"

################################################################################
# Globals
################################################################################

__bb_interactive_prompt_lhs=()
__bb_interactive_prompt_rhs=()
__bb_interactive_prompt_nl=()

__bb_interactive_prompt_backup_ps1=""
__bb_interactive_prompt_backup_cmd=""
__bb_interactive_prompt_resetopt=false

################################################################################
# Functions
################################################################################

# loadprompt
# Activates the registered dynamic prompt
function bb_interactive_prompt_loadprompt () {
    if [[ ! -o checkwinsize ]]; then
        shopt -s checkwinsize
        __bb_interactive_prompt_resetopt=true
    fi
    __bb_interactive_prompt_backup_ps1="$PS1"
    __bb_interactive_prompt_backup="$PROMPT_COMMAND"
    export PROMPT_COMMAND="_bb_interactive_prompt_promptimpl"
}

# unloadprompt
# Deactivates the registered dynamic prompt
# @notes:
#   This will restore the prompt to the state it was in
#   when loadprompt was called
function bb_interactive_prompt_unloadprompt () {
    $__bb_interactive_prompt_resetopt && shopt -u checkwinsize
    PS1="$__bb_interactive_prompt_backup_ps1"
    if [[ -z $__bb_interactive_prompt_backup ]]; then
        unset PROMPT_COMMAND
    else
        export PROMPT_COMMAND="$__bb_interactive_prompt_backup"
    fi
}

# setpromptleft FUNCTION ...
# Sets the left prompt to the output of the list of given functions
# @arguments:
# - FUNCTION: a function whose stdout output will be added to the prompt
# @notes:
#   +----------------------------------------+
#   | left prompt               right prompt |
#   | nextline prompt                        |
#   +----------------------------------------+
function bb_interactive_prompt_setpromptleft () {
    __bb_interactive_prompt_lhs=("$@")
}

# setpromptright FUNCTION ...
# Sets the right prompt to the output of the list of given functions
# @arguments:
# - FUNCTION: a function whose stdout output will be added to the prompt
function bb_interactive_prompt_setpromptright () {
    __bb_interactive_prompt_rhs=("$@")
}

# setpromptnextline FUNCTION ...
# Sets the next line prompt to the output of the list of given functions
# @arguments:
# - FUNCTION: a function whose stdout output will be added to the prompt
function bb_interactive_prompt_setpromptnextline () {
    __bb_interactive_prompt_nl=("$@")
}

# setwintitle FUNCTION
# Sets the window title to the output of the list of given functions
# @arguments:
# - FUNCTION: a function whose stdout output will used as the window title
function bb_interactive_prompt_setwintitle () {
    __bb_interactive_prompt_wintitle="$1"
}

# settabtitle FUNCTION
# Sets the tab title to the output of the list of given functions
# @arguments:
# - FUNCTION: a function whose stdout output will used as the tab title
# @notes:
#   Not all terminals support this
function bb_interactive_prompt_settabtitle () {
    __bb_interactive_prompt_tabtitle="$1"
}

# promptcolor COLORSTR TEXT
# Prints text in color, for use specifically in prompts
# @arguments:
# - COLORSTR: valid color string, see bb_cli_color_colorize
# - TEXT: text to be printed in color
# @note:
#   This is like colorize but adds \[ and \] around non-printing
#   characters which are needed specifically in prompts
function bb_interactive_prompt_promptcolor () {
    __bb_cli_color_escapeprompt=1
    bb_cli_color_rawcolor "$@"
    unset __bb_cli_color_escapeprompt
}

# promptimpl
function _bb_interactive_prompt_promptimpl () {
    BB_PROMPT_LASTRC=$? # keep this line first!
    BB_PROMPT_REM=${COLUMNS?set checkwinsize}

    local unitsep=$'\x22'
    local block
    local raw
    local text

    # Set window title, tab title
    if [[ -n "${__bb_interactive_prompt_wintitle}" ]]; then
        text="$(__bb_interactive_prompt_wintitle)"
        echo -ne "\033]0;${text}\007"
    fi
    if [[ -n "${__bb_interactive_prompt_tabtitle}" ]]; then
        text="$(__bb_interactive_prompt_tabtitle)"
        echo -ne "\033]30;${text}\007"
    fi

    # Left hand side
    local lhs=""
    for block in "${__bb_interactive_prompt_lhs[@]}"; do
        raw="$($block)" 
        text="$(bb_cli_color_colorstrip "$raw")"
        lhs+="$raw"
        (( BB_PROMPT_REM -= ${#text} ))
    done # for block

    # Left-only: stop here, no new line
    PS1="${lhs}"
    [[ -z "${__bb_interactive_prompt_rhs+1}" ]] && return

    # Left and right side: full line prompt
    PS1="\r${PS1}"

    # Right hand side
    local rhs=""
    for block in "${__bb_interactive_prompt_rhs[@]}"; do
        raw="$($block)" 
        text="$(bb_cli_color_colorstrip "$raw")"
        rhs+="$raw"
        (( BB_PROMPT_REM -= ${#text} ))
    done # for block  

    # Calculate center width
    local center
    if [[ $BB_PROMPT_REM -gt 0 ]]; then
        center="$(printf "%${BB_PROMPT_REM}s" "")"
    else
        center=' '
    fi

    # No next line prompt: stop here
    PS1+="${center}${rhs}\n"
    [[ -z "${__bb_interactive_prompt_nl+1}" ]] && return

    # Next line prompt
    BB_PROMPT_REM=$COLUMNS
    local nextline=""
    for block in "${__bb_interactive_prompt_nl[@]}"; do
        raw="$($block)" 
        text="$(bb_cli_color_colorstrip "$raw")"
        nextline+="$raw"
        (( BB_PROMPT_REM -= ${#text} ))
    done # for block

    PS1+="${nextline}"

    # Clean up
    unset BB_PROMPT_RC # important!
    unset BB_PROMPT_REM
}
