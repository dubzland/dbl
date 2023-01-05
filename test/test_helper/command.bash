#!/usr/bin/env bash

function make_command() {
	if [ $# -gt 0 ]; then
		local -n command_id__ref="$1"
	else
		local unused
		local -n command_id__ref="unused"
	fi
	hbl::command::create "" "test-command" "Test command." "${!command_id__ref}"
}

function make_subcommand() {
	if [ $# -gt 0 ]; then
		if [ $# -gt 1 ]; then
			local -n command_id__ref="$1"
			local -n subcommand_id__ref="$2"
		else
			local unused
			local -n command_id__ref="unused"
			local -n subcommand_id__ref="$1"
		fi
	else
		local unused
		local -n command_id__ref="unused"
		local -n subcommand_id__ref="unused"
	fi
	make_command "${!command_id__ref}"
	hbl::command::create "${command_id__ref}" "test-subcommand" \
		"Test subcommand." "${!subcommand_id__ref}"
}

