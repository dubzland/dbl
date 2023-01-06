#!/usr/bin/env bash

function hbl::util::is_defined() {
	if declare -p "$1" 2>&1 >/dev/null; then
		return 0
	fi
	return 1
}

function hbl::util::is_function() {
	declare -f -F "$1" 2>&1 >/dev/null
	return $?
}

function hbl::util::is_array() {
	if hbl::util::is_defined "$1"; then
		[[ "$(declare -p $1 2>/dev/null)" == "declare -a"* ]] && return 0
	fi
	return 1
}

function hbl::util::is_dict() {
	if hbl::util::is_defined "$1"; then
		[[ "$(declare -p $1 2>/dev/null)" == "declare -A"* ]] && return 0
	fi
	return 1
}

function hbl::util::string_to_constant() {
	local source
	source="$1"
	local -n target__ref="$2"
	local underscore=""
	hbl::util::string_to_underscore "${source}" underscore
	target__ref="${underscore^^}"
}

function hbl::util::string_to_underscore() {
	local source
	source="$1"
	local -n target__ref="$2"
	# Shellcheck doesn't seem to support nameref variables yet.
	# See https://github.com/koalaman/shellcheck/issues/1544.
	# shellcheck disable=SC2034
	target__ref="${source//[^a-zA-Z0-9]/_}"
}
