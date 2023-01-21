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
	_raw=("${@:2}")
	this[_size]=${#_raw[@]}
}

function Array__at() {
	[[ $# -ge 3 ]] || $Error.invocation 'Array#at' "$@" || return
	local -n this="$1"
	local -n _raw=${this[_raw]}

	# printf "this[_size]: %s\n" ${this[_size]} >&3

	[[ $2 -lt ${this[_size]} && $2 -gt $((0-this[_size])) ]] ||
		$Error.argument 'Array#at' 'index' "$2 is out of range" || return

	local index=$2
	[[ $index -lt 0 ]] && index=$((this[_size]+$index)) || true
	local -n ret__ref="$3"

	ret__ref=${_raw[index]}

	return $HBL_SUCCESS
}

function Array__shift() {
	[[ $# -ge 1 ]] || $Error.invocation 'Array#shift' "$@" || return
	local -n this="$1"
	local -n _raw=${this[_raw]}

	[[ ${this[_size]} -gt 0 ]] ||
		$Error.illegal_instruction 'Array#shift' \
			'cannot shift an empty array' || return

	if [[ $# -gt 1 ]]; then
		local -n ret__ref="$2"
		ret__ref="${_raw[0]}"
	fi
	_raw=("${_raw[@]:1}")
	this[_size]=${#_raw[@]}

	return $HBL_SUCCESS
}

function Array__unshift() {
	[[ $# -ge 2 ]] || $Error.invocation 'Array#shift' "$@" || return
	local -n this="$1"
	local -n _raw=${this[_raw]}

	_raw=("${@:2}" "${_raw[@]}")
	this[_size]=${#_raw[@]}

	return $HBL_SUCCESS
}

function Array__push() {
	[[ $# -ge 2 ]] || $Error.invocation 'Array#push' "$@" || return

	local -n this="$1"
	local -n _raw="${this[_raw]}"

	_raw+=("${@:2}")
	this[_size]=${#_raw[@]}

	return $HBL_SUCCESS
}

function Array__pop() {
	[[ $# -ge 1 ]] || $Error.invocation 'Array#pop' "$@" || return

	local -n this="$1"
	local -n _raw="${this[_raw]}"

	if [[ $# -gt 1 ]]; then
		local -n var__ref="$2"
		var__ref="${_raw[-1]}"
	fi

	unset _raw[-1];
	this[_size]=${#_raw[@]}

	return $HBL_SUCCESS
}

function Array__bubble_sort() {
	[[ $# -eq 1 ]] || $Error.invocation 'Array#sort' "$@" || return

	local -n this="$1"

	local swapped tmp
	swapped=0

	declare -a sortable

	local -n _raw="${this[_raw]}"

	sortable=("${_raw[@]}")

	for ((i = 0; i < ${#sortable[@]}; i++)); do
		for(( j = 0; j < ${#sortable[@]}-i-1; j++)); do
			if [[ "${sortable[j]}" > "${sortable[$((j+1))]}" ]]; then
				tmp=${sortable[j]}
				sortable[$j]=${sortable[$((j+1))]}
				sortable[$((j+1))]=$tmp
				swapped=1
			fi
		done
		[[ $swapped -eq 0 ]] && break
	done
	_raw=("${sortable[@]}")

	return $HBL_SUCCESS
}

function Array__contains() {
	[[ $# -eq 2 ]] || $Error.invocation 'Array#contains' "${@:2}" || return

	local -n this="$1"

	local -n _raw="${this[_raw]}"
	for val in "${_raw[@]}"; do
		[[ "$val" = "$2" ]] && return $HBL_SUCCESS
	done

	return $HBL_ERROR
}

function Array__to_array() {
	[[ $# -eq 2 ]] || hbl__error__invocation_ 1 "${@:2}" || return

	local -n this=$1
	local tgt="$2"

	local -n _raw="${this[_raw]}"
	local -n tgt__ref="$tgt"
	tgt__ref=("${_raw[@]}")

	return $HBL_SUCCESS
}

if [[ ${BASH_VERSINFO[0]} -ge 5 && $FORCE_BASH4 -ne 1 ]]; then
function Array__static__is_array() {
	[[ $# -eq 2 && "$1" = 'Array' ]] || $Error.invocation "$@" || exit
	[[ -n "$2" ]] || $Error.argument 'array' "$2" || exit

	local -n _v="$2"
	[[ ${_v@a} = *a* ]]
}
else
function Array__static__is_array() {
	printf "BASH4\n" >&3
	[[ $# -eq 2 && "$1" = 'Array' ]] || $Error.invocation "$@" || exit
	[[ -n "$2" ]] || $Error.argument 'array' "$2" || exit

	[[ "$(declare -p "$2" 2>/dev/null)" == "declare -a"* ]] && return $HBL_SUCCESS

	return $HBL_ERROR
}
fi

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
	[at]="$HBL_SELECTOR_METHOD Array__at"
	[shift]="$HBL_SELECTOR_METHOD Array__shift"
	[unshift]="$HBL_SELECTOR_METHOD Array__unshift"
	[push]="$HBL_SELECTOR_METHOD Array__push"
	[pop]="$HBL_SELECTOR_METHOD Array__pop"
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
