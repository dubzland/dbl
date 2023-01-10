#!/usr/bin/env bash

function hbl::command::create() {
	[[ $# -eq 3 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]]  || hbl::error::argument "command_name" "$1" || exit
	[[ -n "$2" ]]  || hbl::error::argument "command_entrypoint" "$2" || exit
	[[ -n "$3" ]]  || hbl::error::argument "command_id_var" "$3" || exit

	local command_index
	local -n command_id__ref="$3"

	command_index="${#__hbl_commands[@]}"
	command_id__ref="__hbl_command_${command_index}"
	declare -Ag "${command_id__ref}"

	hbl::dict::set "$command_id__ref" '_id'         "$command_id__ref"
	hbl::dict::set "$command_id__ref" '_parent'     ''
	hbl::dict::set "$command_id__ref" '_name'       "$1"
	hbl::dict::set "$command_id__ref" '_entrypoint' "$2"

	declare -ag "${command_id__ref}__examples"

	hbl::array::append '__hbl_commands' "$command_id__ref"

	return 0
}

function hbl::command::init() {
	declare -Ag __hbl_params
	__hbl_params=()
	__hbl_params[verbose]=0
	__hbl_params[showhelp]=0

	declare -ag __hbl_commands
}

function hbl::command::add_example() {
	[[ $# -eq 2 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]] || hbl::error::argument "command_id" "$1" || exit
	[[ -n "$2" ]] || hbl::error::argument "example" "$2" || exit

	hbl::command::ensure_command "$1" || exit

	hbl::array::append "${1}__examples" "$2" || return

	return $HBL_SUCCESS
}

function hbl::command::add_option() {
	[[ $# -eq 3 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]] || hbl::error::argument "command_id" "$1" || exit
	[[ -n "$2" ]] || hbl::error::argument "option_name" "$2" || exit
	[[ -n "$3" ]] || hbl::error::argument "option_id_var" "$3" || exit

	hbl::command::ensure_command "$1" || return

	local -n option_id__ref="$3"
	option_id__ref=""

	hbl::command::option::create "$1" "$2" "${!option_id__ref}" || return

	hbl::util::is_dict "${1}__options" || declare -Ag "${1}__options"

	hbl::dict::set "${1}__options" "$2" "$option_id__ref" || return

	return 0
}

function hbl::command::add_subcommand() {
	[[ $# -eq 4 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]] || hbl::error::argument "parent_id" "$1" || exit
	[[ -n "$2" ]] || hbl::error::argument "subcommand_name" "$2" || exit
	[[ -n "$3" ]] || hbl::error::argument "subcommand_entrypoint" "$3" || exit
	[[ -n "$4" ]] || hbl::error::argument "subcommand_id_var" "$3" || exit

	hbl::command::ensure_command "$1" || exit

	local -n subcommand_id__ref="$4"
	subcommand_id__ref=""

	hbl::command::create "$2" "$3" "${!subcommand_id__ref}" || return
	hbl::dict::set "$subcommand_id__ref" '_parent' "$1" || return
	hbl::util::is_array "${1}__subcommands" || declare -ag "${1}__subcommands"
	hbl::array::append "${1}__subcommands" "$subcommand_id__ref" || return

	return 0
}

function hbl::command::set_description() {
	[[ $# -eq 2 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]]  || hbl::error::argument "command_id" "$1" || exit

	hbl::command::ensure_command "$1" || return

	hbl::dict::set "$1" '_description' "$2" || return

	return 0
}

function hbl::command::ensure_command() {
	[[ $# -eq 1 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]] || hbl::error::argument 'command_id' "$@" || exit

	hbl::util::is_defined "$1" \
		|| hbl::error::_undefined 2 "$1" || return
	hbl::util::is_dict "$1" \
		|| hbl::error::_invalid_command 2 "$1" || return
	return 0
}
