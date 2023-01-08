setup() {
	load '../../test_helper/common'
	common_setup

	declare -Ag TEST_COMMAND

	declare -ag TEST_COMMAND_EXAMPLES
	TEST_COMMAND_EXAMPLES=()
}

#
# hbl::command::usage::examples()
#
@test ".examples() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::command::usage::examples
	assert_failure $HBL_ERR_INVOCATION
}

@test ".examples() with too many arguments exits with ERR_INVOCATION" {
	run hbl::command::usage::examples "TEST_COMMAND" "extra"
	assert_failure $HBL_ERR_INVOCATION
}

@test ".examples() with an empty command id exits with ERR_ARGUMENT" {
	run hbl::command::usage::examples ""
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".examples() with an undefined command exits with ERR_UNDEFINED" {
	run hbl::command::usage::examples "INVALID_COMMAND"
	assert_failure $HBL_ERR_UNDEFINED
}

@test ".examples() with a non-command argument exits with ERR_INVALID_COMMAND" {
	declare -a INVALID_COMMAND
	run hbl::command::usage::examples "INVALID_COMMAND"
	assert_failure $HBL_ERR_INVALID_COMMAND
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
