#!/usr/bin/env bash

function hbl__option__init_() {
	[[ $# -eq 2 ]] || hbl__error__invocation "${@:2}" || exit
	[[ -n "$2" ]] || hbl__error__argument 'option_name' "$2" || exit

	local this="$1"

	$this:super
	$this.name= "$2"

	return $HBL_SUCCESS
}

################################################################################
# Option
################################################################################
declare -Ag __hbl__Option__vtbl
__hbl__Option__vtbl=(
	[__next]=__hbl__Class__vtbl
)
readonly __hbl__Option__vtbl

declare -Ag __hbl__Option__pvtbl
__hbl__Option__pvtbl=(
	[__ctor]=hbl__option__init_
	[__next]=__hbl__Class__pvtbl
)
readonly __hbl__Option__pvtbl

declare -Ag __hbl__Option__pattrs
__hbl__Option__pattrs=(
	[name]=$HBL_STRING
	[type]=$HBL_STRING
	[short_flag]=$HBL_STRING
	[long_flag]=$HBL_STRING
	[description]=$HBL_STRING
)
readonly __hbl__Option__pattrs

declare -Ag __hbl__Option__prefs
__hbl__Option__prefs=(
	[command]='Command'
)
readonly __hbl__Option__prefs

declare -Ag __hbl__Option
__hbl__Option=(
	[__name]="Option"
	[__ancestor]="Class"
	[__vtbl]=__hbl__Option__vtbl
	[__pvtbl]=__hbl__Option__pvtbl
	[__pattrs]=__hbl__Option__pattrs
	[__prefs]=__hbl__Option__prefs
)

declare -g Option
Option="hbl__object__dispatch_ __hbl__Option__vtbl __hbl__Option__vtbl __hbl__Option '' "
readonly Option
__hbl__classes+=('Option')
