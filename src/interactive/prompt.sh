_bb_on_first_load "bb_interactive_prompt" || return

bb_load "cli/color"

################################################################################
# Globals
################################################################################

__bb_interactive_prompt_lhs=()
__bb_interactive_prompt_rhs=()
__bb_interactive_prompt_nl=()

__bb_interactive_prompt_backup=""

################################################################################
# Functions
################################################################################

# loadprompt
bb_interactive_prompt_loadprompt () {
    shopt -s checkwinsize
    __bb_interactive_prompt_backup="$PROMPT_COMMAND"
    export PROMPT_COMMAND="_bb_interactive_prompt_promptimpl"
}

# unloadprompt
bb_interactive_prompt_unloadprompt () {
    if [[ -z $__bb_interactive_prompt_backup ]]; then
        unset PROMPT_COMMAND
    else
        export PROMPT_COMMAND="$__bb_interactive_prompt_backup"
    fi
}

# setpromptleft FUNCTION ...
bb_interactive_prompt_setpromptleft () {
    __bb_interactive_prompt_lhs=("$@")
}

# setpromptright FUNCTION ...
bb_interactive_prompt_setpromptright () {
    __bb_interactive_prompt_rhs=("$@")
}

# setpromptnextline FUNCTION ...
bb_interactive_prompt_setpromptnextline () {
    __bb_interactive_prompt_nl=("$@")
}

# setwintitle FUNCTION
bb_interactive_prompt_setwintitle () {
    __bb_interactive_prompt_wintitle="$1"
}

# settabtitle FUNCTION
bb_interactive_prompt_settabtitle () {
    __bb_interactive_prompt_tabtitle="$1"
}

# promptcolor COLORSTR TEXT
# like colorize but adds \[ and \] around non-printing
# characters which are needed specifically in prompts
bb_interactive_prompt_promptcolor () {
    __bb_cli_color_escapeprompt=1
    bb_cli_color_rawcolor "$@"
    unset __bb_cli_color_escapeprompt
}

# promptimpl
_bb_interactive_prompt_promptimpl () {
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
