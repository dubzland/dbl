setup() {
	load '../../test_helper/common'
	common_setup

	declare -Ag TEST_COMMAND
}

#
# hbl::command::usage::description()
#
@test ".description() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::command::usage::description
	assert_failure $HBL_ERR_INVOCATION
}

@test ".description() with too many arguments exits with ERR_INVOCATION" {
	run hbl::command::usage::description "TEST_COMMAND" "extra"
	assert_failure $HBL_ERR_INVOCATION
}

@test ".description() with an empty command id exits with ERR_ARGUMENT" {
	run hbl::command::usage::description ""
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".description() with an undefined command exits with ERR_UNDEFINED" {
	run hbl::command::usage::description "INVALID_COMMAND"
	assert_failure $HBL_ERR_UNDEFINED
}

@test ".description() with a non-command argument exits with ERR_INVALID_COMMAND" {
	declare -a INVALID_COMMAND
	run hbl::command::usage::description "INVALID_COMMAND"
	assert_failure $HBL_ERR_INVALID_COMMAND
}

@test ".description() when the command doesn't have one displays nothing" {
	TEST_COMMAND[desc]=""
	run hbl::command::usage::description TEST_COMMAND
	assert_success
	assert_output ""
}

@test ".description() when the command has one displays it with a header" {
	TEST_COMMAND[desc]="Test Description"
	run hbl::command::usage::description TEST_COMMAND
	assert_success
	assert_output - <<-EOF
	Description
	  Test Description

	EOF
}
