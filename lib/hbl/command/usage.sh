#!/usr/bin/env bash

function hbl::command::usage::show() {
	[[ $# -eq 1 ]] || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	local test_command
	test_command="$1"

	hbl::command::usage::examples "$test_command"
	hbl::command::usage::description "$test_command"

	return 0
}

function hbl::command::usage::description() {
	[[ $# -eq 1 ]] || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	local command_id
	command_id="$1"

	local -n command__ref="$command_id"
	local desc="${command__ref[desc]}"
	if [[ -n "${desc}" ]]; then
		# printf "%s" "Description\n  ${desc}\n\r\n"
		printf "Description\n"
		printf "  ${desc}\n"
		printf "\r\n"
	fi

	return 0
}

function hbl::command::usage::examples() {
	[[ $# -eq 1 ]] || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	local command_id command_examples
	command_id="$1"
	local -n command__ref="${command_id}"

	# hbl::util::is_dict "$command_id" || printf "Not a command: ${command_id}\n" || return 1

	command_examples="${command_id}_EXAMPLES"

	printf "Usage:\n"

	if hbl::util::is_array "$command_examples"; then
		local -n command_examples__ref="$command_examples"
		if [[ ${#command_examples__ref[@]} -gt 0 ]]; then
			for ex in "${command_examples__ref[@]}"; do
				if [[ -n "${command__ref[fullname]}" ]]; then
					printf "  %s %s\n" "${command__ref[fullname]}" "$ex"
				else
					printf "  %s %s\n" "${command__ref[name]}" "$ex"
				fi
			done
		else
			if [[ -n "${command__ref[fullname]}" ]]; then
				printf "  %s <options>\n" "${command__ref[fullname]}" "$ex"
			else
				printf "  %s <options>\n" "${command__ref[name]}" "$ex"
			fi
		fi
		printf "\r\n"
	fi

	return 0
}
