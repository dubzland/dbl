#!/usr/bin/env bash

function hbl::command::option::create() {
	[[ $# -eq 3 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]] || hbl::error::argument 'command_id' "$1" || exit
	[[ -n "$2" ]] || hbl::error::argument 'option_name' "$2" || exit
	[[ -n "$3" ]] || hbl::error::argument 'option_id_var' "$3" || exit

	hbl::command::ensure_command "$1" || exit

	local command_id option_name
	command_id="$1" option_name="$2"
	local option_index=0

	local -n option_id__ref=$3
	option_id__ref="${command_id}_OPTION_${option_index}"

	declare -Ag "${option_id__ref}"
	hbl::dict::set "${option_id__ref}" name "$option_name"

	return 0
}

function hbl::command::option::set_type() {
	[[ $# -eq 2 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]] || hbl::error::argument 'option_id' "$1" || exit
	[[ -n "$2" ]] || hbl::error::argument 'type' "$2" || exit

	hbl::command::option::ensure_option "$1" || exit

	return 0
}

function hbl::command::option::ensure_option() {
	[[ $# -eq 1 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]] || hbl::error::argument 'option_id' "$@" || exit

	hbl::util::is_defined "$1" \
		|| hbl::error::_undefined "${FUNCNAME[1]}" "$1" || return
	hbl::util::is_dict "$1" \
		|| hbl::error::_invalid_option "${FUNCNAME[1]}" "$1" || return

	return $HBL_SUCCESS
}
