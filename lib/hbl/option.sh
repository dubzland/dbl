#!/usr/bin/env bash

function __hbl__Option__init() {
	[[ $# -eq 2 ]] || hbl__error__invocation "${@:2}" || exit
	[[ -n "$2" ]] || hbl__error__argument 'option_name' "$2" || exit

	local -n this="$1"

	$this.super
	this[_name]="$2"
	this[_type]=""
	this[_short_flag]=""
	this[_long_flag]=""
	this[_description]=""

	return $HBL_SUCCESS
}
