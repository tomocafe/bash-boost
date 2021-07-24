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

# canonicalize PATH
# Resolves . and .. in a given absolute path
# @arguments:
# - PATH: an absolute path
# @returns: 1 if PATH is invalid, 0 otherwise
function bb_canonicalize () {
    local path="$1"
    [[ "${path:0:1}" == '/' ]] || return $__bb_false
    local patharr=()
    bb_split patharr '/' "$path"
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

# abspath TARGET [FROM]
# Returns the absolute path from a relative one
# @arguments:
# - TARGET: target relative path (can be file or directory)
# - FROM: the absolute directory path from which the absolute path is formed
#         (Defaults to $PWD)
function bb_abspath () {
    local target="$1"
    local from="${2:-$PWD}"
    _bb_result "$(bb_canonicalize "$from/$target")"
}

# relpath TARGET [FROM]
# Returns the relative path from a directory to the target
# @arguments:
# - TARGET: target absolute path (can be file or directory)
# - FROM: the absolute directory path from which the relative path is formed
#         (Defaults to $PWD)
# @returns: 1 if either TARGET or FROM is invalid, 0 otherwise
function bb_relpath () {
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
    target="$(bb_canonicalize "$target")"
    from="$(bb_canonicalize "$from")"
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
