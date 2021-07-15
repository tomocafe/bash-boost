################################################################################
# util/env 
################################################################################

__bb_tmp_setvar="1"
__bb_tmp_emptyvar=""
unset __bb_tmp_unsetvar
bb_util_env_checkset "__bb_tmp_setvar"
bb_expect "$?" "0" "checkset set var"
bb_util_env_checkset "__bb_tmp_unsetvar"
bb_expect "$?" "1" "checkset unset var"
bb_util_env_checkset "__bb_tmp_emptyvar"
bb_expect "$?" "2" "checkset empty var"
unset __bb_tmp_setvar
unset __bb_tmp_emptyvar

bb_util_env_iscmd "echo"
bb_expect "$?" "$__bb_true" "iscmd command"
bb_util_env_iscmd "this_is_not_a_command"
bb_expect "$?" "$__bb_false" "iscmd not a command"

__bb_tmp_path="foo"
bb_util_env_inpath "__bb_tmp_path" "foo"
bb_expect "$?" "$__bb_true" "inpath true"
bb_util_env_inpath "__bb_tmp_path" "bar"
bb_expect "$?" "$__bb_false" "inpath false"

bb_util_env_appendpath "__bb_tmp_path" "bar"
bb_expect "$__bb_tmp_path" "foo:bar" "appendpath"

__bb_tmp_prevpath="$__bb_tmp_path"
bb_util_env_appendpathuniq "__bb_tmp_path" "foo"
bb_expect "$__bb_tmp_prevpath" "$__bb_tmp_path" "appendpathuniq"

bb_util_env_prependpath "__bb_tmp_path" "baz"
bb_expect "$__bb_tmp_path" "baz:foo:bar" "prependpath"

__bb_tmp_prevpath="$__bb_tmp_path"
bb_util_env_prependpathuniq "__bb_tmp_path" "foo"
bb_expect "$__bb_tmp_prevpath" "$__bb_tmp_path" "prependpathuniq"

bb_expect "$(bb_util_env_printpath "__bb_tmp_path")" "baz
foo
bar"

bb_util_env_swapinpath "__bb_tmp_path" "bar" "baz"
bb_expect "$__bb_tmp_path" "bar:foo:baz" "swapinpath"

bb_util_env_removefrompath "__bb_tmp_path" "bar" "baz"
bb_expect "$__bb_tmp_path" "foo"

unset __bb_tmp_path
unset __bb_tmp_prevpath

################################################################################
# util/kwargs
################################################################################

bb_util_kwargs_kwparse "foo=bar" "hello=world"
bb_expect "$(bb_util_kwargs_kwget foo)" "bar" "kwget foo"
bb_expect "$(bb_util_kwargs_kwget hello)" "world" "kwget hello"
bb_expect "$(bb_util_kwargs_kwget NOT_A_KEY)" "" "kwget NOT_A_KEY"

################################################################################
# util/list
################################################################################

__bb_tmp_list=(foo bar baz)

bb_expect "$(bb_util_list_join : "${__bb_tmp_list[@]}")" "foo:bar:baz"
bb_util_list_split "__bb_tmp_rebuilt_list" ":" "foo:bar:baz"
bb_expect "${__bb_tmp_rebuilt_list[*]}" "foo bar baz"
bb_expect "${#__bb_tmp_rebuilt_list}" "3"
unset __bb_tmp_rebuilt_list

bb_util_list_inlist "bar" "${__bb_tmp_list[@]}"
bb_expect "$?" "$__bb_true" "inlist bar"
bb_util_list_inlist "NOT_IN_LIST" "${__bb_tmp_list[@]}"
bb_expect "$?" "$__bb_false" "inlist NOT_IN_LIST"

__bb_tmp_list=()
bb_util_list_push "__bb_tmp_list" "aa"
bb_util_list_push "__bb_tmp_list" "bb"
bb_util_list_unshift "__bb_tmp_list" "cc"
bb_expect "${__bb_tmp_list[*]}" "cc aa bb"
bb_util_list_pop "__bb_tmp_list"
bb_expect "${__bb_tmp_list[*]}" "cc aa"
bb_util_list_shift "__bb_tmp_list"
bb_expect "${__bb_tmp_list[*]}" "aa"

__bb_tmp_list=(foo bar baz)
bb_expect "$(bb_util_list_sort "${__bb_tmp_list[@]}")" "bar baz foo"
bb_expect "$(bb_util_list_sortdesc "${__bb_tmp_list[@]}")" "foo baz bar"

__bb_tmp_list=(1 2 -1)
bb_expect "$(bb_util_list_sortnums "${__bb_tmp_list[@]}")" "-1 1 2"
bb_expect "$(bb_util_list_sortnumsdesc "${__bb_tmp_list[@]}")" "2 1 -1"

__bb_tmp_list=(3M 2G 4K)
bb_expect "$(bb_util_list_sorthuman "${__bb_tmp_list[@]}")" "4K 3M 2G"
bb_expect "$(bb_util_list_sorthumandesc "${__bb_tmp_list[@]}")" "2G 3M 4K"

__bb_tmp_list=(1 2 3 2 1)
bb_expect "$(bb_util_list_uniq "${__bb_tmp_list[@]}")" "1 2 3"
bb_expect "$(bb_util_list_uniqsorted $(bb_util_list_sort "${__bb_tmp_list[@]}"))" "1 2 3"
bb_expect "$(bb_util_list_uniqsorted $(bb_util_list_sortnums "${__bb_tmp_list[@]}"))" "1 2 3"

unset __bb_tmp_list

################################################################################
# util/math
################################################################################

bb_expect "$(bb_util_math_sum -1 2 3)" "4" "sum"
bb_expect "$(bb_util_math_min -1 3 -3 7)" "-3" "min"
bb_expect "$(bb_util_math_max -1 3 -3 7)" "7" "max"

bb_util_math_isint "42"
bb_expect "$?" "$__bb_true" "isint true"
bb_util_math_isint "-5"
bb_expect "$?" "$__bb_true" "isint negative true"
bb_util_math_isint "3.14"
bb_expect "$?" "$__bb_false" "isint float false"
bb_util_math_isint "abcd"
bb_expect "$?" "$__bb_false" "isint string false"

################################################################################
# util/string
################################################################################

bb_expect "$(bb_util_string_snake2camel foo_bar_baz)" "fooBarBaz" "snake2camel"
bb_expect "$(bb_util_string_snake2camel __foo_bar_baz)" "__fooBarBaz" "snake2camel leading underscore"
bb_expect "$(bb_util_string_camel2snake fooBarBaz)" "foo_bar_baz" "camel2snake"
bb_expect "$(bb_util_string_titlecase "foo bar baz")" "Foo Bar Baz" "titlecase"
bb_expect "$(bb_util_string_sentcase "foo bar. baz")" "Foo bar. Baz" "sentcase"

bb_expect "$(bb_util_string_urlencode "hello world")" "hello%20world" "urlencode"
bb_expect "$(bb_util_string_urldecode "hello%20world")" "hello world" "urldecode"
