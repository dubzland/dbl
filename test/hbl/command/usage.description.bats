setup() {
	load '../../test_helper/common'
	common_setup

	declare -Ag TEST_COMMAND
}

@test ".description() when insufficient arguments are passed returns INVALID_ARGS" {
	run hbl::command::usage::description
	assert_failure $HBL_INVALID_ARGS
}

@test ".description() when the command does not exist returns INVALID_ARGS" {
	run hbl::command::usage::description BAD_COMMAND
	assert_failure $HBL_INVALID_ARGS
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
