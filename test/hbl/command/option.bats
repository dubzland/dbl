setup() {
	load '../../test_helper/common'
	common_setup
	declare -A TEST_COMMAND
	TEST_COMMAND=()
}

@test ".create() when insufficient arguments are passed returns INVALID_ARGS" {
	run hbl::command::option::create "TEST_COMMAND"
	assert_failure $HBL_INVALID_ARGS
	assert_output -p "Invalid arguments to hbl::command::option::create --"
}

@test ".create() when too many arguments are passed returns INVALID_ARGS" {
	run hbl::command::option::create "TEST_COMMAND" "test_option" option_id extra
	assert_failure $HBL_INVALID_ARGS
	assert_output -p "Invalid arguments to hbl::command::option::create --"
}

@test ".create() creates the option" {
	hbl::command::option::create "TEST_COMMAND" "test_option" option_id
	run hbl::util::is_dict "TEST_COMMAND_OPTION_0"
	assert_success
}

@test ".create() assigns the option name" {
	hbl::command::option::create "TEST_COMMAND" "test_option" option_id
	run hbl::dict::has_key "TEST_COMMAND_OPTION_0" "name"
	assert_success
	hbl::dict::get "TEST_COMMAND_OPTION_0" "name" option_name
	assert_equal "${option_name}" "test_option"
}

@test ".create() returns the option id" {
	hbl::command::option::create "TEST_COMMAND" "test_option" option_id
	assert_equal "${option_id}" "TEST_COMMAND_OPTION_0"
}
