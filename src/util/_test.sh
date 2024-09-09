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

bb_kwparse __bb_kwmap "foo=bar" "positional" "hello=world"
bb_expect "${__bb_kwmap[foo]:-x}" "bar"
bb_expect "${__bb_kwmap[hello]:-x}" "world"
bb_expect "${__bb_kwmap[NOT_A_KEY]:-none}" "none"
bb_expect "${#BB_OTHERARGS[@]}" "1" "BB_OTHERARGS size"
bb_expect "${BB_OTHERARGS[0]}" "positional"
unset __bb_kwmap
unset BB_OTHERARGS

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
bb_push "__bb_tmp_list" "aa" "bb"
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
# shellcheck disable=SC2046
bb_expect "$(bb_uniqsorted $(bb_sort "${__bb_tmp_list[@]}"))" "1 2 3"
# shellcheck disable=SC2046
bb_expect "$(bb_uniqsorted $(bb_sortnums "${__bb_tmp_list[@]}"))" "1 2 3"

unset __bb_tmp_list # note: need to do this when changing variable from array to scalar!
# shellcheck disable=SC2178
__bb_tmp_list="not_a_list"
bb_islist __bb_tmp_list
bb_expect "$?" "$__bb_false" "islist not_a_list"
__bb_tmp_list=("one_element")
bb_islist __bb_tmp_list
bb_expect "$?" "$__bb_false" "islist (one_element)"
__bb_tmp_list=(1 2 3)
bb_islist __bb_tmp_list
bb_expect "$?" "$__bb_true" "islist (1 2 3)"

unset __bb_tmp_list

bb_islist __bb_tmp_list
bb_expect "$?" "$__bb_false" "islist undefined"

unset __bb_one __bb_two __bb_three
bb_rename x y z -- __bb_one __bb_two
bb_expect ":$__bb_one:$__bb_two:$__bb_three:" ":x:y::"
bb_rename x y -- __bb_one __bb_two __bb_three
bb_expect ":$__bb_one:$__bb_two:$__bb_three:" ":x:y::"
bb_rename x y z -- __bb_one __bb_two __bb_three
bb_expect ":$__bb_one:$__bb_two:$__bb_three:" ":x:y:z:"

__bb_tmp_list=(x y z)
unset __bb_one __bb_two __bb_three
bb_rename "${__bb_tmp_list[@]}" -- __bb_one __bb_two
bb_expect ":$__bb_one:$__bb_two:$__bb_three:" ":x:y::"
bb_rename "${__bb_tmp_list[@]:0:2}" -- __bb_one __bb_two __bb_three
bb_expect ":$__bb_one:$__bb_two:$__bb_three:" ":x:y::"
bb_rename "${__bb_tmp_list[@]}" -- __bb_one __bb_two __bb_three
bb_expect ":$__bb_one:$__bb_two:$__bb_three:" ":x:y:z:"

if _bb_checkbashversion 4 3; then
    unset __bb_one __bb_two __bb_three
    bb_unpack __bb_tmp_list __bb_one __bb_two __bb_three
    bb_expect ":$__bb_one:$__bb_two:$__bb_three:" ":x:y:z:"
fi

if _bb_checkbashversion 4 3; then
    bb_map __bb_tmp_list bb_ord
    bb_expect "${__bb_tmp_list[*]}" "120 121 122"
fi

if _bb_checkbashversion 4 3; then
    __bb_tmp_list=(x y z)
    bb_mapkeys __bb_tmp_map bb_ord "${__bb_tmp_list[@]}"
    bb_expect "${__bb_tmp_map[z]} ${__bb_tmp_map[x]} ${__bb_tmp_map[y]}" "122 120 121"
fi

bb_expect "$(bb_reverselist a b c)" "c b a"

unset __bb_one __bb_two __bb_three
unset __bb_tmp_list __bb_tmp_map

################################################################################
# util/file
################################################################################

bb_expect "$(bb_canonicalize "/foo//bar/../bar/./baz/")" "/foo/bar/baz"
bb_expect "$(bb_abspath "../leaf2" "/base/leaf1")" "/base/leaf2"
bb_expect "$(bb_abspath "/foo/baz/../bar" "zzz")" "/foo/bar"
bb_expect "$(bb_relpath "/base/leaf2" "/base/leaf1")" "../leaf2"
bb_expect "$(bb_relpath "/foo/bar/baz" "/foo/bar")" "baz"
bb_expect "$(bb_relpath "/foo/bar" "/foo/bar/baz")" ".."
bb_expect "$(bb_relpath "/foo/./bar//" "/foo/bar")" "."
bb_expect "$(bb_prettypath "$HOME/foo")" "~/foo"

