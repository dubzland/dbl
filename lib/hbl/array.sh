#!/usr/bin/env bash

function hbl::array::contains() {
	[[ $# -eq 2 ]] || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	if hbl::util::is_array $1; then
		local -n __ref=$1
		for key in "${__ref[@]}"; do
			[[ "${key}" == "$2" ]] && return 0
		done
	else
		return 2
	fi

	return 1
}

function hbl::array::append() {
	[[ $# -ge 2 ]] || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	hbl::util::is_array "$1" || hbl::error::invalid_args "${FUNCNAME[0]}" || return

	local -n array__ref="$1"; shift
	array__ref+=("$@")
	return 0
}
