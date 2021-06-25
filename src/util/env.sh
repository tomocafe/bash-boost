this="bb_util_env"
bb_on_first_load "$this" || return

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

bb_util_env_inpath () {
    command -v "$1" &>/dev/null
}

# check if variable set, nonempty
# check if command in path
# PATH (etc) manipulation: add, remove, swap; check uniqueness; custom separator with : as default