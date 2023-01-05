#!/usr/bin/env bash

common_setup() {
	load 'test_helper/bats-support/load'
	load 'test_helper/bats-assert/load'

	# get the containing directory of this file
	# use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
	# as those will point to the bats executable's location or the preprocessed file respectively
	PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/.." >/dev/null 2>&1 && pwd )"
	# make executables in src/ visible to PATH
	# PATH="$PROJECT_ROOT/src:$PATH"

	source ./lib/hbl.sh
}

function is_defined() {
	if declare -p "$1" >/dev/null  2>&1; then
		return 0
	fi

	echo "$1 is undefined."
	return 1
}

function is_array() {
	if is_defined "$1"; then
		[[ "$(declare -p $1 2>/dev/null)" == "declare -a"* ]] && return 0
	fi

	echo "$1 is not an array."
	return 1
}

function is_associative_array() {
	if is_defined "$1"; then
		[[ "$(declare -p $1 2>/dev/null)" == "declare -A"* ]] && return 0
	fi

	echo "$1 is not an associative array."
	return 1
}
