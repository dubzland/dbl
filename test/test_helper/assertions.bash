#!/usr/bin/env bash

function assert_defined() {
	declare -p "$1" >/dev/null 2>&1 || fail "variable is undefined: $1"
}

function assert_dict() {
	if [[ "$(declare -p $1 2>/dev/null)" != "declare -A"* ]]; then
		fail "not a valid dictionary: $1"
	fi
}

function assert_object() {
	if [[ "$(declare -p $1 2>/dev/null)" != "declare -A"* ]]; then
		fail "not a valid object: $1"
	fi
}

function assert_array() {
	if [[ "$(declare -p $1 2>/dev/null)" != "declare -a"* ]]; then
		fail "not a valid array: $1"
	fi
}

function assert_function() {
	declare -f -F "$1" >/dev/null 2>&1 || fail "not a function: $1"
}

function assert_array_contains() {
	local haystack_string

	assert_array $1

	local -n array__ref="$1"
	for val in "${array__ref[@]}"; do
		[[ "${val}" == "$2" ]] && return 0
	done

	printf -v haystack_string "'%s'," "${array__ref[@]}"
	batslib_print_kv_single_or_multi 8 \
	'haystack' "$1 - [${haystack_string%,}]" \
	'needle'   "$2" \
	| batslib_decorate 'item not found in array' \
	| fail
	return 1

}

function assert_array_equals() {
	local expected_string local actual_string arrays_differ
	arrays_differ=0

	assert_array $1
	assert_array $2
	local -n actual__ref="$1"
	local -n expected__ref="$2"

	[[ ${#actual__ref[@]} -eq ${#expected__ref[@]} ]] || arrays_differ=1

	for i in ${!actual__ref[@]}; do
		[[ "${actual__ref[$i]}" = "${expected__ref[$i]}" ]] || arrays_differ=1
	done

	if [[ $arrays_differ -gt 0 ]]; then
		printf -v expected_string "'%s'," "${expected__ref[@]}"
		printf -v actual_string "'%s'," "${actual__ref[@]}"
		batslib_print_kv_single_or_multi 8 \
		'expected' "[${expected_string%,}]" \
		'actual'   "[${actual_string%,}]" \
		| batslib_decorate 'arrays differ' \
		| fail
	fi
}

function dict_has_key() {
	assert_dict $1

	dict_id=$1
	local -n dict__ref=$1
	[[ -v dict__ref[$2] ]]
}

function assert_dict_has_key() {
	local dict_id key_string

	assert_dict $1

	dict_id=$1
	local -n dict__ref=$1
	# [[ -v dict__ref[$2] ]] || batslib_print_kv_single_or_multi 8 \
	dict_has_key $1 $2 || batslib_print_kv_single_or_multi 8 \
		'dict' "$1" \
		'key'  "$2" \
		| batslib_decorate 'item not found in dictionary' \
		| fail
}
