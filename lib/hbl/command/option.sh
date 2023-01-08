#!/usr/bin/env bash

declare -ag HBL_OPTION_TYPES
HBL_OPTION_TYPES=(string number flag dir)
readonly HBL_OPTION_TYPES

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
	option_id__ref="${command_id}__option_${option_index}"

	declare -Ag "${option_id__ref}"
	hbl::dict::set "${option_id__ref}" 'name' "$option_name"
	hbl::dict::set "${option_id__ref}" 'id' "$option_id__ref"

	return 0
}

function hbl::command::option::set_type() {
	[[ $# -eq 2 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]] || hbl::error::argument 'option_id' "$1" || exit
	[[ -n "$2" ]] || hbl::error::argument 'option_type' "$2" || exit

	hbl::array::contains HBL_OPTION_TYPES "$2" \
		|| hbl::error::argument 'type' "$2" || exit

	hbl::command::option::ensure_option "$1" || exit

	local option_id option_type
	option_id="$1" option_type="$2"
	local -n option__ref="$option_id"
	option__ref[type]="$option_type"

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
