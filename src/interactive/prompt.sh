_bb_on_first_load "bb_interactive_prompt" || return

bb_load "cli/color"

################################################################################
# Globals
################################################################################

__bb_interactive_prompt_lhs=()
__bb_interactive_prompt_rhs=()
__bb_interactive_prompt_nl=()

__bb_interactive_prompt_backup=""
__bb_interactive_prompt_lastrc=$__bb_true
__bb_interactive_prompt_rem=0

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

# addpromptleft FUNCTION ...
bb_interactive_prompt_addpromptleft () {
    __bb_interactive_prompt_lhs+=("$@")
}

# addpromptright FUNCTION ...
bb_interactive_prompt_addpromptright () {
    __bb_interactive_prompt_rhs+=("$@")
}

# addpromptnextline FUNCTION ...
bb_interactive_prompt_addpromptnextline () {
    __bb_interactive_prompt_nl+=("$@")
}

# setwintitle FUNCTION
bb_interactive_prompt_setwintitle () {
    __bb_interactive_prompt_wintitle="$1"
}

# settabtitle FUNCTION
bb_interactive_prompt_settabtitle () {
    __bb_interactive_prompt_tabtitle="$1"
}

# promptimpl
_bb_interactive_prompt_promptimpl () {
    __bb_interactive_prompt_lastrc=$? # keep this line first!
    __bb_interactive_prompt_rem=${COLUMNS?set checkwinsize}

    local unitsep=$'\x22'
    local block
    local color
    local text

    # Left hand side
    local lhs=""
    for block in "${__bb_interactive_prompt_lhs[@]}"; do
        local packed=$(
            { text="$($block)"; } 2>&1
            printf "%s%s" "$unitsep" "$text"
)
        color="${packed%%${unitsep}*}"
        text="${packed#*${unitsep}}"
        lhs+="${color:+\[${color}\]}${text}${color:+\[$__bb_cli_color_reset\]}"
        (( __bb_interactive_prompt_rem -= ${#text} ))
    done # for block

    # Left-only: stop here, no new line
    PS1="${lhs}"
    [[ -z "${__bb_interactive_prompt_rhs+1}" ]] && return

    # Left and right side: full line prompt
    PS1="\r${PS1}"

    # Right hand side
    local rhs=""
    for block in "${__bb_interactive_prompt_rhs[@]}"; do
        local packed=$(
            { text="$($block)"; } 2>&1
            printf "%s%s" "$unitsep" "$text"
)
        color="${packed%%${unitsep}*}"
        text="${packed#*${unitsep}}"
        rhs+="${color:+\[${color}\]}${text}${color:+\[$__bb_cli_color_reset\]}"
        (( __bb_interactive_prompt_rem -= ${#text} ))
    done # for block  

    # Calculate center width
    local center
    if [[ $__bb_interactive_prompt_rem -gt 0 ]]; then
        center="$(printf "%${__bb_interactive_prompt_rem}s" "")"
    else
        center=' '
    fi

    # No next line prompt: stop here
    PS1+="${center}${rhs}\n"
    [[ -z "${__bb_interactive_prompt_nl+1}" ]] && return

    # Next line prompt
    __bb_interactive_prompt_rem=$COLUMNS
    local nextline=""
    for block in "${__bb_interactive_prompt_nl[@]}"; do
        local packed=$(
            { text="$($block)"; } 2>&1
            printf "%s%s" "$unitsep" "$text"
)
        color="${packed%%${unitsep}*}"
        text="${packed#*${unitsep}}"
        nextline+="${color:+\[${color}\]}${text}${color:+\[$__bb_cli_color_reset\]}"
        (( __bb_interactive_prompt_rem -= ${#text} ))
    done # for block

    PS1+="${next}"

    # Set window title, tab title
    if [[ -n "${__bb_interactive_prompt_wintitle}" ]]; then
        text="$(__bb_interactive_prompt_wintitle)"
        echo -ne "\033]0;${text}\007"
    fi
    if [[ -n "${__bb_interactive_prompt_tabtitle}" ]]; then
        text="$(__bb_interactive_prompt_tabtitle)"
        echo -ne "\033]30;${text}\007"
    fi

    # Clean up
    unset __bb_interactive_prompt_rc # important!
    unset __bb_interactive_prompt_rem
}
