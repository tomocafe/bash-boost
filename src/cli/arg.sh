# @package: cli/arg
# Routines for parsing command line arguments
# @example:
# ```bash
# bb_setprog "myprogram"
# bb_addopt f:foo "Number of foos (default: 2)" 2
# bb_addflag b:bar "Bar flag"
# bb_setpositional "THINGS" "Things to process"
# bb_parseargs "$@"
# set -- "${BB_POSARGS[@]}" # $@ now only contains the positional arguments
# bb_checkopt bar && echo "You gave the bar flag!"
# bb_getopt -v fooval foo
# [[ $fooval -gt 0 ]] || bb_errusage "foo val must be greater than 0"
# echo "You set foo to $fooval"
# for arg in "$@"; do
#   echo "You have item $arg"
# done
# ```

_bb_onfirstload "bb_cli_arg" || return

bb_load "cli/color"

################################################################################
# Globals
################################################################################

declare -Ag __bb_cli_arg_optvals # optvals[LONGNAME] = VAL
declare -Ag __bb_cli_arg_optdesc # optdesc[LONGNAME] = DESCRIPTION
declare -Ag __bb_cli_arg_flags # flags[LONGNAME] = 1
declare -Ag __bb_cli_arg_short # short[SHORTNAME] = LONGNAME
__bb_cli_arg_short["h"]="help"

__bb_cli_arg_progname="" # see setprog()
__bb_cli_arg_opts=() # [SHORTNAME:]LONGNAME in order of registry
__bb_cli_arg_positional_name="" # see setpositional()
__bb_cli_arg_positional_desc="" # see setpositional()
BB_POSARGS=() # remaining (positional) args

################################################################################
# Functions
################################################################################

# function: bb_addopt [SHORTNAME:]LONGNAME [DESCRIPTION] [DEFAULT]
# Adds a command line option to be parsed
# @arguments:
# - SHORTNAME: optional single character, e.g. "f" for an -f FOO option
# - LONGNAME: required long name, e.g. "foo" for a --foo FOO option
# - DESCRIPTION: description of the option used in help
# - DEFAULT: the default value of the option if not given in the command line
# @notes:
#   -h and --help are reserved for automatically-generated
#   command usage and help
function bb_addopt () {
    local optdef="$1"
    local desc="$2"
    local default="$3"
    local longname="${optdef#*:}"
    __bb_cli_arg_opts+=("$optdef")
    __bb_cli_arg_optvals["$longname"]="${default}"
    __bb_cli_arg_optdesc["$longname"]="${desc}"
    # Check for short name
    if [[ "${optdef:1:1}" == ":" ]]; then
        local shortname="${optdef:0:1}"
        if ! [[ ${__bb_cli_arg_short["$shortname"]+set} ]]; then
            __bb_cli_arg_short["$shortname"]="$longname"
        fi
    fi
}

# function: bb_addflag [SHORTNAME:]LONGNAME [DESCRIPTION]
# Adds a command line flag to be parsed
# @arguments:
# - SHORTNAME: optional single character, e.g. "f" for an -f flag
# - LONGNAME: required long name, e.g. "foo" for a --foo flag
# - DESCRIPTION: description of the option used in help
# @notes:
#   -h and --help are reserved for automatically-generated
#   command usage and help
function bb_addflag () {
    local optdef="$1"
    local longname="${optdef#*:}"
    bb_addopt "$optdef" "$2" "$__bb_false"
    __bb_cli_arg_flags["$longname"]=1
}

# function: bb_argusage
# Print the command line usage string
function bb_argusage () {
    {
    printf "$__bb_cli_arg_progname"
    local optdef
    for optdef in "${__bb_cli_arg_opts[@]}"; do
        # e.g. [--foo] [-f|--foo] [-f|--foo FOO]
        printf " ["
        local longname="${optdef#*:}"
        if [[ "${optdef:1:1}" == ":" ]]; then
            local shortname="${optdef:0:1}"
            printf -- "-%s|" "$shortname"
        fi
        printf -- "--%s" "$longname";
        if ! bb_isflag "$longname"; then
            printf " ${longname^^}"
        fi
        printf "]"
    done
    if [[ -n $__bb_cli_arg_positional_name ]]; then
        printf " [${__bb_cli_arg_positional_name^^} ...]"
    fi
    printf "\n";
    } 1>&2
}

# function: bb_arghelp
# Print the command line help
# @notes:
#   Includes the usage string and a list of flags and options with their
#   descriptions.
function bb_arghelp () {
    {
    bb_argusage
    local optdef
    for optdef in "${__bb_cli_arg_opts[@]}"; do
        local longname="${optdef#*:}"
        if [[ ${__bb_cli_arg_optdesc["$longname"]+set} ]]; then
            printf "  %-16s %s\n" "--$longname" "${__bb_cli_arg_optdesc["$longname"]}"
        fi
    done
    if [[ -n $__bb_cli_arg_positional_name ]] && [[ -n $__bb_cli_arg_positional_desc ]]; then
        printf "  %-16s %s\n" "${__bb_cli_arg_positional_name^^}" "$__bb_cli_arg_positional_desc"
    fi
    } 1>&2
}

# function: bb_errusage MESSAGE [RETURNVAL]
# Issues an error message, prints the command usage, and exits the shell
# @arguments:
# - MESSAGE: error message to be printed
# - RETURNVAL: return code to exit with (defaults to 1)
function bb_errusage () {
    echo "usage error: $1" 1>&2
    bb_argusage
    bb_issourced && return "${2:-1}" || exit "${2:-1}"
}

