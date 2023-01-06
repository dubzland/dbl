setup() {
	load 'test_helper/common'
	load 'test_helper/command'
	common_setup
	hbl::init
	hbl_test::stub_command_create

	HBL_COMMANDS+=("HBL_COMMAND_0")
	declare -Ag HBL_COMMAND_0
	declare -Ag HBL_COMMAND_0_SUBCOMMANDS
	HBL_COMMAND_0[name]="test-command"
}

@test ".add_subcommand() assigns the command to the parent's subcommands" {
	hbl::command::add_subcommand HBL_COMMAND_0 "subcommand" subcommand_run command_id
	run hbl::dict::has_key? "HBL_COMMAND_0_SUBCOMMANDS" "subcommand"
	assert_success
}

