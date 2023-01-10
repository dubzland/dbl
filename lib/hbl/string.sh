#!/usr/bin/env bash

function hbl::string::to_underscore() {
	[[ $# -eq 2 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$2" ]] || hbl::error::argument 'target_var' "$2" || exit

	local source
	source="$1"
	local -n target__ref="$2"
	# shellcheck disable=SC2034
	target__ref="${source//[^a-zA-Z0-9]/_}"
}

function hbl::string::to_constant() {
	[[ $# -eq 2 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$2" ]] || hbl::error::argument 'target_var' "$2" || exit

	local source underscore
	source="$1"
	local -n target__ref="$2"
	target__ref=""

	hbl::string::to_underscore "${source}" underscore
	# shellcheck disable=SC2034
	target__ref="${underscore^^}"
}