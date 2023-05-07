# @package: util/file
# Routines for common file operations

_bb_onfirstload "bb_util_file" || return

bb_load "util/list"
bb_load "util/env"

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# function: bb_canonicalize [-v VAR] PATH
# Resolves . and .. in a given absolute path
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - PATH: an absolute path
# @returns: 1 if PATH is invalid, 0 otherwise
function bb_canonicalize () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local path="$1"
    [[ "${path:0:1}" == '/' ]] || return "$__bb_false"
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
    return "$__bb_true"
}

# function: bb_abspath [-v VAR] TARGET [FROM]
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
    [[ "${target:0:1}" == '/' ]] || target="$from/$target"
    bb_canonicalize -v result "$target"
    _bb_result "$result"
}

# function: bb_relpath [-v VAR] TARGET [FROM]
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
    [[ "${target:0:1}" == '/' ]] || return "$__bb_false"
    [[ "${from:0:1}" == '/' ]] || return "$__bb_false"
    # Strip any trailing slashes
    target="${target%/}"
    from="${from%/}"
    # Canonicalize paths
    bb_canonicalize -v target "$target"
    bb_canonicalize -v from "$from"
    # Handle trivial . case
    if [[ "$target" == "$from" ]]; then
        _bb_result "."
        return "$__bb_true"
    fi
    # Find the common parent directory
    local common="$from/"
    while [[ "${target#$common}" == "${target}" ]]; do
        common="${common%/}"
        common="${common%/*}"
        result+="${result:+/}.."
    done
    # Append
    result+="${target#$common}"
    _bb_result "$result"
    return "$__bb_true"
}

# function: bb_prettypath PATH
# Prints a pretty version of the path
# @arguments:
# - PATH: a path
# @notes:
#   Replaces home directory with ~
function bb_prettypath () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local result="$1"
    result="${result/#$HOME/\~}"
    _bb_result "$result"
}

# function: bb_countlines FILENAME ...
# Counts the number of lines in a list of files
# @arguments:
# - FILENAME: a valid filename
# @returns: 1 if any of the filenames are invalid, 0 otherwise
function bb_countlines () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local f line
    local -i ct=0
    for f in "$@"; do
        [[ -f "$f" ]] || return "$__bb_false"
        while read -r line; do
            if [[ -n $__bb_util_file_countlines_filter ]]; then
                $__bb_util_file_countlines_filter "$line" || continue
            fi
            (( ct++ ))
        done < "$f"
    done
    _bb_result "$ct"
    return "$__bb_true"
}

# function: bb_countmatches PATTERN FILENAME ...
# Counts the number of matching lines in a list of files
# @arguments:
# - PATTERN: a valid bash regular expression
# - FILENAME: a valid filename
# @returns: 1 if any of the filenames are invalid, 0 otherwise
function bb_countmatches () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    __bb_util_file_grep_pattern="$1"
    shift
    _bb_util_file_grep () { [[ $1 =~ $__bb_util_file_grep_pattern ]]; }
    __bb_util_file_countlines_filter=_bb_util_file_grep
    local result
    bb_countlines -v result "$@"
    local rc=$?
    unset __bb_util_file_countlines_filter
    unset __bb_util_file_grep_pattern
    unset -f _bb_util_file_grep
    _bb_result "$result"
    return $rc
}

# function: bb_extpush EXT FILENAME ...
# Adds the file extension EXT to all given files
# @arguments:
# - EXT: the file extension
# - FILENAME: a valid filename
function bb_extpush () {
    local ext="$1"; shift;
    bb_checkset ext || return
    local f
    for f in "$@"; do
        mv "$f" "$f.$ext"
    done
}

# function: bb_extpop FILENAME ...
# Removes the last file extension from the given files
# @arguments:
# - FILENAME: a valid filename
function bb_extpop () {
    local f
    for f in "$@"; do
        local new="${f%.*}"
        [[ "$f" == "$new" ]] || mv "$f" "$new"
    done
}

# function: bb_hardcopy FILENAME ...
# Replaces symbolic links with deep copies
# @arguments:
# - FILENAME: a valid symbolic link
function bb_hardcopy () {
    local f
    for f in "$@"; do
        [[ -L "$f" ]] || continue
        local real="$(readlink -f "$f")"
        unlink "$f" && cp -r "$real" "$f"
    done
}
