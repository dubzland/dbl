setup() {
	load '../../test_helper/common'
	common_setup

	declare -Ag TEST_COMMAND
	TEST_COMMAND[name]="test-command"

	declare -ag TEST_COMMAND_SUBCOMMANDS
	TEST_COMMAND_SUBCOMMANDS=()

	declare -Ag TEST_SUBCOMMAND1
	TEST_SUBCOMMAND1[name]="run"
	TEST_SUBCOMMAND1[desc]="A test subcommand."

	declare -Ag TEST_SUBCOMMAND2
	TEST_SUBCOMMAND2[name]="execute"
	TEST_SUBCOMMAND2[desc]="Another test subcommand."
}

@test ".subcommands() when insufficient arguments are passed returns INVALID_ARGS" {
	run hbl::command::usage::subcommands
	assert_failure $HBL_INVALID_ARGS
}

@test ".subcommands() when the command does not exist returns INVALID_ARGS" {
	run hbl::command::usage::subcommands BAD_COMMAND
	assert_failure $HBL_INVALID_ARGS
}

@test ".subcommands() when the command doesn't have any displays nothing" {
	TEST_COMMAND_SUBCOMMANDS=()
	run hbl::command::usage::subcommands TEST_COMMAND
	assert_success
	assert_output ""
}

@test ".subcommands() when the command has some displays them with a header" {
	TEST_COMMAND_SUBCOMMANDS=("TEST_SUBCOMMAND1" "TEST_SUBCOMMAND2")
	run hbl::command::usage::subcommands TEST_COMMAND
	assert_success
	assert_line --index 0 "Subcommands:"
	assert_line --index 1 "  execute                   Another test subcommand."
	assert_line --index 2 "  run                       A test subcommand."
}
