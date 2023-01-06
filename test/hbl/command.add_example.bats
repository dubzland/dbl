setup() {
	load '../test_helper/common'
	load '../test_helper/command'
	common_setup
	hbl::init
	hbl::command::init
}

@test ".add_example() when insufficient arguments are passed returns INVALID_ARGS" {
	run hbl::command::add_example
	assert_failure $HBL_INVALID_ARGS
}

@test ".add_example() when too many arguments are passed returns INVALID_ARGS" {
	run hbl::command::add_example "TEST_COMMAND_ID" "example" extra
	assert_failure $HBL_INVALID_ARGS
}

@test ".add_example() assigns the example to the command" {
	hbl::command::add_example "TEST_COMMAND_ID" "example"
	hbl::array::contains "TEST_COMMAND_ID_EXAMPLES" "example"
}
