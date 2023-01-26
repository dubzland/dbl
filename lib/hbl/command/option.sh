#!/usr/bin/env bash

function __hbl__Command__Option__init() {
	[[ $# -eq 2 ]] || $Error.argument || return
	[[ -n "$2" ]] || $Error.argument || return

	local -n this="$1"

	$this.super || return

	this[name]="$2"
	this[type]=""
	this[short_flag]=""
	this[long_flag]=""
	this[description]=""

	return 0
}
