#!/usr/bin/env bash

function Option__init() {
	[[ $# -eq 2 ]] || hbl__error__invocation "${@:2}" || exit
	[[ -n "$2" ]] || hbl__error__argument 'option_name' "$2" || exit

	local -n this="$1"

	$this.super
	this[name]="$2"
	this[type]=""
	this[short_flag]=""
	this[long_flag]=""
	this[description]=""

	return $HBL_SUCCESS
}

################################################################################
# Option
################################################################################
declare -Ag Option__prototype
Option__prototype=(
	[__init]="$HBL_SELECTOR_METHOD Option__init"
	[command]="$HBL_SELECTOR_REFERENCE Command"
)
readonly Option__prototype

declare -Ag Option
Option=(
	[0]='Class__static__dispatch_ Option '
	[__name]=Option
	[__base]=Class
	[__prototype]=Option__prototype
)
readonly Option

__hbl__classes+=('Option')
