################################################################################
# util/env 
################################################################################

__bb_tmp_setvar="1"
__bb_tmp_emptyvar=""
unset __bb_tmp_unsetvar
bb_checkset "__bb_tmp_setvar"
bb_expect "$?" "0" "checkset set var"
bb_checkset "__bb_tmp_unsetvar"
bb_expect "$?" "1" "checkset unset var"
bb_checkset "__bb_tmp_emptyvar"
bb_expect "$?" "2" "checkset empty var"
unset __bb_tmp_setvar
unset __bb_tmp_emptyvar

bb_iscmd "echo"
bb_expect "$?" "$__bb_true" "iscmd command"
bb_iscmd "this_is_not_a_command"
bb_expect "$?" "$__bb_false" "iscmd not a command"

__bb_tmp_path="foo"
bb_inpath "__bb_tmp_path" "foo"
bb_expect "$?" "$__bb_true" "inpath true"
bb_inpath "__bb_tmp_path" "bar"
bb_expect "$?" "$__bb_false" "inpath false"

bb_appendpath "__bb_tmp_path" "bar"
bb_expect "$__bb_tmp_path" "foo:bar" "appendpath"

__bb_tmp_prevpath="$__bb_tmp_path"
bb_appendpathuniq "__bb_tmp_path" "foo"
bb_expect "$__bb_tmp_prevpath" "$__bb_tmp_path" "appendpathuniq"

bb_prependpath "__bb_tmp_path" "baz"
bb_expect "$__bb_tmp_path" "baz:foo:bar" "prependpath"

__bb_tmp_prevpath="$__bb_tmp_path"
bb_prependpathuniq "__bb_tmp_path" "foo"
bb_expect "$__bb_tmp_prevpath" "$__bb_tmp_path" "prependpathuniq"

bb_expect "$(bb_printpath "__bb_tmp_path")" "baz
foo
bar"

bb_swapinpath "__bb_tmp_path" "bar" "baz"
bb_expect "$__bb_tmp_path" "bar:foo:baz" "swapinpath"

bb_removefrompath "__bb_tmp_path" "bar" "baz"
bb_expect "$__bb_tmp_path" "foo"

unset __bb_tmp_path
unset __bb_tmp_prevpath

################################################################################
# util/kwargs
################################################################################

bb_kwparse "foo=bar" "hello=world"
bb_expect "$(bb_kwget foo)" "bar" "kwget foo"
bb_expect "$(bb_kwget hello)" "world" "kwget hello"
bb_expect "$(bb_kwget NOT_A_KEY)" "" "kwget NOT_A_KEY"

################################################################################
# util/list
################################################################################

__bb_tmp_list=(foo bar baz)

bb_expect "$(bb_join : "${__bb_tmp_list[@]}")" "foo:bar:baz"
bb_split -V __bb_tmp_rebuilt_list ":" "foo:bar:baz"
bb_expect "${__bb_tmp_rebuilt_list[*]}" "foo bar baz" "split foo:bar:baz by :"
bb_expect "${#__bb_tmp_rebuilt_list[@]}" "3" "split foo:bar:baz by :"
bb_split -V __bb_tmp_rebuilt_list "z" "aazb bzcc"
bb_expect "${#__bb_tmp_rebuilt_list[@]}" "3" "split aazb bzcc by z"
bb_expect "${__bb_tmp_rebuilt_list[1]}" "b b" "split aazb bzcc by z"
unset __bb_tmp_rebuilt_list

bb_inlist "bar" "${__bb_tmp_list[@]}"
bb_expect "$?" "$__bb_true" "inlist bar"
bb_inlist "NOT_IN_LIST" "${__bb_tmp_list[@]}"
bb_expect "$?" "$__bb_false" "inlist NOT_IN_LIST"

__bb_tmp_list=()
bb_push "__bb_tmp_list" "aa"
bb_push "__bb_tmp_list" "bb"
bb_unshift "__bb_tmp_list" "cc"
bb_expect "${__bb_tmp_list[*]}" "cc aa bb"
bb_pop "__bb_tmp_list"
bb_expect "${__bb_tmp_list[*]}" "cc aa"
bb_shift "__bb_tmp_list"
bb_expect "${__bb_tmp_list[*]}" "aa"

__bb_tmp_list=(foo bar baz)
bb_expect "$(bb_sort "${__bb_tmp_list[@]}")" "bar baz foo"
bb_expect "$(bb_sortdesc "${__bb_tmp_list[@]}")" "foo baz bar"

__bb_tmp_list=(1 2 -1)
bb_expect "$(bb_sortnums "${__bb_tmp_list[@]}")" "-1 1 2"
bb_expect "$(bb_sortnumsdesc "${__bb_tmp_list[@]}")" "2 1 -1"

__bb_tmp_list=(3M 2G 4K)
bb_expect "$(bb_sorthuman "${__bb_tmp_list[@]}")" "4K 3M 2G"
bb_expect "$(bb_sorthumandesc "${__bb_tmp_list[@]}")" "2G 3M 4K"

