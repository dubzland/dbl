#!/usr/bin/env bash

function hbl::array::contains() {
	[[ $# -eq 2 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]]  || hbl::error::argument 'haystack' "$1" || exit

	hbl::array::ensure_array "$1" || exit

	local -n haystack__ref="$1"
	for val in "${haystack__ref[@]}"; do
		[[ "${val}" == "$2" ]] && return $HBL_SUCCESS
	done

	return $HBL_ERROR
}

function hbl::array::append() {
	[[ $# -ge 2 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]]  || hbl::error::argument 'array' "$1" || exit

	hbl::array::ensure_array "$1" || exit

	local -n array__ref="$1"
	array__ref+=("${@:2}")

	return $HBL_SUCCESS
}

function hbl::array::bubble_sort() {
	[[ $# -eq 1 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]]  || hbl::error::argument 'array' "$1" || exit

	hbl::array::ensure_array "$1" || exit

	local swapped
	swapped=0

	declare -a sortable

	local -n array__ref="$1"
	sortable=("${array__ref[@]}")

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

function hbl::array::ensure_array() {
	[[ $# -eq 1 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]] || hbl::error::argument 'array' "$@" || exit

	hbl::util::is_defined "$1" \
		|| hbl::error::_undefined 2 "$1" || return
	hbl::util::is_array "$1" \
		|| hbl::error::_invalid_array 2 "$1" || return

	return $HBL_SUCCESS
}
