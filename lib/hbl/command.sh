#!/usr/bin/env bash

function hbl::command::create() {
	[[ $# -eq 3 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]]  || hbl::error::argument "command_name" "$1" || exit
	[[ -n "$2" ]]  || hbl::error::argument "command_entrypoint" "$2" || exit
	[[ -n "$3" ]]  || hbl::error::argument "command_id_var" "$3" || exit

	local command_name command_entrypoint command_id_var command_index
	command_name="$1" command_entrypoint="$2" command_id_var="$3"

	local -n command_id__ref="$command_id_var"

	command_index="${#__hbl_commands[@]}"
	command_id__ref="__hbl_command_${command_index}"
	declare -Ag "${command_id__ref}"

	local -n command__ref="${command_id__ref}"
	command__ref[id]="${command_id__ref}"
	command__ref[parent]=""
	command__ref[name]="${command_name}"
	command__ref[entrypoint]="${command_entrypoint}"

	__hbl_commands+=("${command_id__ref}")

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

	local command_id example command_examples
	command_id="$1" example="$2"

	command_examples="${command_id}__examples"
	hbl::util::is_array "$command_examples" || declare -ag "${command_examples}"

	local -n command_examples__ref="$command_examples"
	command_examples__ref+=("$example")

	return $HBL_SUCCESS
}

function hbl::command::add_option() {
	[[ $# -eq 3 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]] || hbl::error::argument "command_id" "$1" || exit
	[[ -n "$2" ]] || hbl::error::argument "option_name" "$2" || exit
	[[ -n "$3" ]] || hbl::error::argument "option_id_var" "$3" || exit

	hbl::command::ensure_command "$1" || exit

	local command_id option_name
	command_id="$1" option_name="$2"
	local -n option_id__ref="$3"
	option_id__ref=""

	if hbl::command::option::create "$command_id" "${option_name}" "${!option_id__ref}"; then
		local command_options="${command_id}__options"
		if ! hbl::util::is_dict "$command_options"; then
			declare -Ag "$command_options"
		fi
		hbl::dict::set "$command_options" "$option_name" "$option_id__ref"
	else
		return 1
	fi

	return 0
}

function hbl::command::add_subcommand() {
	[[ $# -eq 4 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]] || hbl::error::argument "parent_id" "$1" || exit
	[[ -n "$2" ]] || hbl::error::argument "subcommand_name" "$2" || exit
	[[ -n "$3" ]] || hbl::error::argument "subcommand_entrypoint" "$3" || exit
	[[ -n "$4" ]] || hbl::error::argument "subcommand_id_var" "$3" || exit

	local parent_id name entrypoint parent_subcommands
	parent_id="$1" name="$2" entrypoint="$3"
	local -n command_id__ref="$4"

	hbl::command::ensure_command "$1" || exit

	if hbl::command::create "$name" "$entrypoint" "${!command_id__ref}"; then
		local -n command__ref="$command_id__ref"
		local -n parent__ref="$parent_id"
		command__ref[parent]="$parent_id"
		command__ref[full_name]="${parent__ref[name]} $name"
		parent_subcommands="${parent_id}__subcommands"
		if ! hbl::util::is_array "$parent_subcommands"; then
			declare -ag "$parent_subcommands"
		fi
		local -n parent_subcommands__ref="$parent_subcommands"
		parent_subcommands__ref+=("$command_id")
	fi

	return 0
}

function hbl::command::set_description() {
	[[ $# -eq 2 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]]  || hbl::error::argument "command_id" "$1" || exit
	[[ -n "$2" ]]  || hbl::error::argument "description" "$1" || exit

	hbl::command::ensure_command "$1" || exit

	local command_id description
	command_id="$1" description="$2"

	local -n command__ref="$command_id"
	command__ref[desc]="$description"

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