# function: bb_isflag LONGNAME
# Check if LONGNAME is a registered flag (not an option)
# @returns: 0 if LONGNAME is a flag, 1 otherwise (i.e. it is an option)
function bb_isflag () {
    [[ ${__bb_cli_arg_flags["$1"]+set} ]]
}

# function: bb_setprog PROGNAME
# Sets the name of the program for printing usage and help
# @arguments:
# - PROGNAME: name of the program
function bb_setprog () {
    __bb_cli_arg_progname="$1"
}

# function: bb_setpositional NAME DESCRIPTION
# Sets the name and description of the positional arguments
# @arguments:
# - NAME: one-word name of the positional arguments (auto-capitalized)
# - DESCRIPTION: description of the positionals used in help
function bb_setpositional () {
    __bb_cli_arg_positional_name="$1"
    __bb_cli_arg_positional_desc="$2"
}

# function: bb_parseargs ARGS
# Parses command line arguments after registering valid flags and options
# @arguments:
# - ARGS: the list of command line arguments, usually "$@"
# @notes:
#   Check flags with checkopt LONGNAME
#   Get option setting values with getopt LONGNAME
#   Get positional arguments with ${BB_POSARGS[@]} array
#   If the last argument is a single dash (-), read remaining arguments from stdin
function bb_parseargs () {
    # Read arguments from stdin if last argument is -
    local arglist=("$@")
    case "${@: -1}" in
        -)
            unset arglist[${#arglist[@]}-1] # negative array index requires bash 4.3+
            readarray -t -O ${#arglist[@]} arglist # append args from stdin to arglist
            ;;
    esac
    set -- "${arglist[@]}" # replace original $@ with expanded arglist
    BB_POSARGS=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --)
                shift
                break # remaining arguments shall not be interpreted as options, flags
                ;;
            -h|--help)
                bb_arghelp
                bb_issourced && return 0 || exit 0
                ;;
            --*)
                # Long form options, e.g., --foo, --foo=bar, --foo bar
                local optstr="${1:2}" # strip --
                local longname="${optstr%%=*}" # strip =*
                local optval="${optstr#*=}"
                [[ ${__bb_cli_arg_optvals["$longname"]+set} ]] || bb_errusage "invalid option: --$longname"
                if bb_isflag "$longname"; then
                    # Flag, e.g., --foo
                    __bb_cli_arg_optvals["$longname"]=$__bb_true
                else
                    # Option, e.g., --foo=bar, --foo bar
                    if [[ "$optstr" == "$longname" ]]; then
                        # This is the --foo bar case, get the next arg
                        shift
                        [[ $# -gt 0 ]] || bb_errusage "option --$longname missing required value"
                        optval="$1"
                    fi
                    __bb_cli_arg_optvals["$longname"]="$optval"
                fi
                ;;
            -*)
                # Short form options, e.g., -f, -f bar, -rf (implies -r -f)
                local optstr="${1:1}"
                local -i i
                for (( i=0; i<${#optstr}; i++ )); do
                    local shortname="${optstr:$i:1}"
                    local longname="${__bb_cli_arg_short["$shortname"]}"
                    [[ -n "$longname" ]] || bb_errusage "invalid option: -$shortname"
                    if bb_isflag "$longname"; then
                        # Flag, e.g., -f
                        __bb_cli_arg_optvals["$longname"]=$__bb_true
                    else
                        # Option, e.g., -f bar
                        if [[ ${#optstr} -eq 1 ]]; then
                            shift
                            [[ $# -gt 0 ]] || bb_errusage "option -$shortname missing required value"
                            __bb_cli_arg_optvals["$longname"]="$1"
                        else
                            bb_errusage "option -$shortname requires argument but is compounded as -$optstr; use -$shortname ${longname^^} -${optstr/$shortname/}"
                        fi
                    fi
                done
                ;;
            *)
                # Positional args
                BB_POSARGS+=("$1")
                ;;
        esac
        shift
    done
    # Accumulate remaining args in the event -- was used
    while [[ $# -gt 0 ]]; do
        BB_POSARGS+=("$1")
        shift
    done
}

# function: bb_getopt [-v VAR] LONGNAME
# Gets the value of option named LONGNAME
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - LONGNAME: long name of the option
function bb_getopt () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    _bb_result "${__bb_cli_arg_optvals["$1"]}"
}

# function: bb_checkopt LONGNAME
# Returns the value of flag named LONGNAME
# @arguments:
# - LONGNAME: long name of the flag
# @returns: the flag value
function bb_checkopt () {
    return "${__bb_cli_arg_optvals["$1"]}"
}

# function: bb_argclear
# Clears all registered argument parsing settings
# @notes:
#   Only one "command" can be registered for parsing at once
#   so this can be used to clear the state of a previous command
#   and start a new one
function bb_argclear () {
    __bb_cli_arg_optvals=()
    __bb_cli_arg_optdesc=()
    __bb_cli_arg_flags=()
    __bb_cli_arg_short=()
    __bb_cli_arg_short["h"]="help"

    __bb_cli_arg_progname=""
    __bb_cli_arg_opts=()
    __bb_cli_arg_positional_name=""
    __bb_cli_arg_positional_desc=""
    BB_POSARGS=()
}
