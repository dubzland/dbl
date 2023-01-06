#!/usr/bin/env bash

readonly HBL_EXAMPLES_SUFFIX="_EXAMPLES"

function hbl::command::examples::init() {
	local command_id="$1"
	local -n command__ref="${HBL_COMMANDS[${command_id}]}"

	command__ref[examples]="${command__ref[module]}${HBL_EXAMPLES_SUFFIX}"
	declare -Ag "${command__ref[examples]}"
}

