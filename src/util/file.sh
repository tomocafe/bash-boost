# @package: util/file
# Routines for common file operations

_bb_onfirstload "bb_util_file" || return

bb_load "util/list"

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# canonicalize [-v VAR] PATH
# Resolves . and .. in a given absolute path
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - PATH: an absolute path
# @returns: 1 if PATH is invalid, 0 otherwise
function bb_canonicalize () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local path="$1"
    [[ "${path:0:1}" == '/' ]] || return $__bb_false
    local patharr=()
    bb_split -V patharr '/' "$path"
    local fixed=()
    for dir in "${patharr[@]}"; do
        case $dir in
            .|'') ;;
            ..)
                bb_pop fixed
                ;;
            *)
                fixed+=("$dir")
                ;;
        esac
    done
    _bb_result "/$(bb_join '/' "${fixed[@]}")"
    return $__bb_true
}

# abspath [-v VAR] TARGET [FROM]
# Returns the absolute path from a relative one
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - TARGET: target relative path (can be file or directory)
# - FROM: the absolute directory path from which the absolute path is formed
#         (Defaults to $PWD)
function bb_abspath () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local target="$1"
    local from="${2:-$PWD}"
    local result
    bb_canonicalize -v result "$from/$target"
    _bb_result "$result"
}

# relpath [-v VAR] TARGET [FROM]
# Returns the relative path from a directory to the target
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - TARGET: target absolute path (can be file or directory)
# - FROM: the absolute directory path from which the relative path is formed
#         (Defaults to $PWD)
# @returns: 1 if either TARGET or FROM is invalid, 0 otherwise
function bb_relpath () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local target="$1"
    local from="${2:-$PWD}"
    local result=""
    # Check inputs, must be absolute
    [[ "${target:0:1}" == '/' ]] || return $__bb_false
    [[ "${from:0:1}" == '/' ]] || return $__bb_false
    # Strip any trailing slashes
    target="${target%/}"
    from="${from%/}"
    # Canonicalize paths
    bb_canonicalize -v target "$target"
    bb_canonicalize -v from "$from"
    # Find the common parent directory
    local common="$from"
    while [[ ${target#$common} == ${target} ]]; do
        common="${common%/*}"
        result+="${result:+/}.."
    done
    # Append
    result+="${target#$common}"
    _bb_result "$result"
    return $__bb_true
}
