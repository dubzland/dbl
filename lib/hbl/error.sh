#!/usr/bin/env bash

HBL_SUCCESS=0
HBL_ERROR=1
HBL_ERR_UNDEFINED=2
HBL_ERR_INVOCATION=101
HBL_ERR_ARGUMENT=102
HBL_ERR_INVALID_COMMAND=103
HBL_ERR_INVALID_ARRAY=104
HBL_ERR_INVALID_DICT=105
HBL_ERR_INVALID_OPTION=106
HBL_ERR_TEST_ERROR=999

readonly HBL_SUCCESS
readonly HBL_ERROR
readonly HBL_ERR_UNDEFINED
readonly HBL_ERR_INVOCATION
readonly HBL_ERR_ARGUMENT
readonly HBL_ERR_INVALID_COMMAND
readonly HBL_ERR_INVALID_ARRAY
readonly HBL_ERR_INVALID_DICT
readonly HBL_ERR_INVALID_OPTION
readonly HBL_ERR_TEST_ERROR

function hbl::error::_invocation() {
	[[ $# -ge 1 ]] || exit 99

	hbl::error::_display $1 $HBL_ERR_INVOCATION \
		"invalid arguments -- '${@:2}'"

	return $HBL_ERR_INVOCATION
}

function hbl::error::invocation() {
	hbl::error::_invocation 2 "$@"
}

function hbl::error::_argument() {
	[[ $# -eq 3 ]] || exit 99

	hbl::error::_display $1 $HBL_ERR_ARGUMENT \
		"invalid argument for '$2' -- '$3'"

	return $HBL_ERR_ARGUMENT
}

function hbl::error::argument() {
	hbl::error::_argument 2 "$@"
}

function hbl::error::_undefined() {
	[[ $# -ne 2 ]] && exit 99

	hbl::error::_display $1 $HBL_ERR_UNDEFINED \
		"variable is undefined -- '$2'"

	return $HBL_ERR_UNDEFINED
}

function hbl::error::undefined() {
	hbl::error::_undefined 2 "$@"
}

function hbl::error::_invalid_command() {
	[[ $# -eq 2 ]] || exit 99

	hbl::error::_display $1 $HBL_ERR_INVALID_COMMAND \
		"invalid command id -- '$2'"

	return $HBL_ERR_INVALID_COMMAND
}

function hbl::error::invalid_command() {
	hbl::error::_invalid_command 2 "$@"
}

function hbl::error::_invalid_array() {
	[[ $# -eq 2 ]] || exit 99

	hbl::error::_display $1 $HBL_ERR_INVALID_ARRAY \
		"not an array -- '$2'"

	return $HBL_ERR_INVALID_ARRAY
}

function hbl::error::invalid_array() {
	hbl::error::_invalid_array 2 "$@"
}

function hbl::error::_invalid_dict() {
	[[ $# -eq 2 ]] || exit 99

	hbl::error::_display $1 $HBL_ERR_INVALID_DICT \
		"not a dictionary -- '$2'"

	return $HBL_ERR_INVALID_DICT
}

function hbl::error::invalid_dict() {
	hbl::error::_invalid_dict 2 "$@"
}

function hbl::error::_invalid_option() {
	[[ $# -eq 2 ]] || exit 99

	hbl::error::_display $1 $HBL_ERR_INVALID_OPTION \
		"invalid option id -- '$2'"

	return $HBL_ERR_INVALID_OPTION
}

function hbl::error::invalid_option() {
	hbl::error::_invalid_option "${FUNCNAME[1]}" "$@"
}

function hbl::error::_test_error() {
	local -i offset
	offset=$1
	hbl::error::_display_error $offset \
		$HBL_ERR_TEST_ERROR \
		"this is a test" \
	return $HBL_ERR_TEST_ERROR
}

function hbl::error::test_error() {
	hbl::error::_test_error 2
}

function hbl::error::_display() {
	local -i offset code
	local message code_string

	[[ $TRACE -ge 1 ]] || return

	offset=$1
	code=$2
	message="$3"

	case $code in
		$HBL_SUCCESS) code_string="HBL_SUCCESS" ;;
		$HBL_ERROR) code_string="HBL_SUCCESS" ;;
		$HBL_ERR_INVOCATION) code_string="HBL_ERR_INVOCATION" ;;
		$HBL_ERR_ARGUMENT) code_string="HBL_ERR_ARGUMENT" ;;
		$HBL_ERR_INVALID_COMMAND) code_string="HBL_ERR_INVALID_COMMAND" ;;
		$HBL_ERR_INVALID_ARRAY) code_string="HBL_ERR_INVALID_ARRAY" ;;
		$HBL_ERR_INVALID_DICT) code_string="HBL_ERR_INVALID_DICT" ;;
		$HBL_ERR_INVALID_OPTION) code_string="HBL_ERR_INVALID_OPTION" ;;
		$HBL_ERR_TEST_ERROR) code_string="HBL_ERR_TEST_ERROR" ;;
		?) code_string="HBL_UNKNOWN" ;;
	esac

	printf "Backtrace (most recent call last):\n" >&2

	for ((i = ${#FUNCNAME[@]}-1; i > $offset+1; i--)); do
		printf "  [%s] %s:%s:in '%s'\n" \
			$(($i-$offset-1)) \
			"${BASH_SOURCE[i]/$HBL_LIB/<hbl>}" \
			"${BASH_LINENO[i-1]}" \
			"${FUNCNAME[i]}" >&2
	done

	printf "%s:%s:in '%s': %s (%s)\n" \
		"${BASH_SOURCE[$offset+1]/$HBL_LIB/<hbl>}" \
		"${BASH_LINENO[$offset]}" \
		"${FUNCNAME[$offset+1]}" \
		"${message}" \
		"${code_string}" >&2
}
