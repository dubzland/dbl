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

#
# hbl::command::usage::subcommands()
#
@test ".subcommands() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::command::usage::subcommands
	assert_failure $HBL_ERR_INVOCATION
}

@test ".subcommands() with too many arguments exits with ERR_INVOCATION" {
	run hbl::command::usage::subcommands "TEST_COMMAND" "extra"
	assert_failure $HBL_ERR_INVOCATION
}

@test ".subcommands() with an empty command id exits with ERR_ARGUMENT" {
	run hbl::command::usage::subcommands ""
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".subcommands() with an undefined command exits with ERR_UNDEFINED" {
	run hbl::command::usage::subcommands "INVALID_COMMAND"
	assert_failure $HBL_ERR_UNDEFINED
}

@test ".subcommands() with a non-command argument exits with ERR_INVALID_COMMAND" {
	declare -a INVALID_COMMAND
	run hbl::command::usage::subcommands "INVALID_COMMAND"
	assert_failure $HBL_ERR_INVALID_COMMAND
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
	assert_output - <<-EOF
		Subcommands:
		  execute                   Another test subcommand.
		  run                       A test subcommand.

	EOF
	assert_line --index 0 "Subcommands:"
}
