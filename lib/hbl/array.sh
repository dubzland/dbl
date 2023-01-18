#!/usr/bin/env bash

# @file hbl__array
# @brief A library for interacting with Bash arrays.
###############################################################################

function hbl__array__init_() {
	local this="$1"

	$this:super
}

function hbl__array__append() {
	[[ $# -ge 2 ]] || hbl__error__invocation_ 1 "${@:2}" || return

	local this="$1"
	local _arr

	$this._raw _arr
	local -n _arr__ref=$_arr
	_arr__ref+=("${@:2}")

	return $HBL_SUCCESS
}

function hbl__array__bubble_sort() {
	[[ $# -eq 1 ]] || hbl__error__invocation_ 1 "${@:2}" || return

	local this="$1"

	local arr swapped
	swapped=0

	$this._raw arr

	declare -a sortable

	local -n arr__ref="$arr"
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

function hbl__array__contains() {
	[[ $# -eq 2 ]] || hbl__error__invocation_ 1 "${@:2}" || return

	local this="$1"
	local haystack

	$this._raw haystack
	local -n haystack__ref="$haystack"
	for val in "${haystack__ref[@]}"; do
		[[ "$val" = "$2" ]] && return $HBL_SUCCESS
	done

	return $HBL_ERROR
}

function hbl__array__to_array() {

	puts "here\n" >&3
	[[ $# -eq 2 ]] || hbl__error__invocation_ 1 "${@:2}" || return

	local this src tgt
	this="$1" tgt="$2"

	$this._raw src

	local -n src__ref="$src"
	local -n tgt__ref="$tgt"
	tgt__ref=("${src__ref[@]}")

	return $HBL_SUCCESS
}

################################################################################
# Array
################################################################################
declare -Ag __hbl__Array__vtbl
__hbl__Array__vtbl=(
	[__next]=__hbl__Class__vtbl
)
readonly __hbl__Array__vtbl

declare -Ag __hbl__Array__pvtbl
__hbl__Array__pvtbl=(
	[__ctor]=hbl__array__init_
	[append]=hbl__array__append
	[bubble_sort]=hbl__array__bubble_sort
	[sort]=hbl__array__bubble_sort
	[contains]=hbl__array__contains
	[to_array]=hbl__array__to_array
	[__next]=__hbl__Class__pvtbl
)
readonly __hbl__Array__pvtbl

declare -Ag __hbl__Array__pattrs
__hbl__Array__pattrs=(
	[_raw]="$HBL_ARRAY"
)
readonly __hbl__Array__pattrs

declare -Ag __hbl__Array__prefs
__hbl__Array__prefs=()
readonly __hbl__Array__prefs

declare -Ag __hbl__Array
__hbl__Array=(
	[__name]="Array"
	[__ancestor]="Class"
	[__vtbl]=__hbl__Array__vtbl
	[__pvtbl]=__hbl__Array__pvtbl
	[__pattrs]=__hbl__Array__pattrs
	[__prefs]=__hbl__Array__prefs
)

declare -g Array
Array="hbl__object__dispatch_ __hbl__Array__vtbl __hbl__Array__vtbl __hbl__Array '' "
readonly Array

__hbl__classes+=('Array')
