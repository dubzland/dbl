#!/usr/bin/env bash

function hbl__util__is_defined() {
	[[ $# -eq 2 ]] || hbl__error__invocation_ 1 "${@:2}" || exit
	[[ -n "$2" ]] || hbl__error__argument_ 1 'var' "$2" || exit

	declare -p "$2" >/dev/null 2>&1 && return $HBL_SUCCESS

	return $HBL_ERROR
}

function hbl__util__is_function() {
	[[ $# -eq 2 ]] || hbl__error__invocation_ 1 "${@:2}" || exit
	[[ -n "$2" ]] || hbl__error__argument 'func' "$2" || exit

	declare -f -F "$2" >/dev/null 2>&1 && return $HBL_SUCCESS

	return $HBL_ERROR
}

function hbl__util__is_array() {
	[[ $# -eq 2 ]] || hbl__error__invocation_ 1 "${@:2}" || exit
	[[ -n "$2" ]] || hbl__error__argument_ 1 'array' "$2" || exit

	[[ "$(declare -p "$2" 2>/dev/null)" == "declare -a"* ]] && return $HBL_SUCCESS

	return $HBL_ERROR
}

function hbl__util__is_dict() {
	[[ $# -eq 2 ]] || hbl__error__invocation_ 1 "${@:2}" || exit
	[[ -n "$2" ]] || hbl__error__argument_ 'dict' "$2" || exit

	declare -p "$2" 2>/dev/null | grep 'declare -A' >/dev/null && return $HBL_SUCCESS

	return $HBL_ERROR
}

################################################################################
# Util
################################################################################
declare -Ag __hbl__Util__vtbl
__hbl__Util__vtbl=(
	[is_defined]=hbl__util__is_defined
	[is_function]=hbl__util__is_function
	[is_array]=hbl__util__is_array
	[is_dict]=hbl__util__is_dict
	[__next]=__hbl__Class__vtbl
)
readonly __hbl__Util__vtbl

declare -Ag __hbl__Util__pvtbl
__hbl__Util__pvtbl=()
readonly __hbl__Util__pvtbl

declare -Ag __hbl__Util__pattrs
__hbl__Util__pattrs=()
readonly __hbl__Util__pattrs

declare -Ag __hbl__Util__prefs
__hbl__Util__prefs=()
readonly __hbl__Util__prefs

declare -Ag __hbl__Util
__hbl__Util=(
	[__name]="Util"
	[__ancestor]="Class"
	[__vtbl]=__hbl__Util__vtbl
	[__pvtbl]=__hbl__Util__pvtbl
	[__pattrs]=__hbl__Util__pattrs
	[__prefs]=__hbl__Util__prefs
)

declare -g Util
Util="hbl__object__dispatch_ __hbl__Util__vtbl __hbl__Util__vtbl __hbl__Util '' "
readonly Util

__hbl__classes+=('Util')
