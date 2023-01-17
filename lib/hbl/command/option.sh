#!/usr/bin/env bash

declare -ag HBL_OPTION_TYPES
HBL_OPTION_TYPES=(string number flag dir)
readonly HBL_OPTION_TYPES

function hbl__command__option__init_() {
	[[ $# -eq 2 ]] || hbl__error__invocation "${@:2}" || exit
	[[ -n "$2" ]] || hbl__error__argument 'option_name' "$2" || exit

	local this="$1"

	$this:super
	$this.name= "$2"

	return $HBL_SUCCESS
}

$Class:define Option hbl__command__option__init_

$Option:attr name $HBL_STRING
$Option:attr type $HBL_STRING
$Option:attr short_flag $HBL_STRING
$Option:attr long_flag $HBL_STRING
$Option:attr description $HBL_STRING
