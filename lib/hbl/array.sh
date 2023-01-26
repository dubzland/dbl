#!/usr/bin/env bash

# @name Array
# @brief A library for interacting with Bash arrays.

###############################################################################
# @description Determine whether or not a variable is a bash array.
#
# @example
#    $Array.is_array myvar
#
# @arg $1 string A variable name to check
#
# @exitcode $HBL_SUCCESS If successful.
# @exitcode $HBL_ERROR If the argument is not an array
#
function __hbl__Array__static__is_array() {
	[[ $# -eq 1 && -n "$1" ]] || return $HBL_ERR_ARGUMENT
	$Util.is_defined "$1" || return $HBL_ERR_ARGUMENT

	if [[ ${BASH_VERSINFO[0]} -ge 5 && $FORCE_BASH4 -ne 1 && -z ${-//[^u]/} ]]; then
		local -n __ref="$1"
		[[ "${__ref@a}" = *a* ]]
	else
		[[ "$(declare -p "$1" 2>/dev/null)" == "declare -a"* ]]
	fi
}

###############################################################################
# @description Extract array element at the specified position
#
# @example
#    $Array.at myarr 1 myvar
#
# @arg $1 string A bash array name
# @arg $2 number Index of the array element to be retrieved
# @arg $3 string Name of the var to hold the extracted value
#
# @exitcode 0 If successful.
# @exitcode 1 If the array item does not exist
#
function __hbl__Array__static__at() {
	[[ $# -eq 3 && -n $1 && -n $2 && -n $3 ]] || return $HBL_ERR_ARGUMENT
	__hbl__Array__static__is_array $1 || return $HBL_ERR_ARGUMENT
	local -n arr__ref="$1"
	local arr_size=${#arr__ref[@]}

	[[ $2 -lt $arr_size && $2 -gt $((0-arr_size)) ]] ||
		return $HBL_ERR_ARGUMENT

	local -n ret__ref=$3
	ret__ref=${arr__ref[$2]}

	return $HBL_SUCCESS
}

###############################################################################
# @description Remove (and optionally return) the first element of a bash array.
#
# @example
#    $Array.shift myarr
#
# @arg $1 string A bash array name
# @arg $2 string Name of a variable to hold the removed value (Optional)
#
# @exitcode 0 If successful.
# @exitcode 1 If the array is empty
#
function __hbl__Array__static__shift() {
	[[ $# -ge 1 && -n "$1" ]] || return $HBL_ERR_ARGUMENT
	__hbl__Array__static__is_array $1 || return $HBL_ERR_ARGUMENT

	local -n __ref=$1

	[[ ${#__ref[@]} -gt 0 ]] || return $HBL_ERR_ILLEGAL_INSTRUCTION

	if [[ $# -gt 1 ]]; then
		local -n ret__ref="$2"
		ret__ref="${__ref[0]}"
	fi
	__ref=("${__ref[@]:1}")

	return $HBL_SUCCESS
}

###############################################################################
# @description Prepend a value to the beginning of a bash array.
#
# @example
#    $Array.unshift myarr 'value'
#
# @arg $1 string A bash array name
# @arg $2 string Value to be prepended (more values may be specified)
#
# @exitcode 0 If successful.
# @exitcode 1 If the array is empty
#
function __hbl__Array__static__unshift() {
	[[ $# -ge 2 && -n "$1" ]] || return $HBL_ERR_ARGUMENT
	__hbl__Array__static__is_array $1 || return $HBL_ERR_ARGUMENT

	local -n __ref=$1; shift
	__ref=("$@" "${__ref[@]}")

	return $HBL_SUCCESS
}

###############################################################################
# @description Append a value to the end of a bash array.
#
# @example
#    $Array.push myarr 'value'
#
# @arg $1 string A bash array name
# @arg $2 string Value to be appended (more values may be specified)
#
# @exitcode 0 If successful.
#
function __hbl__Array__static__push() {
	[[ $# -ge 2 && -n "$1" ]] || return $HBL_ERR_ARGUMENT
	__hbl__Array__static__is_array $1 || return $HBL_ERR_ARGUMENT

	local -n __ref="$1"; shift
	__ref+=("$@")

	return $HBL_SUCCESS
}

###############################################################################
# @description Removes (and optionally returns) the last value from a bash array.
#
# @example
#    $Array.pop myarr
#
# @arg $1 string A bash array name
# @arg $2 string Variable name to hold the popped value (Optional)
#
# @exitcode 0 If successful.
# @exitcode 1 Empty array was passed
#
function __hbl__Array__static__pop() {
	[[ $# -ge 1 && -n "$1" ]] || return $HBL_ERR_ARGUMENT
	__hbl__Array__static__is_array $1 || return $HBL_ERR_ARGUMENT

	local -n __ref="$1"; shift
	[[ ${#__ref[@]} -gt 0 ]] || return $HBL_ERR_ARGUMENT

	if [[ $# -eq 1 ]]; then
		local -n var__ref="$1"
		var__ref="${__ref[-1]}"
	fi

	unset __ref[-1];

	return $HBL_SUCCESS
}

###############################################################################
# @description Sorts the bash array in-place (using  bubble-sort algorithm).
#
# @example
#    $Array.pop myarr
#
# @arg $1 string A bash array name
#
# @exitcode 0 If successful.
#
function __hbl__Array__static__sort() {
	[[ $# -eq 1 && -n "$1" ]] || return $HBL_ERR_ARGUMENT
	__hbl__Array__static__is_array $1 || return $HBL_ERR_ARGUMENT

	local -n __ref="$1"

	if [[ ${#__ref[@]} -gt 0 ]]; then

		local swapped tmp
		swapped=0 tmp=""

		local -a sortable

		sortable=("${__ref[@]}")

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
		__ref=("${sortable[@]}")
	fi

	return $HBL_SUCCESS
}

###############################################################################
# @description Checks for the existence of a value in a bash array.
#
# @example
#    $Array.contains myarr 'needle'
#
# @arg $1 string A bash array name
# @arg $2 string Value to search for
#
# @exitcode 0 If the value is present
# @exitcode 1 If the value is not present
#
function __hbl__Array__static__contains() {
	[[ $# -eq 2 && -n "$1" ]] || return $HBL_ERR_ARGUMENT
	# __hbl__Array__static__is_array $1 || return $HBL_ERR_ARGUMENT

	local val=""
	local -n __ref="$1"; shift
	[[ ${#__ref[@]} -gt 0 ]] || return $HBL_ERROR

	for val in "${__ref[@]}"; do
		[[ "$val" = "$1" ]] && return $HBL_SUCCESS
	done

	return $HBL_ERROR
}

function __hbl__Array__init() {
	local -n this="$1"
	$this.super || return

	this[_raw]="$1__raw_array"
	declare -ag "${this[_raw]}"
	local -n _raw="${this[_raw]}"
	_raw=("${@:2}")
	this[size]=${#_raw[@]}
}

function __hbl__Array__at() {
	[[ $# -ge 3 ]] || return $HBL_ERR_ARGUMENT
	local -n this="$1"; shift
	__hbl__Array__static__at ${this[_raw]} "$@"
}

function __hbl__Array__shift() {
	[[ $# -ge 1 ]] || return $HBL_ERR_ARGUMENT
	local -n this="$1"; shift
	local -n _raw="${this[_raw]}"

	__hbl__Array__static__shift ${this[_raw]} "$@" || return

	this[size]=${#_raw[@]}

	return $HBL_SUCCESS
}

function __hbl__Array__unshift() {
	[[ $# -ge 2 ]] || return $HBL_ERR_ARGUMENT
	local -n this="$1"; shift
	local -n _raw="${this[_raw]}"

	__hbl__Array__static__unshift ${this[_raw]} "$@" || return

	this[size]=${#_raw[@]}

	return $HBL_SUCCESS
}

function __hbl__Array__push() {
	[[ $# -ge 2 ]] || return $HBL_ERR_ARGUMENT
	local -n this="$1"; shift
	local -n _raw="${this[_raw]}"

	__hbl__Array__static__push ${this[_raw]} "$@" || return

	this[size]=${#_raw[@]}

	return $HBL_SUCCESS
}

function __hbl__Array__pop() {
	[[ $# -ge 2 ]] || return $HBL_ERR_ARGUMENT
	local -n this="$1"; shift
	local -n _raw="${this[_raw]}"

	__hbl__Array__static__pop ${this[_raw]} "$@" || return

	this[size]=${#_raw[@]}

	return $HBL_SUCCESS
}

function __hbl__Array__sort() {
	[[ $# -eq 1 ]] || return $HBL_ERR_ARGUMENT
	local -n this="$1"; shift

	__hbl__Array__static__sort ${this[_raw]} || return

	return $HBL_SUCCESS
}

function __hbl__Array__contains() {
	[[ $# -ge 2 ]] || return $HBL_ERR_ARGUMENT
	local -n this="$1"; shift

	__hbl__Array__static__contains ${this[_raw]} "$@"
}

function __hbl__Array__to_array() {
	[[ $# -eq 2 ]] || return $HBL_ERR_ARGUMENT

	local -n this=$1
	local tgt="$2"

	local -n _raw="${this[_raw]}"
	local -n tgt__ref="$tgt"
	tgt__ref=("${_raw[@]}")

	return $HBL_SUCCESS
}
