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
bb_util_env_inpath "__bb_tmp_path" "bar"
bb_expect "$?" "$__bb_true" "appendpath"

__bb_tmp_prevpath="$__bb_tmp_path"
bb_util_env_appendpathuniq "__bb_tmp_path" "foo"
bb_expect "$__bb_tmp_prevpath" "$__bb_tmp_path" "appendpathuniq"

bb_util_env_prependpath "__bb_tmp_path" "baz"
bb_util_env_inpath "__bb_tmp_path" "baz"
bb_expect "$?" "$__bb_true" "prependpath"

__bb_tmp_prevpath="$__bb_tmp_path"
bb_util_env_prependpathuniq "__bb_tmp_path" "foo"
bb_expect "$__bb_tmp_prevpath" "$__bb_tmp_path" "prependpathuniq"

unset __bb_tmp_path
unset __bb_tmp_prevpath

# TODO: removefrompath, swapinpath

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