__bb_tmp_list=(1 2 3 2 1)
bb_expect "$(bb_uniq "${__bb_tmp_list[@]}")" "1 2 3"
bb_expect "$(bb_uniqsorted $(bb_sort "${__bb_tmp_list[@]}"))" "1 2 3"
bb_expect "$(bb_uniqsorted $(bb_sortnums "${__bb_tmp_list[@]}"))" "1 2 3"

unset __bb_tmp_list

################################################################################
# util/file
################################################################################

bb_expect "$(bb_canonicalize "/foo//bar/../bar/./baz/")" "/foo/bar/baz"
bb_expect "$(bb_abspath "../leaf2" "/base/leaf1")" "/base/leaf2"
bb_expect "$(bb_relpath "/base/leaf2" "/base/leaf1")" "../leaf2"
bb_expect "$(bb_relpath "/foo/bar/baz" "/foo/bar")" "baz"
bb_expect "$(bb_relpath "/foo/bar" "/foo/bar/baz")" ".."
bb_expect "$(bb_relpath "/foo/./bar//" "/foo/bar")" "."

__bb_tmp_file="$(mktemp)"
cat <<EOF > $__bb_tmp_file
foo
bar
baz
hello
world
EOF

bb_expect "$(bb_countlines "$__bb_tmp_file")" "5"
bb_expect "$(bb_countmatches 'o' "$__bb_tmp_file")" "3"
bb_expect "$(bb_countmatches '^...$' "$__bb_tmp_file")" "3"

checkfile () {
    [[ -e "$1" ]]; echo "$?"
}

bb_extpush "ext" "$__bb_tmp_file"
bb_expect "$(checkfile "$__bb_tmp_file.ext")" "$__bb_true"
bb_expect "$(checkfile "$__bb_tmp_file")" "$__bb_false"
bb_extpop "$__bb_tmp_file.ext"
bb_expect "$(checkfile "$__bb_tmp_file.ext")" "$__bb_false"
bb_expect "$(checkfile "$__bb_tmp_file")" "$__bb_true"

rm -f "$__bb_tmp_file"
unset __bb_tmp_file

################################################################################
# util/math
################################################################################

bb_expect "$(bb_sum -1 2 3)" "4" "sum"
bb_expect "$(bb_min -1 3 -3 7)" "-3" "min"
bb_expect "$(bb_max -1 3 -3 7)" "7" "max"
bb_expect "$(bb_abs -5)" "5" "abs"

bb_isint "42"
bb_expect "$?" "$__bb_true" "isint true"
bb_isint "-5"
bb_expect "$?" "$__bb_true" "isint negative true"
bb_isint "3.14"
bb_expect "$?" "$__bb_false" "isint float false"
bb_isint "abcd"
bb_expect "$?" "$__bb_false" "isint string false"

__bb_tmp_nums=({0..20})
bb_expect "$(bb_hex2dec $(bb_dec2hex "${__bb_tmp_nums[@]}"))" "${__bb_tmp_nums[*]}" "hex2dec(dec2hex())"
bb_expect "$(bb_oct2dec $(bb_dec2oct "${__bb_tmp_nums[@]}"))" "${__bb_tmp_nums[*]}" "oct2dec(dec2oct())"
unset __bb_tmp_nums

################################################################################
# util/string
################################################################################

bb_expect "$(bb_lstrip "  hello world  ")" "hello world  " "lstrip"
bb_expect "$(bb_rstrip "  hello world  ")" "  hello world" "rstrip"
bb_expect "$(bb_strip "  hello world  ")" "hello world" "strip"

bb_expect "$(bb_snake2camel foo_bar_baz)" "fooBarBaz" "snake2camel"
bb_expect "$(bb_snake2camel __foo_bar_baz)" "__fooBarBaz" "snake2camel leading underscore"
bb_expect "$(bb_camel2snake fooBarBaz)" "foo_bar_baz" "camel2snake"
bb_expect "$(bb_titlecase "foo bar baz")" "Foo Bar Baz" "titlecase"
bb_expect "$(bb_sentcase "foo bar. baz")" "Foo bar. Baz" "sentcase"

bb_expect "$(bb_urlencode "hello world")" "hello%20world" "urlencode"
bb_expect "$(bb_urldecode "hello%20world")" "hello world" "urldecode"
bb_expect "$(bb_urldecode "hello+world")" "hello world" "urldecode"

################################################################################
# util/time
################################################################################

chkdelta () {
    local delta
    (( delta = $1 - $2 ))
    delta="${delta#-}" # absolute value
    [[ $delta -le 1 ]] # difference less than 1 second
}

chkdelta "$(bb_now)" "$(date +%s)" || bb_fatal "bb_now gave incorrect value"
chkdelta "$(bb_now -2d +1h)" "$(date --date="now - 2 days + 1 hour" +%s)" || bb_fatal "bb_now -2d +1h gave incorrect value"

bb_expect "$(TZ=UTC bb_timefmt %Y-%m-%d_%H%M%S 0)" "1970-01-01_000000"
