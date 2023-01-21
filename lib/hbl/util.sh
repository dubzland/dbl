#!/usr/bin/env bash

function hbl__util__is_defined() {
	[[ $# -eq 2 ]] || hbl__error__invocation_ 1 "${@:2}" || exit
	[[ -n "$2" ]] || hbl__error__argument_ 1 'var' "$2" || exit

	declare -p "$2" >/dev/null 2>&1 && return $HBL_SUCCESS

	return $HBL_ERROR
}

function hbl__util__is_function() {
	[[ $# -eq 2 ]] || hbl__error__invocation_ 1 "${@:2}" || exit
	[[ -n "$2" ]] || hbl__error__argument 'func' "$2" || exit

	declare -f -F "$2" >/dev/null 2>&1 && return $HBL_SUCCESS

	return $HBL_ERROR
}


if [[ ${BASH_VERSINFO[0]} -ge 5 && $FORCE_BASH4 -ne 1 ]]; then

function hbl__util__is_associative_array() {
	[[ $# -eq 2 ]] || hbl__error__invocation "$@" || exit
	[[ -n $2 ]] || hbl__error__argument 'dict' "$2" || exit

	local -n var=$2

	[[ ${var@a} = *A* ]]
}

else

function hbl__util__is_associative_array() {
	[[ $# -eq 2 ]] || hbl__error__invocation "$@" || exit
	[[ -n $2 ]] || hbl__error__argument 'dict' "$2" || exit

	declare -p "$2" 2>/dev/null | grep 'declare -A' >/dev/null && return $HBL_SUCCESS

	return $HBL_ERROR
}

fi

function hbl__util__dump_associative_array() {
	[[ $# -eq 2 ]] || hbl__error__invocation "$@" || exit
	[[ -n "$2" ]] || hbl__error__argument 'dict' "$2" || exit

	local name="$2"
	local -n name__ref="$name"

	printf "=== %s ===\n" "$name"
	printf "!: %s\n" "${!name__ref[@]}"
	printf "@: %s\n" "${name__ref[@]}"
	printf "### %s ###\n" "$name"

	return $HBL_SUCCESS
}

################################################################################
# Util
################################################################################
declare -Ag Util__methods
Util__methods=(
	[is_defined]=hbl__util__is_defined
	[is_function]=hbl__util__is_function
	[is_array]=hbl__util__is_array
	[is_associative_array]=hbl__util__is_associative_array
	[dump_associative_array]=hbl__util__dump_associative_array
)
readonly Util__methods

declare -Ag Util
Util=(
	[0]='Class__static__dispatch_ Util '
	[__name]=Util
	[__base]=Class
	[__methods]=Util__methods
)
readonly Util

__hbl__classes+=('Util')
