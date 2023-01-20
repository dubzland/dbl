#!/usr/bin/env bash

# @file hbl__array
# @brief A library for interacting with Bash arrays.
###############################################################################

function Array__init() {
	local -n this="$1"
	$this.super || return

	this[_raw]="$1__raw_array"
	declare -ag "${this[_raw]}"
	local -n _raw="${this[_raw]}"
	_raw=()
}

function Array__append() {
	[[ $# -ge 2 ]] || $Error.invocation 'Array:append' "$@" || return

	local -n this="$1"
	local -n _arr__ref="${this[_raw]}"

	_arr__ref+=("${@:2}")

	return $HBL_SUCCESS
}

function Array__bubble_sort() {
	[[ $# -eq 1 ]] || $Error.invocation $FUNCNAME "$@" || return

	local -n this="$1"

	local swapped
	swapped=0

	declare -a sortable

	local -n arr__ref="${this[_raw]}"

	sortable=("${arr__ref[@]}")

	for ((i = 0; i < ${#sortable[@]}; i++)); do
		for(( j = 0; j < ${#sortable[@]}-i-1; j++)); do
			if [[ "${sortable[j]}" > "${sortable[$((j+1))]}" ]]; then
				arr__ref=${sortable[j]}
				sortable[$j]=${sortable[$((j+1))]}
				sortable[$((j+1))]=$arr__ref
				swapped=1
			fi
		done
		[[ $swapped -eq 0 ]] && break
	done
	arr__ref=("${sortable[@]}")

	return $HBL_SUCCESS
}

function Array__contains() {
	[[ $# -eq 2 ]] || $Error.invocation $FUNCNAME "${@:2}" || return

	local -n this="$1"
	local haystack

	local -n haystack="${this[_raw]}"
	for val in "${haystack[@]}"; do
		[[ "$val" = "$2" ]] && return $HBL_SUCCESS
	done

	return $HBL_ERROR
}

function Array__to_array() {
	[[ $# -eq 2 ]] || hbl__error__invocation_ 1 "${@:2}" || return

	local -n this=$1
	local tgt="$2"

	local -n src__ref="${this[_raw]}"
	local -n tgt__ref="$tgt"
	tgt__ref=("${src__ref[@]}")

	return $HBL_SUCCESS
}

function Array__static__is_array() {
	[[ $# -eq 2 && "$1" = 'Array' ]] || $Error.invocation "$@" || exit
	[[ -n "$2" ]] || $Error.argument 'array' "$2" || exit

	[[ "$(declare -p "$2" 2>/dev/null)" == "declare -a"* ]] && return $HBL_SUCCESS

	return $HBL_ERROR
}

################################################################################
# Array
################################################################################
declare -Ag Array__methods
Array__methods=(
	[is_array]=Array__static__is_array
)
readonly Array__methods

declare -Ag Array__prototype
Array__prototype=(
	[__init]="$HBL_SELECTOR_METHOD Array__init"
	[append]="$HBL_SELECTOR_METHOD Array__append"
	[bubble_sort]="$HBL_SELECTOR_METHOD Array__bubble_sort"
	[sort]="$HBL_SELECTOR_METHOD Array__bubble_sort"
	[contains]="$HBL_SELECTOR_METHOD Array__contains"
	[to_array]="$HBL_SELECTOR_METHOD Array__to_array"
)
readonly Array__prototype

declare -Ag Array
Array=(
	[0]='Class__static__dispatch_ Array '
	[__name]=Array
	[__base]=Class
	[__methods]=Array__methods
	[__prototype]=Array__prototype
)

__hbl__classes+=('Array')
