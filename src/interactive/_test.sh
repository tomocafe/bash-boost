################################################################################
# interactive/bookmark
################################################################################

__bb_tmp_dir="$(mktemp -d)"

mkdir -p "$__bb_tmp_dir/aaa/bbb/ccc" && \
mkdir -p "$__bb_tmp_dir/aaa/000/111" && \
(
bb_bookmark a "$__bb_tmp_dir/aaa" # full path from other dir
bb_expect "$(bb_getbookmark "$__bb_tmp_dir/aaa")" "a"
cd "$__bb_tmp_dir"
bb_expect "$(bb_getbookmark "aaa")" "a"
bb_bookmark b "$__bb_tmp_dir/aaa/bbb" # full path from current dir
bb_bookmark 0 "aaa/000" # relative path
bb_addbookmark 1 "aaa/000/111"
bb_expect "$(bb_getbookmark "$__bb_tmp_dir/aaa/bbb")" "b"
bb_expect "$(bb_getbookmark "aaa/000")" "0"
bb_expect "$(bb_getbookmark "aaa/000/111")" "1"
bb_expect "$(bb_showbookmark | wc -l)" "4"
bb_expect "$(bb_showbookmark a)" "$__bb_tmp_dir/aaa"
bb_bookmark a &>/dev/null && bb_expect "$PWD" "$__bb_tmp_dir/aaa"
bb_bookmark b &>/dev/null && bb_expect "$PWD" "$__bb_tmp_dir/aaa/bbb"
bb_bookmark 0 &>/dev/null && bb_expect "$PWD" "$__bb_tmp_dir/aaa/000"
bb_bookmark 1 &>/dev/null && bb_expect "$PWD" "$__bb_tmp_dir/aaa/000/111"
bb_addbookmark 1 "$__bb_tmp_dir/aaa/bbb/ccc" # overwrite 1
bb_expect "$(bb_showbookmark 1)" "$__bb_tmp_dir/aaa/bbb/ccc"
bb_expect "$(bb_getbookmark "$__bb_tmp_dir/aaa/bbb/ccc")" "1"
bb_delbookmark z; bb_expect "$?" "$__bb_false" "delbookmark key not exist"
bb_delbookmark 0; bb_expect "$?" "$__bb_true" "delbookmark 0"
bb_expect "$(bb_showbookmark | wc -l)" "3" "after delete"
bb_expect "$(bb_getbookmark "$__bb_tmp_dir/aaa/000")" ""
bb_bookmark z "$__bb_tmp_dir/aaa/bbb" # rename b
bb_expect "$(bb_showbookmark | wc -l)" "3" "after rename"
bb_expect "$(bb_getbookmark "$__bb_tmp_dir/aaa/bbb")" "z"
bb_expect "$(bb_showbookmark z)" "$__bb_tmp_dir/aaa/bbb"
echo "x /xxx" > "$__bb_tmp_dir/.bookmarks"
bb_loadbookmark "$__bb_tmp_dir/.bookmarks"
bb_expect "$(bb_showbookmark x)" "/xxx"
bb_expect "$(bb_showbookmark | wc -l)" "4"
)
rm -rf "${__bb_tmp_dir}"
