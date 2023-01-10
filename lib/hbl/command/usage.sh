#!/usr/bin/env bash

HBL_INDENT=${HBL_INDENT:-"  "}
readonly HBL_INDENT

function hbl::command::usage::show() {
	[[ $# -eq 1 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]] || hbl::error::argument 'command_id' "$1" || exit

	hbl::command::ensure_command "$1" || exit

	local command_id="$1"
	command_id="$1"

	hbl::command::usage::examples "$command_id"
	hbl::command::usage::description "$command_id"
	hbl::command::usage::subcommands "$command_id"

	return 0
}

function hbl::command::usage::examples() {
	[[ $# -eq 1 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]]  || hbl::error::argument "command_id" "$1" || exit

	hbl::command::ensure_command "$1" || exit

	local command_id command_examples command_name
	command_id="$1" command_name=""

	hbl::dict::get "$command_id" '_fullname' command_name
	[[ -z "$command_name" ]] && hbl::dict::get "$command_id" '_name' command_name

	command_examples="${command_id}__examples"

	printf "Usage:\n"

	if hbl::util::is_array "${1}__examples"; then
		local -n command_examples__ref="${1}__examples"
		if [[ ${#command_examples__ref[@]} -gt 0 ]]; then
			for ex in "${command_examples__ref[@]}"; do
				local example
				printf -v example "%s %s" "$command_name" "$ex"
				command_examples+=("$example")
			done
		fi
	fi

	if [[ ${#command_examples[@]} -gt 0 ]]; then
		for ex in "${command_examples[@]}"; do
			printf "%s%s\n" "$HBL_INDENT" "$ex"
		done
	else
		printf "%s%s <options>\n" "$HBL_INDENT" "$command_name"
	fi

	return 0
}

function hbl::command::usage::description() {
	[[ $# -eq 1 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]]  || hbl::error::argument "command_id" "$1" || exit

	hbl::command::ensure_command "$1" || exit

	local desc

	hbl::dict::get "$1" '_description' 'desc'

	if [[ -n "${desc}" ]]; then
		printf "Description:\n"
		printf "%s%s\n" "${HBL_INDENT}" "${desc}"
		printf "\n"
	fi

	return 0
}

function hbl::command::usage::subcommands() {
	[[ $# -eq 1 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]]  || hbl::error::argument "command_id" "$1" || exit

	hbl::command::ensure_command "$1" || exit

	local command_id command_subcommands subcommand_id subcommand_name
	local subcommand_desc
	local -A subcommand_dict
	local -a subcommand_names
	command_id="$1" subcommand_dict=() subcommand_names=()

	command_subcommands="${command_id}__subcommands"

	if hbl::util::is_array "$command_subcommands"; then
		local -n command_subcommands__ref="$command_subcommands"

		if [[ ${#command_subcommands__ref[@]} -gt 0 ]]; then
			printf "Subcommands:\n"
			for subcommand_id in "${command_subcommands__ref[@]}"; do
				if hbl::util::is_dict "$subcommand_id"; then
					hbl::dict::get "$subcommand_id" 'name' subcommand_name
					hbl::dict::set subcommand_dict "$subcommand_name" "$subcommand_id"
				else
					hbl::error::undefined "${FUNCNAME[0]}" "$subcommand_id"
					return
				fi
			done

			subcommand_names=("${!subcommand_dict[@]}")
			hbl::array::bubble_sort subcommand_names
			for sub in "${subcommand_names[@]}"; do
				hbl::dict::get subcommand_dict "$sub" subcommand_id
				hbl::dict::get "$subcommand_id" 'desc' subcommand_desc
				printf "%s%-26s%s\n" "${HBL_INDENT}" "$sub" "$subcommand_desc"
			done
			printf "\n"
		fi
	fi

	return 0
}
