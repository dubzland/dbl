#!/usr/bin/env bash

function hbl::command::create() {
	[[ $# -eq 3 ]] || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	local name entrypoint command_index
	name="$1" entrypoint="$2"

	local -n command_id__ref="$3"

	command_index="${#HBL_COMMANDS[@]}"
	command_id__ref="HBL_COMMAND_${command_index}"
	declare -Ag "${command_id__ref}"

	local -n command__ref="${command_id__ref}"
	command__ref[id]="${command_id__ref}"
	command__ref[parent]=""
	command__ref[name]="${name}"
	command__ref[entrypoint]="${entrypoint}"

	HBL_COMMANDS+=("${command_id__ref}")
}

function hbl::command::init() {
	declare -Ag HBL_COMMAND
	HBL_COMMAND=()
	HBL_COMMAND[name]=""

	declare -Ag HBL_PARAMS
	HBL_PARAMS=()
	HBL_PARAMS[verbose]=0
	HBL_PARAMS[showhelp]=0

	declare -ag HBL_COMMANDS
}

function hbl::command::add_example() {
	[[ $# -eq 2 ]] || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	local command_id example command_examples
	command_id="$1" example="$2"

	command_examples="${command_id}_EXAMPLES"
	hbl::util::is_array "$command_examples" || declare -ag "${command_examples}"

	local -n command_examples__ref="$command_examples"
	command_examples__ref+=("$example")

	return 0
}

function hbl::command::add_option() {
	[[ $# -eq 3 ]] || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	local command_id option_name
	command_id="$1" option_name="$2"
	local -n option_id__ref="$3"

	if hbl::command::option::create "$command_id" "${option_name}" "${!option_id__ref}"; then
		local command_options="${command_id}_OPTIONS"
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
	[[ $# -eq 4 ]] || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	local parent_id name entrypoint parent_subcommands
	parent_id="$1" name="$2" entrypoint="$3"
	local -n command_id__ref="$4"

	if hbl::command::create "$name" "$entrypoint" "${!command_id__ref}"; then
		local -n command__ref="$command_id__ref"
		local -n parent__ref="$parent_id"
		command__ref[parent]="$parent_id"
		command__ref[full_name]="${parent__ref[name]} $name"
		parent_subcommands="${parent_id}_SUBCOMMANDS"
		if ! hbl::util::is_array "$parent_subcommands"; then
			declare -ag "$parent_subcommands"
		fi
		local -n parent_subcommands__ref="$parent_subcommands"
		parent_subcommands__ref+=("$command_id")
		return 0
	fi

	return 0
}
