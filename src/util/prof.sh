_bb_on_first_load "bb_util_prof" || return

bb_load "cli/msg"

################################################################################
# Globals
################################################################################

__bb_util_prof_logfile=""
__bb_util_prof_backup_ps4="$PS4"

################################################################################
# Functions
################################################################################

# startprof LOGFILE
bb_util_prof_startprof () {
    __bb_util_prof_logfile="${1:-${TMPDIR:-/tmp}/bbprof.$$.out}"
    __bb_util_prof_backup_ps4="$PS4"
    [[ $- == *i* ]] && bb_cli_msg_info "logging runtime profile to $__bb_util_prof_logfile"
    exec 5>"$__bb_util_prof_logfile"
    BASH_XTRACEFD="5"
    if [[ ${BASH_VERSINFO-0} -ge 5 ]]; then
        echo -e "$EPOCHREALTIME\011 start" 1>&5
        PS4='+ $EPOCHREALTIME\011 '
    else
        echo -e "$(date +"%s.%N")\011 start" 1>&5
        PS4='+ $(date "+%s.%N")\011 '
    fi
    set -x
}

# stopprof
bb_util_prof_stopprof () {
    set +x
    unset BASH_XTRACEFD
    PS4="$__bb_util_prof_backup_ps4"
}
