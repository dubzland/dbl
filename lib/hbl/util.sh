#!/usr/bin/env bash

function hbl::util::is_defined() {
	[[ $# -eq 1 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]] || hbl::error::argument 'var' "$1" || exit

	if declare -p "$1" >/dev/null 2>&1; then
		return $HBL_SUCCESS
	fi
	return $HBL_ERROR
}

function hbl::util::is_function() {
	[[ $# -eq 1 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]] || hbl::error::argument 'func' "$1" || exit

	declare -f -F "$1" 2>/dev/null && return $HBL_SUCCESS

	return $HBL_ERROR
}

function hbl::util::is_array() {
	[[ $# -eq 1 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]] || hbl::error::argument 'array' "$1" || exit

	[[ "$(declare -p "$1" 2>/dev/null)" == "declare -a"* ]] && return $HBL_SUCCESS

	return $HBL_ERROR
}

function hbl::util::is_dict() {
	[[ $# -eq 1 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]] || hbl::error::argument 'dict' "$1" || exit

	[[ "$(declare -p "$1" 2>/dev/null)" == "declare -A"* ]] && return $HBL_SUCCESS

	return $HBL_ERROR
}

function hbl::util::string_to_underscore() {
	[[ $# -eq 2 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$2" ]] || hbl::error::argument 'target_var' "$2" || exit

	local source
	source="$1"
	local -n target__ref="$2"
	# Shellcheck doesn't seem to support nameref variables yet.
	# See https://github.com/koalaman/shellcheck/issues/1544.
	# shellcheck disable=SC2034
	target__ref="${source//[^a-zA-Z0-9]/_}"
}

function hbl::util::string_to_constant() {
	[[ $# -eq 2 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$2" ]] || hbl::error::argument 'target_var' "$2" || exit

	local source underscore
	source="$1"
	local -n target__ref="$2"
	target__ref=""

	hbl::util::string_to_underscore "${source}" underscore
	target__ref="${underscore^^}"
}
