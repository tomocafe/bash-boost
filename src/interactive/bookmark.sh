# @package: interactive/bookmark
# Directory bookmarking system

_bb_onfirstload "bb_interactive_bookmark" || return

bb_load "util/file"

################################################################################
# Globals
################################################################################

declare -Ag __bb_interactive_bookmark_keys # keys[KEY] = DIR
declare -Ag __bb_interactive_bookmark_dirs # dirs[DIR] = KEY
__bb_interactive_bookmark_resp=""

################################################################################
# Functions
################################################################################

function _bb_interactive_bookmark_prompt () {
    read -r -n 1 -p "${BB_BOOKMARK_PS1:-(bookmark) }" __bb_interactive_bookmark_resp
    echo
    __bb_interactive_bookmark_resp="${__bb_interactive_bookmark_resp,,}"
}

function _bb_interactive_bookmark_iskeyvalid() {
    [[ ${#1} -eq 1 ]] && [[ $1 =~ [a-zA-Z0-9] ]]
}

# function: bb_addbookmark [KEY] [DIR]
# Adds a bookmark to the directory for quick recall
# @arguments:
# - KEY: single character to assign bookmark to
# - DIR: directory to bookmark; defaults to current directory
# @notes:
#   If DIR is already bookmarked, this will clear the previously associated key
#   If KEY is already used, this will overwrite the orevious assignment
function bb_addbookmark () {
    local key="$1"
    local dir="${2:-$PWD}"
    [[ -z $key ]] && { _bb_interactive_bookmark_prompt; key="$__bb_interactive_bookmark_resp"; }
    _bb_interactive_bookmark_iskeyvalid "$key" || return $__bb_false
    bb_abspath -v dir "$dir"
    if [[ -n "${__bb_interactive_bookmark_dirs[$dir]}" ]]; then
        # this directory already bookmarked, replace assignment
        bb_delbookmark "${__bb_interactive_bookmark_dirs[$dir]}"
    fi
    __bb_interactive_bookmark_keys["$key"]="$dir"
    __bb_interactive_bookmark_dirs["$dir"]="$key"
    return $__bb_true
}

# function: bb_delbookmark [KEY]
# @arguments:
# - KEY: bookmark key to delete; prompts if unspecified
# @notes:
#   Useful as a keyboard shortcut, e.g., Ctrl+X-B
function bb_delbookmark () {
    local key="$1"
    [[ -z $key ]] && { _bb_interactive_bookmark_prompt; key="$__bb_interactive_bookmark_resp"; }
    _bb_interactive_bookmark_iskeyvalid "$key" || return $__bb_false
    [[ -z ${__bb_interactive_bookmark_keys[$key]} ]] && return $__bb_false
    local dir="${__bb_interactive_bookmark_keys[$key]}"
    unset __bb_interactive_bookmark_keys["$key"]
    unset __bb_interactive_bookmark_dirs["$dir"]
    return $__bb_true
}

# function: bb_bookmark [KEY] [DIR]
# Go to the directory bookmarked by KEY if it exists, otherwise create bookmark
# @arguments:
# - KEY: single character to assign bookmark to; prompts if unspecified
# - DIR: directory to bookmark; defaults to current directory
# @notes:
#   If DIR is already bookmarked, this will clear the previously associated key.
#   If KEY is already used but you wish to overwrite it, use bb_addbookmark or use bb_delbookmark KEY first
#   Useful as a keyboard shortcut, e.g., Ctrl+B
function bb_bookmark () {
    local key="$1"
    local dir="${2:-$PWD}"
    [[ -z $key ]] && { _bb_interactive_bookmark_prompt; key="$__bb_interactive_bookmark_resp"; }
    _bb_interactive_bookmark_iskeyvalid "$key" || return $__bb_false
    if [[ -z ${__bb_interactive_bookmark_keys[$key]} ]]; then
        bb_addbookmark "$key" "$dir"
        return $?
    fi
    dir="${__bb_interactive_bookmark_keys[$key]}"
    [[ -n $BB_BOOKMARK_SILENT ]] || echo "${BB_BOOKMARK_PS2}$(bb_prettypath "$dir")"
    cd "$dir"
}

# function: bb_showbookmark [KEY]
# Shows the current mapping of KEY, or all keys if KEY is unspecified
# @arguments:
# - KEY: bookmark key to show
function bb_showbookmark () {
    local key="$1"
    if [[ -n "$key" ]]; then
        echo "$(bb_prettypath "${__bb_interactive_bookmark_keys[$key]}")"
        return $__bb_true
    fi
    for key in "${!__bb_interactive_bookmark_keys[@]}"; do
        echo "$key: $(bb_prettypath "${__bb_interactive_bookmark_keys[$key]}")"
    done
}

# function: bb_getbookmark [DIR]
# Prints bookmark key assigned to the given DIR if such a bookmark exists
# @arguments:
# - DIR: directory to get assigned bookmark key of; defaults to current directory
function bb_getbookmark () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local dir="${1:-$PWD}"
    bb_abspath -v dir "$dir"
    local key="${__bb_interactive_bookmark_dirs[$dir]}"
    _bb_result "$key"
    [[ -n "$key" ]]
}
