#!/usr/bin/env bash

function hbl::dict::set() {
	[[ $# -eq 3 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]] || hbl::error::argument 'dict' "$1" || exit
	[[ -n "$2" ]] || hbl::error::argument 'key' "$2" || exit

	hbl::dict::ensure_dict "$1" || exit

	local -n __ref=$1
	__ref[$2]="${@:3}"

	return $HBL_SUCCESS
}

function hbl::dict::has_key() {
	[[ $# -eq 2 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]] || hbl::error::argument 'dict' "$1" || exit
	[[ -n "$2" ]] || hbl::error::argument 'key' "$2" || exit

	hbl::dict::ensure_dict "$1" || exit

	local -n __ref=$1
	for key in "${!__ref[@]}"; do
		[[ "${key}" == "$2" ]] && return $HBL_SUCCESS
	done

	return $HBL_ERROR
}

function hbl::dict::get() {
	[[ $# -eq 3 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]] || hbl::error::argument 'dict' "$1" || exit
	[[ -n "$2" ]] || hbl::error::argument 'key' "$2" || exit
	[[ -n "$3" ]] || hbl::error::argument 'value_var' "$3" || exit

	hbl::dict::ensure_dict "$1" || exit

	local key
	key="$2"

	local -n value_var__ref=$3
	local -n dict__ref=$1
	if hbl::dict::has_key "${!dict__ref}" "$key"; then
		value_var__ref="${dict__ref[$key]}"
		return $HBL_SUCCESS
	fi

	return $HBL_ERROR
}

function hbl::dict::ensure_dict() {
	[[ $# -eq 1 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]] || hbl::error::argument 'dict' "$@" || exit

	hbl::util::is_defined "$1" \
		|| hbl::error::_undefined "${FUNCNAME[1]}" "$1" || return
	hbl::util::is_dict "$1" \
		|| hbl::error::_invalid_dict "${FUNCNAME[1]}" "$1" || return

	return $HBL_SUCCESS
}
