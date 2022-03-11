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
# @example:
# ```bash
# bb_setprog "copy"
# bb_addflag "f:force" "force overwrite destination"
# bb_addarg "src" "source file/directory"
# bb_addarg "dst" "destination path"
# bb_parseargs "$@"
# bb_getopt -v src src || bb_errusage "missing required src argument"
# bb_getopt -v dst fst || bb_errusage "missing required dst argument"
# [[ -e "$dst" && ! bb_checkopt force ]] && bb_fatal "$dst exists"
# cp "$src" "$dst"
# ```

_bb_onfirstload "bb_cli_arg" || return

bb_load "cli/color" "util/list"

################################################################################
# Globals
################################################################################

declare -Ag __bb_cli_arg_argvals # argvals[LONGNAME] = VAL
declare -Ag __bb_cli_arg_argdesc # argdesc[LONGNAME] = DESCRIPTION
declare -Ag __bb_cli_arg_opts # opts[LONGNAME] = 1
declare -Ag __bb_cli_arg_flags # flags[LONGNAME] = 1
declare -Ag __bb_cli_arg_short # short[SHORTNAME] = LONGNAME
__bb_cli_arg_short["h"]="help"

__bb_cli_arg_progname="" # see setprog()
__bb_cli_arg_optdefs=() # [SHORTNAME:]LONGNAME in order of registry
__bb_cli_arg_args=() # named arguments
__bb_cli_arg_positional_name="" # see setpositional()
__bb_cli_arg_positional_desc="" # see setpositional()
BB_POSARGS=() # remaining positional args

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
    __bb_cli_arg_optdefs+=("$optdef")
    __bb_cli_arg_argdesc["$longname"]="${desc}"
    __bb_cli_arg_opts["$longname"]=1
    [[ $# -ge 3 ]] && __bb_cli_arg_argvals["$longname"]="${default}"
    # Check for short name
    if [[ "${optdef:1:1}" == ":" ]]; then
        local shortname="${optdef:0:1}"
        if ! [[ ${__bb_cli_arg_short["$shortname"]+set} ]]; then
            __bb_cli_arg_short["$shortname"]="$longname"
        fi
    fi
}

# function: bb_addarg NAME DESCRIPTION [DEFAULT]
# Adds a named argument
# @arguments:
# - NAME: unique, one-word name of the argument
# - DESCRIPTION: description of the argument used in help
# - DEFAULT: default value if not given in the command line
function bb_addarg () {
    __bb_cli_arg_args+=("$1")
    __bb_cli_arg_argdesc["$1"]="$2"
    [[ $# -ge 3 ]] && __bb_cli_arg_argvals["$1"]="$3"
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
    local arg
    for arg in "${__bb_cli_arg_optdefs[@]}"; do
        # e.g. [--foo] [-f|--foo] [-f|--foo FOO]
        printf " ["
        local longname="${arg#*:}"
        if [[ "${arg:1:1}" == ":" ]]; then
            local shortname="${arg:0:1}"
            printf -- "-%s|" "$shortname"
        fi
        printf -- "--%s" "$longname";
        if ! bb_isflag "$longname"; then
            printf " ${longname^^}"
        fi
        printf "]"
    done
    for arg in "${__bb_cli_arg_args[@]}"; do
        printf -- " %s" "$arg"
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
    local arg
    for arg in "${__bb_cli_arg_optdefs[@]}"; do
        local longname="${arg#*:}"
        if [[ ${__bb_cli_arg_argdesc["$longname"]+set} ]]; then
            printf "  %-16s %s\n" "--$longname" "${__bb_cli_arg_argdesc["$longname"]}"
        fi
    done
    for arg in "${__bb_cli_arg_args[@]}"; do
        if [[ ${__bb_cli_arg_argdesc["$arg"]+set} ]]; then
            printf "  %-16s %s\n" "$arg" "${__bb_cli_arg_argdesc["$arg"]}"
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
# - Check flags with `bb_checkopt LONGNAME`
# - Get option setting values or named arguments with `bb_getopt LONGNAME`
# - Get positional arguments with `${BB_POSARGS[@]}` array
# - If the last argument is a single dash (-), read remaining arguments from stdin
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
    local namedargs=("${__bb_cli_arg_args[@]}")
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
                [[ ${__bb_cli_arg_opts["$longname"]+set} ]] || bb_errusage "invalid option: --$longname"
                if bb_isflag "$longname"; then
                    # Flag, e.g., --foo
                    __bb_cli_arg_argvals["$longname"]=$__bb_true
                else
                    # Option, e.g., --foo=bar, --foo bar
                    if [[ "$optstr" == "$longname" ]]; then
                        # This is the --foo bar case, get the next arg
                        shift
                        [[ $# -gt 0 ]] || bb_errusage "option --$longname missing required value"
                        optval="$1"
                    fi
                    __bb_cli_arg_argvals["$longname"]="$optval"
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
                        __bb_cli_arg_argvals["$longname"]=$__bb_true
                    else
                        # Option, e.g., -f bar
                        if [[ ${#optstr} -eq 1 ]]; then
                            shift
                            [[ $# -gt 0 ]] || bb_errusage "option -$shortname missing required value"
                            __bb_cli_arg_argvals["$longname"]="$1"
                        else
                            bb_errusage "option -$shortname requires argument but is compounded as -$optstr; use -$shortname ${longname^^} -${optstr/$shortname/}"
                        fi
                    fi
                done
                ;;
            *)
                # Populate named args first, in order; then add any remaining to positional args
                if [[ ${#namedargs[@]} -gt 0 ]]; then
                    # Named arg
                    __bb_cli_arg_argvals["${namedargs[0]}"]="$1"
                    bb_shift namedargs
                else
                    # Positional args
                    BB_POSARGS+=("$1")
                fi
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

# alias: bb_processargs
# Parses arguments in $@ and modifies it in-place to only hold positional arguments
# @notes:
#   To use this in a script, you must do `shopt -s expand_aliases`
alias bb_processargs='bb_parseargs "$@"; set -- "${BB_POSARGS[@]}"; unset BB_POSARGS;' # shellcheck disable=SC2142

# function: bb_getopt [-v VAR] LONGNAME
# Gets the value of option or argument by name
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - LONGNAME: long name of the option (or named argument)
# @returns: true if the result is nonempty
function bb_getopt () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    _bb_result "${__bb_cli_arg_argvals["$1"]}"
    [[ ${__bb_cli_arg_argvals["$1"]+set} ]]
}

# function: bb_checkopt LONGNAME
# Returns the value of flag named LONGNAME
# @arguments:
# - LONGNAME: long name of the flag
# @returns: the flag value, either true or false
# @notes:
#   Undefined if used on an opt instead of a flag
function bb_checkopt () {
    return "${__bb_cli_arg_argvals["$1"]}"
}

# function: bb_argclear
# Clears all registered argument parsing settings
# @notes:
#   Only one "command" can be registered for parsing at once
#   so this can be used to clear the state of a previous command
#   and start a new one
function bb_argclear () {
    __bb_cli_arg_argvals=()
    __bb_cli_arg_argdesc=()
    __bb_cli_arg_opts=()
    __bb_cli_arg_flags=()
    __bb_cli_arg_short=()
    __bb_cli_arg_short["h"]="help"

    __bb_cli_arg_progname=""
    __bb_cli_arg_optdefs=()
    __bb_cli_arg_args=()
    __bb_cli_arg_positional_name=""
    __bb_cli_arg_positional_desc=""
    BB_POSARGS=()
}
