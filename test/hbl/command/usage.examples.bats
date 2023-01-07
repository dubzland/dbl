setup() {
	load '../../test_helper/common'
	common_setup

	declare -Ag TEST_COMMAND

	declare -ag TEST_COMMAND_EXAMPLES
	TEST_COMMAND_EXAMPLES=()
}

@test ".examples() when insufficient arguments are passed returns INVALID_ARGS" {
	TEST_COMMAND[name]="test-command"
	run hbl::command::usage::examples
	assert_failure $HBL_INVALID_ARGS
}

@test ".examples() when the command does not exist returns INVALID_ARGS" {
	run hbl::command::usage::examples BAD_COMMAND
	assert_failure $HBL_INVALID_ARGS
}

@test ".examples() when the command doesn't have any displays a default" {
	TEST_COMMAND['name']="test-command"
	TEST_COMMAND_EXAMPLES=()
	run hbl::command::usage::examples TEST_COMMAND
	assert_success
	assert_output - <<-EOF
		Usage:
		  test-command <options>

	EOF
}

@test ".examples() when the command has some displays them with a header" {
	TEST_COMMAND[name]="test-command"
	TEST_COMMAND_EXAMPLES=("-a <options>")
	run hbl::command::usage::examples TEST_COMMAND
	assert_success
	assert_output - <<-EOF
		Usage:
		  test-command -a <options>

	EOF
}