__bb_tmp_file="$(mktemp)"
cat <<EOF > "$__bb_tmp_file"
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

__bb_tmp_dir="$(mktemp -d)"
mkdir -p "$__bb_tmp_dir/src"
cat <<EOF > "$__bb_tmp_dir/src/test.sh"
source $__bb_test_script
bb_load util/file
bb_scriptpath
EOF
chmod +x "$__bb_tmp_dir/src/test.sh"
ln -s "$__bb_tmp_dir/src" "$__bb_tmp_dir/foo"
mkdir -p "$__bb_tmp_dir/bar"
ln -s "$__bb_tmp_dir/src/test.sh" "$__bb_tmp_dir/bar/link.sh"
ln -s "$__bb_tmp_dir/src" "$__bb_tmp_dir/bar/baz"

bb_expect "$("$__bb_tmp_dir/src/test.sh")" "$__bb_tmp_dir/src"
bb_expect "$("$__bb_tmp_dir/foo/test.sh")" "$__bb_tmp_dir/foo"
bb_expect "$("$__bb_tmp_dir/bar/baz/test.sh")" "$__bb_tmp_dir/bar/baz"
bb_expect "$("$__bb_tmp_dir/bar/link.sh")" "$__bb_tmp_dir/bar"

(
    cd "$__bb_tmp_dir"
    bb_expect "$(./src/test.sh)" "./src"
    bb_expect "$(./foo/test.sh)" "./foo"
    bb_expect "$(./bar/baz/test.sh)" "./bar/baz"
    bb_expect "$(./bar/link.sh)" "./bar"
)

rm -f "$__bb_tmp_file"
unset __bb_tmp_file
rm -rf "$__bb_tmp_dir"
unset __bb_tmp_dir

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
# shellcheck disable=SC2046
bb_expect "$(bb_hex2dec $(bb_dec2hex "${__bb_tmp_nums[@]}"))" "${__bb_tmp_nums[*]}" "hex2dec(dec2hex())"
# shellcheck disable=SC2046
bb_expect "$(bb_oct2dec $(bb_dec2oct "${__bb_tmp_nums[@]}"))" "${__bb_tmp_nums[*]}" "oct2dec(dec2oct())"
unset __bb_tmp_nums

################################################################################
# util/string
################################################################################

bb_expect "$(bb_lstrip "  hello world  ")" "hello world  " "lstrip"
bb_expect "$(bb_rstrip "  hello world  ")" "  hello world" "rstrip"
bb_expect "$(bb_strip "  hello world  ")" "hello world" "strip"

bb_expect "$(bb_reversestr "hello world")" "dlrow olleh"

bb_expect "$(bb_ord A)" "65" "ord"
bb_expect "$(bb_chr 65)" "A" "chr"

bb_expect "$(bb_snake2camel foo_bar_baz)" "fooBarBaz" "snake2camel"
bb_expect "$(bb_snake2camel __foo_bar_baz)" "__fooBarBaz" "snake2camel leading underscore"
bb_expect "$(bb_camel2snake fooBarBaz)" "foo_bar_baz" "camel2snake"
bb_expect "$(bb_titlecase "foo bar baz")" "Foo Bar Baz" "titlecase"
bb_expect "$(bb_sentcase "foo bar. baz")" "Foo bar. Baz" "sentcase"

bb_expect "$(bb_urlencode "hello world")" "hello%20world" "urlencode"
bb_expect "$(bb_urldecode "hello%20world")" "hello world" "urldecode"
bb_expect "$(bb_urldecode "hello+world")" "hello world" "urldecode"

bb_expect "$(bb_repeatstr 5 ab)" "ababababab"

bb_expect "$(bb_centerstr 8 ab)" "   ab   "
bb_expect "$(bb_centerstr 8 ab .)" "...ab..."
bb_expect "$(bb_centerstr 7 ab)" "  ab   "
bb_expect "$(bb_centerstr 7 ab ...)" "..ab..."
bb_expect "$(bb_centerstr 2 foobar)" "foobar"

bb_centerstr -v __bb_tmp_centerstr 9 "$(bb_rawcolor red hello)" _
bb_expect "${__bb_tmp_centerstr:0:2}" "__"
unset __bb_tmp_centerstr

bb_cmpversion 3.10 3.9
bb_expect "$?" "$__bb_true" "bb_cmpversion 3.10 3.9"
bb_cmpversion 3.10 3.009
bb_expect "$?" "$__bb_true" "bb_cmpversion 3.10 3.009"
bb_cmpversion 3.10 3.90
bb_expect "$?" "$__bb_false" "bb_cmpversion 3.10 3.90"
bb_cmpversion 3.10.1 3.10
bb_expect "$?" "$__bb_true" "bb_cmpversion 3.10.1 3.10"
bb_cmpversion 3.10 3.10.1
bb_expect "$?" "$__bb_false" "bb_cmpversion 3.10 3.10.1"

