#!/usr/bin/env bash

function hbl::command::option::create() {
	local command_id option_name
	command_id="$1" option_name="$2"
	local option_index=0

	local -n option_id__ref=$3
	option_id__ref="${command_id}_OPTION_${option_index}"

	declare -Ag "${option_id__ref}"
	hbl::dict::set "${option_id__ref}" name "$option_name"

	return 0
}
