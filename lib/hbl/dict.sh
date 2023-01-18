##!/usr/bin/env bash

function hbl__dict__init_() {
	local this="$1"

	$this:super
}

function hbl__dict__set() {
	[[ $# -eq 3 ]] || hbl__error__invocation_ 1 "${@:2}" || return
	local this="$1"
	local dict key value
	key="$2" val="$3"

	$this._raw dict
	local -n dict__ref="$dict"
	dict__ref[$key]="$val"

	return $HBL_SUCCESS
}

function hbl__dict__get() {
	[[ $# -eq 3 ]] || hbl__error__invocation_ 1 "${@:2}" || return
	[[ -n "$2" ]] || hbl__error__argument_ 1 key "$2" || return

	local this="$1"
	local dict key val_var
	key="$2" val_var="$3"

	$this._raw dict
	local -n dict__ref="$dict"
	local -n val_var__ref="$val_var"
	val_var__ref="${dict__ref[$key]}"

	return $HBL_SUCCESS
}

function hbl__dict__has_key() {
	[[ $# -eq 2 ]] || hbl__error__invocation_ 1 "${@:2}" || return
	[[ -n "$2" ]] || hbl__error__argument_ 1 key "$2" || return

	local this="$1"
	local dict key val_var
	key="$2"

	$this._raw dict
	local -n dict__ref="$dict"

	[[ -v dict__ref[$key] ]]
}

function hbl__dict__to_dict() {
	[[ $# -eq 2 ]] || hbl__error__invocation_ 1 "${@:2}" || return
	[[ -n "$2" ]] || hbl__error__argument_ 1 target "$2" || return

	local this src tgt
	this="$1" tgt="$2"

	$this._raw src

	local -n src__ref="$src"
	local -n tgt__ref="$tgt"
	for key in "${!src__ref[@]}"; do
		tgt__ref[$key]="${src__ref[$key]}"
	done

	return $HBL_SUCCESS
}

################################################################################
# Dict
################################################################################
declare -Ag __hbl__Dict__vtbl
__hbl__Dict__vtbl=(
	[__next]=__hbl__Class__vtbl
)
readonly __hbl__Dict__vtbl

declare -Ag __hbl__Dict__pvtbl
__hbl__Dict__pvtbl=(
	[__ctor]=hbl__dict__init_
	[set]=hbl__dict__set
	[get]=hbl__dict__get
	[has_key]=hbl__dict__has_key
	[to_dict]=hbl__dict__to_dict
	[__next]=__hbl__Class__pvtbl
)
readonly __hbl__Dict__pvtbl

declare -Ag __hbl__Dict__pattrs
__hbl__Dict__pattrs=(
	[_raw]="$HBL_ASSOCIATIVE_ARRAY"
)
readonly __hbl__Dict__pattrs

declare -Ag __hbl__Dict__prefs
__hbl__Dict__prefs=()
readonly __hbl__Dict__prefs

declare -Ag __hbl__Dict
__hbl__Dict=(
	[__name]="Dict"
	[__ancestor]="Class"
	[__vtbl]=__hbl__Dict__vtbl
	[__pvtbl]=__hbl__Dict__pvtbl
	[__pattrs]=__hbl__Dict__pattrs
	[__prefs]=__hbl__Dict__prefs
)

declare -g Dict
Dict="hbl__object__dispatch_ __hbl__Dict__vtbl __hbl__Dict__vtbl __hbl__Dict '' "
readonly Dict

__hbl__classes+=('Dict')
