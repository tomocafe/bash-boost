this="bb_cli_arg"
bb_on_first_load "$this" || return

bb_load "cli/color"

################################################################################
# Globals
################################################################################

declare -Ag _bb_cli_arg_optvals=() # optvals[LONGNAME] = VAL
declare -Ag _bb_cli_arg_optdesc=() # optdesc[LONGNAME] = DESCRIPTION
declare -Ag _bb_cli_arg_flags=() # flags[LONGNAME] = 1
declare -Ag _bb_cli_arg_short=() # short[SHORTNAME] = LONGNAME
_bb_cli_arg_short["h"]="help"

_bb_cli_arg_progname="" # see setprog()
_bb_cli_arg_opts=() # [SHORTNAME:]LONGNAME in order of registry
_bb_cli_arg_positionals=() # remaining args
_bb_cli_arg_positional_name="" # see setpositional()
_bb_cli_arg_positional_desc="" # see setpositional()

################################################################################
# Functions
################################################################################

# addopt [SHORTNAME:]LONGNAME [DESCRIPTION] [DEFAULT]
bb_cli_arg_addopt () {
    local optdef="$1"
    local desc="$2"
    local default="$3"
    local longname="${optdef#*:}"
    _bb_cli_arg_opts+=("$optdef")
    _bb_cli_arg_optvals["$longname"]="${default}"
    _bb_cli_arg_optdesc["$longname"]="${desc}"
    # Check for short name
    if [[ "${optdef:1:1}" == ":" ]]; then
        local shortname="${optdef:0:1}"
        if ! [[ ${_bb_cli_arg_short["$shortname"]+set} ]]; then
            _bb_cli_arg_short["$shortname"]="$longname"
        fi
    fi
}

# addflag [SHORTNAME:]LONGNAME [DESCRIPTION] 
bb_cli_arg_addflag () {
    local optdef="$1"
    local longname="${optdef#*:}"
    bb_cli_arg_addopt "$optdef" "$2" $_bb_false
    _bb_cli_arg_flags["$longname"]=1
}

# usage
bb_cli_arg_usage () {
    {
    printf "$_bb_cli_arg_progname"
    local optdef
    for optdef in "${_bb_cli_arg_opts[@]}"; do
        # e.g. [--foo] [-f|--foo] [-f|--foo FOO]
        printf " ["
        local longname="${optdef#*:}"
        if [[ "${optdef:1:1}" == ":" ]]; then
            local shortname="${optdef:0:1}"
            printf -- "-%s|" "$shortname"
        fi
        printf -- "--%s" "$longname";
        if ! bb_cli_arg_isflag "$longname"; then
            printf " ${longname^^}"
        fi
        printf "]"
    done
    if [[ -n $_bb_cli_arg_positional_name ]]; then
        printf " [${_bb_cli_arg_positional_name^^} ...]"
    fi
    printf "\n";
    } 1>&2
}

# help
bb_cli_arg_help () {
    {
    bb_cli_arg_usage
    local optdef
    for optdef in "${_bb_cli_arg_opts[@]}"; do
        local longname="${optdef#*:}"
        if [[ ${_bb_cli_arg_optdesc["$longname"]+set} ]]; then
            printf "  %-16s %s\n" "--$longname" "${_bb_cli_arg_optdesc["$longname"]}"
        fi
    done
    if [[ -n $_bb_cli_arg_positional_name ]] && [[ -n $_bb_cli_arg_positional_desc ]]; then
        printf "  %-16s %s\n" "${_bb_cli_arg_positional_name^^}" "$_bb_cli_arg_positional_desc"
    fi
    } 1>&2
}

# usage_error MESSAGE [RETURNVAL]
bb_cli_arg_usage_error () {
    echo "usage error: $1" 1>&2
    bb_cli_arg_usage
    exit ${2:-1}
}

# isflag LONGNAME
bb_cli_arg_isflag () {
    [[ ${_bb_cli_arg_flags["$1"]+set} ]]
}

# setprog PROGNAME
bb_cli_arg_setprog () {
    _bb_cli_arg_progname="$1"
}

# setpositional NAME DESCRIPTION
bb_cli_arg_setpositional () {
    _bb_cli_arg_positional_name="$1"
    _bb_cli_arg_positional_desc="$2"
}

# parseargs ARGS
bb_cli_arg_parseargs () {
    _bb_cli_arg_positionals=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --)
                shift
                break # remaining arguments shall not be interpreted as options, flags
                ;;
            -h|--help)
                bb_cli_arg_help
                exit 0
                ;;
            --*)
                # Long form options, e.g., --foo, --foo=bar, --foo bar
                local optstr="${1:2}" # strip --
                local longname="${optstr%%=*}" # strip =*
                local optval="${optstr#*=}"
                [[ ${_bb_cli_arg_optvals["$longname"]+set} ]] || bb_cli_arg_usage_error "invalid option: --$longname"
                if bb_cli_arg_isflag "$longname"; then
                    # Flag, e.g., --foo
                    _bb_cli_arg_optvals["$longname"]=$_bb_true
                else
                    # Option, e.g., --foo=bar, --foo bar
                    if [[ "$optstr" == "$longname" ]]; then
                        # This is the --foo bar case, get the next arg
                        shift
                        [[ $# -gt 0 ]] || bb_cli_arg_usage_error "option --$longname missing required value"
                        optval="$1"
                    fi
                    _bb_cli_arg_optvals["$longname"]="$optval"
                fi
                ;;
            -*)
                # Short form options, e.g., -f, -f bar, -rf (implies -r -f)
                local optstr="${1:1}"
                local i
                for (( i=0; i<${#optstr}; i++ )); do
                    local shortname="${optstr:$i:1}"
                    local longname="${_bb_cli_arg_short["$shortname"]}"
                    [[ -n "$longname" ]] || bb_cli_arg_usage_error "invalid option: -$shortname"
                    if bb_cli_arg_isflag "$longname"; then
                        # Flag, e.g., -f
                        _bb_cli_arg_optvals["$longname"]=$_bb_true
                    else
                        # Option, e.g., -f bar
                        if [[ ${#optstr} -eq 1 ]]; then
                            shift
                            [[ $# -gt 0 ]] || bb_cli_arg_usage_error "option -$shortname missing required value"
                            _bb_cli_arg_optvals["$longname"]="$1"
                        else
                            bb_cli_arg_usage_error "option -$shortname requires argument but is compounded as -$optstr; use -$shortname ${longname^^} -${optstr/$shortname/}"
                        fi
                    fi
                done
                ;;
            *)
                # Positional args
                _bb_cli_arg_positionals+=("$1")
                ;;
        esac
        shift
    done
    # Accumulate remaining args in the event -- was used
    while [[ $# -gt 0 ]]; do
        _bb_cli_arg_positionals+=("$1")
        shift
    done
}

# getopt LONGNAME
bb_cli_arg_getopt () {
    echo -n "${_bb_cli_arg_optvals["$1"]}"
}

# checkopt LONGNAME
bb_cli_arg_checkopt () {
    return ${_bb_cli_arg_optvals["$1"]}
}

# getpositionals
bb_cli_arg_getpositionals () {
    echo -n "${_bb_cli_arg_positionals[@]}"
}
