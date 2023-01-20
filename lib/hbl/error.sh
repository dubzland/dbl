#!/usr/bin/env bash

function Error__static__invocation() {
	[[ $# -ge 2 && "$1" = 'Error' ]] || exit 99

	local -n klass="$1"
	local arg_string=''

	[[ $# -gt 2 ]] && printf -v arg_string "'%s'," "${@:3}"

	$klass._display 2 HBL_ERR_INVOCATION \
		"invalid arguments to '$2' -- [${arg_string%,}]"

	return $HBL_ERR_INVOCATION
}

function Error__static__argument() {
	[[ $# -eq 4 && "$1" = 'Error' && -n "$2" && -n "$3" ]] || exit 99
	local -n klass="$1"

	$Error._display 2 HBL_ERR_ARGUMENT \
		"invalid argument to '$2' for '$3' -- '$4'"

	return $HBL_ERR_ARGUMENT
}

function Error__static__undefined() {
	[[ $# -eq 2 && "$1" = 'Error' && -n "$2" ]] || exit 99
	local -n klass="$1"

	$klass._display 2 HBL_ERR_UNDEFINED \
		"variable is undefined -- '$2'"

	return $HBL_ERR_UNDEFINED
}

function Error__static__already_defined() {
	[[ $# -eq 2 && "$1" = 'Error' && -n "$2" ]] || exit 99
	local -n klass="$1"

	$klass._display 2 HBL_ERR_ALREADY_DEFINED \
		"variable is already defined -- '$2'"

	return $HBL_ERR_ALREADY_DEFINED
}

function Error__static__undefined_method() {
	[[ $# -eq 3 && "$1" = 'Error' && -n "$2" && -n "$3" ]] || exit 99
	local -n klass="$1"

	$klass._display 2 HBL_ERR_UNDEFINED_METHOD \
		"$2 does not respond to method -- '$3'"

	return $HBL_ERR_UNDEFINED_METHOD
}

function Error__static__illegal_instruction() {
	[[ $# -eq 3 && "$1" = 'Error' && -n "$2" && -n "$3" ]] || exit 99
	local -n klass="$1"

	$klass._display 2 HBL_ERR_ILLEGAL_INSTRUCTION \
		"illegal instruction ($2) -- '$3'"

	return $HBL_ERR_ILLEGAL_INSTRUCTION
}

function Error__static__display_() {
	[[ $# -eq 4 && "$1" = 'Error' ]] || exit 99
	local -n klass="$1"
	local -i offset
	local code_string message
	offset=$2 code_string="$3" message="$4"

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

################################################################################
# Error
################################################################################
declare -Ag Error__methods
Error__methods=(
	[invocation]=Error__static__invocation
	[argument]=Error__static__argument
	[undefined]=Error__static__undefined
	[already_defined]=Error__static__already_defined
	[undefined_method]=Error__static__undefined_method
	[illegal_instruction]=Error__static__illegal_instruction
	[_display]=Error__static__display_
)
readonly Error__methods

declare -Ag Error
Error=(
	[0]='Object__static__dispatch_ Error '
	[__name]=Error
	[__base]=Object
	[__methods]=Error__methods
)
readonly Error

__hbl__classes+=('Error')
