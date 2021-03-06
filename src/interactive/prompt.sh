# @package: interactive/prompt
# Routines for managing a dynamic shell prompt

_bb_onfirstload "bb_interactive_prompt" || return

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

# function: bb_loadprompt
# Activates the registered dynamic prompt
function bb_loadprompt () {
    if [[ ! -o checkwinsize ]]; then
        shopt -s checkwinsize
        __bb_interactive_prompt_resetopt=true
    fi
    __bb_interactive_prompt_backup_ps1="$PS1"
    __bb_interactive_prompt_backup="$PROMPT_COMMAND"
    export PROMPT_COMMAND="_bb_interactive_prompt_promptimpl"
}

# function: bb_unloadprompt
# Deactivates the registered dynamic prompt
# @notes:
#   This will restore the prompt to the state it was in
#   when loadprompt was called
function bb_unloadprompt () {
    $__bb_interactive_prompt_resetopt && shopt -u checkwinsize
    PS1="$__bb_interactive_prompt_backup_ps1"
    if [[ -z $__bb_interactive_prompt_backup ]]; then
        unset PROMPT_COMMAND
    else
        export PROMPT_COMMAND="$__bb_interactive_prompt_backup"
    fi
}

# function: bb_setpromptleft FUNCTION ...
# Sets the left prompt to the output of the list of given functions
# @arguments:
# - FUNCTION: a function whose stdout output will be added to the prompt
# @notes:
#   The prompt areas are as follows:
#   ```
#   +----------------------------------------+
#   | left prompt               right prompt |
#   | nextline prompt                        |
#   +----------------------------------------+
#   ```
function bb_setpromptleft () {
    __bb_interactive_prompt_lhs=("$@")
}

# function: bb_setpromptright FUNCTION ...
# Sets the right prompt to the output of the list of given functions
# @arguments:
# - FUNCTION: a function whose stdout output will be added to the prompt
function bb_setpromptright () {
    __bb_interactive_prompt_rhs=("$@")
}

# function: bb_setpromptnextline FUNCTION ...
# Sets the next line prompt to the output of the list of given functions
# @arguments:
# - FUNCTION: a function whose stdout output will be added to the prompt
function bb_setpromptnextline () {
    __bb_interactive_prompt_nl=("$@")
}

# function: bb_setwintitle FUNCTION
# Sets the window title to the output of the list of given functions
# @arguments:
# - FUNCTION: a function whose stdout output will used as the window title
function bb_setwintitle () {
    __bb_interactive_prompt_wintitle="$1"
}

# function: bb_settabtitle FUNCTION
# Sets the tab title to the output of the list of given functions
# @arguments:
# - FUNCTION: a function whose stdout output will used as the tab title
# @notes:
#   Not all terminals support this
function bb_settabtitle () {
    __bb_interactive_prompt_tabtitle="$1"
}

# function: bb_promptcolor COLORSTR TEXT
# Prints text in color, for use specifically in prompts
# @arguments:
# - COLORSTR: valid color string, see bb_colorize
# - TEXT: text to be printed in color
# @notes:
#   This is like colorize but adds \[ and \] around non-printing
#   characters which are needed specifically in prompts
function bb_promptcolor () {
    __bb_cli_color_escapeprompt=1
    bb_rawcolor "$@"
    unset __bb_cli_color_escapeprompt
}

# promptimpl
function _bb_interactive_prompt_promptimpl () {
    BB_PROMPT_LASTRC=$? # keep this line first!
    BB_PROMPT_REM=${COLUMNS?set checkwinsize}

    local block
    local raw
    local text

    # Set window title, tab title
    if [[ -n "${__bb_interactive_prompt_wintitle}" ]]; then
        text="$($__bb_interactive_prompt_wintitle)"
        echo -ne "\033]0;${text}\007"
    fi
    if [[ -n "${__bb_interactive_prompt_tabtitle}" ]]; then
        text="$($__bb_interactive_prompt_tabtitle)"
        echo -ne "\033]30;${text}\007"
    fi

    # Left hand side
    local lhs=""
    for block in "${__bb_interactive_prompt_lhs[@]}"; do
        raw="$($block)" 
        text="$(bb_colorstrip "$raw")"
        lhs+="$raw"
        (( BB_PROMPT_REM -= ${#text} ))
    done # for block
    PS1="${lhs}"

    # Right side: carriage return
    [[ -n "${__bb_interactive_prompt_rhs+1}" ]] && PS1="\r${PS1}"

    # Right hand side
    local rhs=""
    for block in "${__bb_interactive_prompt_rhs[@]}"; do
        raw="$($block)" 
        text="$(bb_colorstrip "$raw")"
        rhs+="$raw"
        (( BB_PROMPT_REM -= ${#text} ))
    done # for block  

    # Calculate center width
    local center=""
    if [[ -n "${__bb_interactive_prompt_rhs+1}" ]]; then
        if [[ $BB_PROMPT_REM -gt 0 ]]; then
            center="$(printf "%${BB_PROMPT_REM}s" "")"
        else
            center=' '
        fi
    fi

    # Add center and right
    PS1+="${center}${rhs}\n"

    # Next line prompt
    BB_PROMPT_REM=$COLUMNS
    local nextline=""
    for block in "${__bb_interactive_prompt_nl[@]}"; do
        raw="$($block)" 
        text="$(bb_colorstrip "$raw")"
        nextline+="$raw"
        (( BB_PROMPT_REM -= ${#text} ))
    done # for block

    PS1+="${nextline}"

    # Clean up
    unset BB_PROMPT_LASTRC
    unset BB_PROMPT_REM
}
