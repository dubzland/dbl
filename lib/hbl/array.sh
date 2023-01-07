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

function hbl::array::bubble_sort() {
	[[ $# -ge 2 ]] || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	hbl::util::is_array "$1" || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	local sortable swapped
	sortable=("${@:2}") swapped=0

	local -n array__ref="$1"
	array__ref=()

	for ((i = 0; i < ${#sortable[@]}; i++)); do
		for(( j = 0; j < ${#sortable[@]}-i-1; j++)); do
			if [[ "${sortable[j]}" > "${sortable[$((j+1))]}" ]]; then
				array__ref=${sortable[j]}
				sortable[$j]=${sortable[$((j+1))]}
				sortable[$((j+1))]=$array__ref
				swapped=1
			fi
		done
		[[ $swapped -eq 0 ]] && break
	done
	array__ref=("${sortable[@]}")

	return 0
}
