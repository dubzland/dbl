#!/usr/bin/env bash

HBL_INDENT="  "
readonly HBL_INDENT

function hbl::command::usage::show() {
	[[ $# -eq 1 ]] || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	local command_id="$1"
	command_id="$1"

	hbl::command::usage::examples "$command_id"
	hbl::command::usage::description "$command_id"
	hbl::command::usage::subcommands "$command_id"

	return 0
}

function hbl::command::usage::examples() {
	[[ $# -eq 1 ]] || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	local command_id command_examples
	command_id="$1"

	hbl::util::is_dict "$command_id" || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	local -n command__ref="${command_id}"

	command_examples="${command_id}_EXAMPLES"

	printf "Usage:\n"

	if hbl::util::is_array "$command_examples"; then
		local -n command_examples__ref="$command_examples"
		if [[ ${#command_examples__ref[@]} -gt 0 ]]; then
			for ex in "${command_examples__ref[@]}"; do
				if [[ -n "${command__ref[fullname]}" ]]; then
					printf "%s%s %s\n" "${HBL_INDENT}" "${command__ref[fullname]}" "$ex"
				else
					printf "%s%s %s\n" "${HBL_INDENT}" "${command__ref[name]}" "$ex"
				fi
			done
		else
			if [[ -n "${command__ref[fullname]}" ]]; then
				printf "%s%s <options>\n" "${HBL_INDENT}" "${command__ref[fullname]}" "$ex"
			else
				printf "%s%s <options>\n" "${HBL_INDENT}" "${command__ref[name]}" "$ex"
			fi
		fi
		printf "\r\n"
	fi

	return 0
}

function hbl::command::usage::description() {
	[[ $# -eq 1 ]] || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	local command_id
	command_id="$1"

	hbl::util::is_dict "$command_id" || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	local -n command__ref="$command_id"
	local desc="${command__ref[desc]}"
	if [[ -n "${desc}" ]]; then
		printf "Description\n"
		printf "%s%s\n" "${HBL_INDENT}" "${desc}"
		printf "\r\n"
	fi

	return 0
}

function hbl::command::usage::subcommands() {
	[[ $# -eq 1 ]] || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	local command_id subcommand_id command_subcommands
	local -A subcommand_dict
	local -a subcommand_names
	command_id="$1" subcommand_dict=() subcommand_names=()

	hbl::util::is_dict "$command_id" || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	local -n command__ref="${command_id}"

	command_subcommands="${command_id}_SUBCOMMANDS"

	if hbl::util::is_array "$command_subcommands"; then
		local -n command_subcommands__ref="$command_subcommands"

		if [[ ${#command_subcommands__ref[@]} -gt 0 ]]; then
			printf "Subcommands:\n"
			for subcommand_id in "${command_subcommands__ref[@]}"; do
				if hbl::util::is_dict "$subcommand_id"; then
					local -n subcommand__ref="$subcommand_id"
					subcommand_dict["${subcommand__ref[name]}"]="$subcommand_id"
				else
					hbl::error::undefined "${FUNCNAME[0]}" "$subcommand_id"
					return
				fi
			done

			subcommand_names=("${!subcommand_dict[@]}")
			hbl::array::bubble_sort subcommand_names "${subcommand_names[@]}"
			for sub in "${subcommand_names[@]}"; do
				local -n subcommand__ref="${subcommand_dict[$sub]}"
				printf "%s%-26s%s\n" "${HBL_INDENT}" "$sub" "${subcommand__ref[desc]}"
			done
		fi
	fi

	return 0
}