################################################################################
# util/time
################################################################################

chkdelta () {
    local delta
    local mod="$4"
    if [[ -n $mod ]]; then
        (( delta = (10#$1 - 10#$2 + mod) % mod )) # handle case when 23:00 rounds up to 00:00, still want delta to be 1
    else
        (( delta = 10#$1 - 10#$2 ))
    fi
    delta="${delta#-}" # absolute value
    [[ $delta -le ${3:-1} ]] # difference less than 1
}

chkdelta "$(bb_now)" "$(date +%s)" || bb_fatal "bb_now gave incorrect value"
chkdelta "$(bb_now -2d +1h)" "$(date --date="now - 2 days + 1 hour" +%s)" || bb_fatal "bb_now -2d +1h gave incorrect value"

bb_expect "$(TZ=UTC bb_timefmt %Y-%m-%d_%H%M%S 0)" "1970-01-01_000000"

testround () {
    local orig rounded mod
    local mod="$3"
    bb_timefmt -v orig "%$2" 
    bb_timefmt -v rounded "%$2" $(bb_now "^$1")
    chkdelta $rounded $orig 1 "$mod"
}

get_days_in_month () {
    # this only works on the last day of the month, but that's the only time we need this to work
    local today tomorrow delta
    today="$(date +%-d)"
    tomorrow="$(date +%-d --date="tomorrow")"
    (( delta = tomorrow - today ))
    if [[ $today -gt $tomorrow ]]; then
        echo "$today"
    fi
    echo "99"
}

for tz in "" UTC US/Pacific Asia/Calcutta; do
    (
    export TZ=$tz
    testround h H 24 || bb_fatal "bb_now ^h failed ${TZ:+(TZ=$TZ)}"
    testround d d "$(get_days_in_month)" || bb_fatal "bb_now ^d failed ${TZ:+(TZ=$TZ)}"
    )
done

bb_expect "$(bb_timedeltafmt "%D:%H:%M:%S %dd %hh %mm %ss" 1400 63)" "00:00:22:17 0d 0h 22m 1337s"
bb_expect "$(bb_timedeltafmt "%D:%H:%M:%S %dd %hh %mm %ss" 8675309)" "100:09:48:29 100d 2409h 144588m 8675309s"

################################################################################
# util/rand
################################################################################

bb_expect "$(bb_randint 1234 1234)" "1234"
bb_expect "$(bb_randstr 4 x)" "xxxx"

for (( i=0; i<100; i++ )); do
    bb_randint -v __bb_tmp_num 210 200
    [[ $__bb_tmp_num -ge 200 && $__bb_tmp_num -le 210 ]] || bb_fatal "bb_randint out of range"
done
unset __bb_tmp_num

for (( i=0; i<100; i++ )); do
    bb_randstr -v __bb_tmp_str 24 abcdef
    bb_expectre "$__bb_tmp_str" "^[abcdef]+" "bb_randstr out of range"
    bb_expect "${#__bb_tmp_str}" "24" "bb_randstr wrong char count"
done
unset __bb_tmp_str

bb_randwords 1 &>/dev/null
bb_expect "$?" "$__bb_false" "bb_randwords before bb_loadworddict"

bb_loadworddict <(echo "foo
bar
baz
hello
world
red
yellow
blue")

bb_expect "${#__bb_util_rand_words[@]}" 8 "__bb_util_rand_words invalid count"
bb_expect "$__bb_util_rand_wordct" 8 "__bb_util_rand_wordct invalid count"

bb_randwords 100 &>/dev/null
bb_expect "$?" "$__bb_false" "bb_randwords too many words requested"

for (( i=0; i<100; i++ )); do
    bb_randwords -v __bb_tmp_str 3 -
    bb_expectre "$__bb_tmp_str" "^\w+-\w+-\w+$" "bb_randwords out of range"
    bb_split -V __bb_tmp_words - "$__bb_tmp_str"
    bb_expect "${#__bb_tmp_words[@]}" "3" "bb_randwords wrong word count"
    while [[ ${#__bb_tmp_words[@]} -gt 1 ]]; do
        __bb_tmp_str="${__bb_tmp_words[0]}"
        bb_shift __bb_tmp_words
        bb_inlist "$__bb_tmp_str" "${__bb_tmp_words[@]}" && bb_fatal "bb_randwords repeated"
    done
done
unset __bb_tmp_str
