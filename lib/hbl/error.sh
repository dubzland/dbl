#!/usr/bin/env bash

function hbl__error__invocation_() {
	[[ $# -ge 1 ]] || exit 99

	local arg_string
	arg_string=''
	[[ $# -gt 1 ]] && printf -v arg_string "'%s'," "${@:2}"

	hbl__error__display_ $1 HBL_ERR_INVOCATION \
		"invalid arguments -- [${arg_string%,}]"

	return $HBL_ERR_INVOCATION
}

function hbl__error__argument_() {
	[[ $# -eq 3 ]] || exit 99

	hbl__error__display_ $1 HBL_ERR_ARGUMENT \
		"invalid argument for '$2' -- '$3'"

	return $HBL_ERR_ARGUMENT
}

function hbl__error__undefined_() {
	[[ $# -ne 2 ]] && exit 99

	hbl__error__display_ $1 HBL_ERR_UNDEFINED \
		"variable is undefined -- '$2'"

	return $HBL_ERR_UNDEFINED
}

function hbl__error__invalid_command_() {
	[[ $# -eq 2 ]] || exit 99

	hbl__error__display_ $1 HBL_ERR_INVALID_COMMAND \
		"invalid command id -- '$2'"

	return $HBL_ERR_INVALID_COMMAND
}

function hbl__error__invalid_array_() {
	[[ $# -eq 2 ]] || exit 99

	hbl__error__display_ $1 HBL_ERR_INVALID_ARRAY \
		"not an array -- '$2'"

	return $HBL_ERR_INVALID_ARRAY
}

function hbl__error__invalid_dict_() {
	[[ $# -eq 2 ]] || exit 99

	hbl__error__display_ $1 HBL_ERR_INVALID_DICT \
		"not a dictionary -- '$2'"

	return $HBL_ERR_INVALID_DICT
}

function hbl__error__invalid_option_() {
	[[ $# -eq 2 ]] || exit 99

	hbl__error__display_ $1 HBL_ERR_INVALID_OPTION \
		"invalid option id -- '$2'"

	return $HBL_ERR_INVALID_OPTION
}

function hbl__error__already_defined_() {
	[[ $# -eq 2 ]] || exit 99

	hbl__error__display_ $1 HBL_ERR_ALREADY_DEFINED \
		"variable is already defined -- '$2'"

	return $HBL_ERR_ALREADY_DEFINED
}

function hbl__error__undefined_method_() {
	[[ $# -eq 2 ]] || exit 99

	hbl__error__display_ $1 HBL_ERR_UNDEFINED_METHOD \
		"object does not respond to method -- '$2'"

	return $HBL_ERR_UNDEFINED_METHOD
}

function hbl__error__illegal_instruction_() {
	[[ $# -eq 3 ]] || exit 99

	hbl__error__display_ $1 HBL_ERR_ILLEGAL_INSTRUCTION \
		"illegal instruction ($2) -- '$3'"

	return $HBL_ERR_ILLEGAL_INSTRUCTION
}

function hbl__error__invocation() {
	hbl__error__invocation_ 2 "$@"
}

function hbl__error__argument() {
	hbl__error__argument_ 2 "$@"
}

function hbl__error__undefined() {
	hbl__error__undefined_ 2 "$@"
}

function hbl__error__invalid_command() {
	hbl__error__invalid_command_ 2 "$@"
}

function hbl__error__invalid_array() {
	hbl__error__invalid_array_ 2 "$@"
}

function hbl__error__invalid_dict() {
	hbl__error__invalid_dict_ 2 "$@"
}

function hbl__error__invalid_option() {
	hbl__error__invalid_option_ 2 "$@"
}

function hbl__error__already_defined() {
	hbl__error__already_defined_ 2 "$@"
}

function hbl__error__undefined_method() {
	hbl__error__undefined_method_ 2 "$@"
}

function hbl__error__illegal_instruction() {
	hbl__error__illegal_instruction_ 2 "$@"
}

function hbl__error__display_() {
	local -i offset
	local message code_string

	offset=$1
	code_string=$2
	message="$3"

	if [[ $TRACE -gt 0 ]]; then

		printf "Backtrace (most recent call last):\n" >&2

		for ((i = ${#FUNCNAME[@]}-1; i > offset+1; i--)); do
			printf "  [%s] %s:%s:in '%s'\n" \
				$((i-offset-1)) \
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
	else
		printf "%s: %s\n" "${FUNCNAME[$offset+1]}" "${message}" >&2
	fi
}
