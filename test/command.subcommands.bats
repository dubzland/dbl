setup() {
	load 'test_helper/common'
	load 'test_helper/command'
	common_setup
	declare -Ag HBL_COMMANDS
	HBL_COMMANDS=([test]="HBL_TEST")
	declare -Ag HBL_TEST
	HBL_TEST=([module]="HBL_TEST")
}

@test "init() defines the SUBCOMMANDS module" {
	hbl::command::subcommands::init 'test'
	run is_defined "HBL_TEST_SUBCOMMANDS"
	assert_success
}

@test "add() appends the subcommand to the parent" {
	hbl::command::subcommands::init 'test'
	hbl::command::subcommands::add 'test' 'test::child'
	[[ " ${!HBL_TEST_SUBCOMMANDS[*]} " =~ " test::child " ]]
}
