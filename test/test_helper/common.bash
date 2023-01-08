#!/usr/bin/env bash

common_setup() {
	TEST_ROOT="$(realpath "$(dirname "${BASH_SOURCE%/*}")")"
	load "${TEST_ROOT}/test_helper/bats-support/load"
	load "${TEST_ROOT}/test_helper/bats-assert/load"

	source ./lib/hbl.sh
}

function assert_dict() {
	[[ "$(declare -p $1 2>/dev/null)" == "declare -A"* ]]
}

function assert_array() {
	[[ "$(declare -p $1 2>/dev/null)" == "declare -a"* ]]
}

function assert_array_contains() {
	local -n array__ref="$1"
	for val in "${array__ref[@]}"; do
		[[ "${val}" == "$2" ]] && return 0
	done

	return 1

}

function hbl_test::is_defined() {
	if declare -p "$1" >/dev/null  2>&1; then
		return 0
	fi

	echo "$1 is undefined."
	return 1
}

function hbl_test::is_array() {
	if hbl_test::is_defined "$1"; then
		[[ "$(declare -p $1 2>/dev/null)" == "declare -a"* ]] && return 0
	fi

	echo "$1 is not an array."
	return 1
}
