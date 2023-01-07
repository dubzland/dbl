setup() {
	load '../test_helper/common'
	load '../test_helper/command'
	common_setup
	hbl::init
	hbl::command::init

	HBL_COMMANDS+=("HBL_COMMAND_0")
	declare -Ag HBL_COMMAND_0
	HBL_COMMAND_0[name]="test-command"
	hbl_test::stub_command_create
}

@test ".add_subcommand() when insufficient arguments are passed returns INVALID_ARGS" {
	run hbl::command::add_subcommand
	assert_failure $HBL_INVALID_ARGS
}

@test ".add_subcommand() when too many arguments are passed returns INVALID_ARGS" {
	run hbl::command::add_subcommand HBL_COMMAND_0 "subcommand" subcommand_run command_id extra
	assert_failure $HBL_INVALID_ARGS
}

@test ".add_subcommand() creates the command" {
	hbl::command::add_subcommand HBL_COMMAND_0 "subcommand" subcommand_run command_id
	assert_equal "$command_create_invoked" 1
	assert_equal ${command_create_args[0]} "subcommand"
	assert_equal ${command_create_args[1]} "subcommand_run"
	assert_equal ${command_create_args[2]} "command_id"
}

@test ".add_subcommand() sets the parent" {
	hbl::command::add_subcommand HBL_COMMAND_0 "subcommand" subcommand_run command_id
	assert_equal "${STUB_COMMAND_ID[parent]}" "HBL_COMMAND_0"
}

@test ".add_subcommand() sets the full_name" {
	hbl::command::add_subcommand HBL_COMMAND_0 "subcommand" subcommand_run command_id
	assert_equal "${STUB_COMMAND_ID[full_name]}" "test-command subcommand"
}

@test ".add_subcommand() assigns the command to the parent's subcommands" {
	declare -ag HBL_COMMAND_0_SUBCOMMANDS
	hbl::command::add_subcommand HBL_COMMAND_0 "subcommand" subcommand_run command_id
	run hbl::array::contains "HBL_COMMAND_0_SUBCOMMANDS" "STUB_COMMAND_ID"
	assert_success
}
