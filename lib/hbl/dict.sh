#!/usr/bin/env bash

function hbl::dict::set() {
	[[ $# -ge 3 ]] || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	if hbl::util::is_dict $1; then
		local -n __ref=$1
		__ref[$2]="${@:3}"
	else
		return $HBL_UNDEFINED
	fi

	return $HBL_SUCCESS
}

function hbl::dict::has_key() {
	[[ $# -eq 2 ]] || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	if hbl::util::is_dict $1; then
		local -n __ref=$1
		for key in "${!__ref[@]}"; do
			[[ "${key}" == "$2" ]] && return $HBL_SUCCESS
		done
	else
		return $HBL_UNDEFINED
	fi

	return $HBL_ERROR
}

function hbl::dict::get() {
	[[ $# -eq 3 ]] || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	local -n __ret=$3

	if hbl::util::is_dict $1; then
		local -n __ref=$1
		if hbl::dict::has_key $1 $2; then
			__ret="${__ref[$2]}"
			return $HBL_SUCCESS
		fi
	else
		return $HBL_UNDEFINED
	fi

	return $HBL_ERROR
}
