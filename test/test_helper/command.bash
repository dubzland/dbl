#!/usr/bin/env bash

function hbl_test::mock_command() {
	local command_id
	command_id="$1"
	declare -Ag "$command_id"
	local -n command__ref="$command_id"
	command__ref[_name]='test-command'
}

function hbl_test::dummy_run() {
	printf "Dummy command run.\n"
	exit 0
}

function hbl_test::generate_command() {
	hbl::command::create "$1" 'hbl_test::dummy_run' "$2"
	return 0
	# local command_id__ref
	# command_id__ref="$2"
	# declare -Ag "$command_id"
}

function hbl_test::mock_option() {
	local option_id
	option_id="$1"
	declare -Ag "$option_id"
	local -n option__ref="$option_id"
	option__ref[id]="$option_id"
	option__ref[name]='test_option'
}

function hbl_test::stub_command_create() {
	declare -a command_create_args
	command_create_args=()
	command_create_invoked=0
	function hbl::command::create() {
		command_create_invoked=1
		command_create_args=("$@")
		hbl_test::mock_command '__stubbed_command'
		local -n command_id__ref="$3"
		command_id__ref='__stubbed_command'
		return 0
	}
}
