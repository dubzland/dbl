##!/usr/bin/env bash

function __hbl__Dict__init() {
	$Error.argument
	[[ $# -eq 1 ]] || $Error.argument || return
	local -n this="$1"
	$this.super || return

	this[_raw]="$1__raw_dict"
	this[size]=0
	declare -Ag "${this[_raw]}"
	local -n _raw="${this[_raw]}"
	_raw=()
}

function __hbl__Dict__set() {
	[[ $# -eq 3 && -n "$1" && -n "$2" ]] || $Error.argument || return
	local -n this="$1"

	local -n _raw="${this[_raw]}"
	_raw[$2]="$3"
	this[size]=${#_raw[@]}

	return 0
}

function __hbl__Dict__get() {
	[[ $# -eq 3 && -n "$1" && -n "$2" ]] || $Error.argument || return

	local -n this="$1"

	local -n _raw="${this[_raw]}"
	local -n val_var__ref="$3"
	val_var__ref="${_raw[$2]}"

	return 0
}

function __hbl__Dict__has_key() {
	[[ $# -eq 2 && -n "$1" && -n "$2" ]] || $Error.argument || return

	local -n this="$1"
	local -n _raw="${this[_raw]}"

	[[ -v _raw[$2] ]]
}

function __hbl__Dict__to_associative_array() {
	[[ $# -eq 2 && -n "$1" && -n "$2" ]] || $Error.argument || return

	local -n this="$1"

	local -n src__ref="${this[_raw]}"
	local -n tgt__ref="$2"

	for key in "${!src__ref[@]}"; do
		tgt__ref[$key]="${src__ref[$key]}"
	done

	return 0
}
