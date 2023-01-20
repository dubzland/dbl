##!/usr/bin/env bash

function Dict__init_() {
	local -n this="$1"
	$this.super || return

	this[_raw]="$1__raw_dict"
	declare -Ag "${this[_raw]}"
	local -n _raw="${this[_raw]}"
	_raw=()
}

function Dict__set() {
	[[ $# -eq 3 ]] || $Error.invocation $FUNCNAME "$@" || return
	local -n this="$1"

	local -n dict__ref="${this[_raw]}"
	dict__ref[$2]="$3"

	return $HBL_SUCCESS
}

function Dict__get() {
	[[ $# -eq 3 ]] || $Error.invocation $FUNCNAME "$@" || return
	[[ -n "$2" ]] || $Error.argument $FUNCNAME key "$2" || return

	local -n this="$1"

	local -n dict__ref="${this[_raw]}"
	local -n val_var__ref="$3"
	val_var__ref="${dict__ref[$2]}"

	return $HBL_SUCCESS
}

function Dict__has_key() {
	[[ $# -eq 2 ]] || $Error.invocation $FUNCNAME "$@" || return
	[[ -n "$2" ]] || $Error.argument $FUNCNAME key "$2" || return

	local -n this="$1"
	local -n dict__ref="${this[_raw]}"

	[[ -v dict__ref[$2] ]]
}

function Dict__to_associative_array() {
	[[ $# -eq 2 ]] || $Error.invocation $FUNCNAME "$@" || return
	[[ -n "$2" ]] || $Error.argument $FUNCNAME target "$2" || return

	local -n this="$1"

	local -n src__ref="${this[_raw]}"
	local -n tgt__ref="$2"

	for key in "${!src__ref[@]}"; do
		tgt__ref[$key]="${src__ref[$key]}"
	done

	return $HBL_SUCCESS
}

################################################################################
# Dict
################################################################################
declare -Ag Dict__methods
Dict__methods=()
readonly Dict__methods

declare -Ag Dict__prototype
Dict__prototype=(
	[__init]="$HBL_SELECTOR_METHOD Dict__init_"
	[set]="$HBL_SELECTOR_METHOD Dict__set"
	[get]="$HBL_SELECTOR_METHOD Dict__get"
	[has_key]="$HBL_SELECTOR_METHOD Dict__has_key"
	[to_associative_array]="$HBL_SELECTOR_METHOD Dict__to_associative_array"
)
readonly Dict__prototype

declare -Ag Dict
Dict=(
	[0]='Class__static__dispatch_ Dict '
	[__name]=Dict
	[__base]=Class
	[__methods]=Dict__methods
	[__prototype]=Dict__prototype
)

__hbl__classes+=('Dict')
