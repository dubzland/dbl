setup() {
	load '../test_helper/common'
	load '../test_helper/command'
	common_setup
	hbl::init
	hbl::command::init

	declare -a option_create_args
	option_create_args=()
	option_create_invoked=0
	function hbl::command::option::create() {
		option_create_invoked=1
		option_create_args=("$@")
		local -n option_id__ref="$3"
		option_id__ref="${1}_TEST_OPTION_ID"
		return 0
	}
}

@test ".add_option() when insufficient arguments are passed returns INVALID_ARGS" {
	run hbl::command::add_option
	assert_failure $HBL_INVALID_ARGS
}

@test ".add_option() when too many arguments are passed returns INVALID_ARGS" {
	run hbl::command::add_option "TEST_COMMAND_ID" "test_option" option_id extra
	assert_failure $HBL_INVALID_ARGS
}

@test ".add_option() creates the option" {
	hbl::command::add_option "TEST_COMMAND_ID" "test_option" option_id
	assert_equal $option_create_invoked 1
}

@test ".add_option() passes the proper arguments to option::create()" {
	hbl::command::add_option "TEST_COMMAND_ID" "test_option" option_id
	assert_equal ${option_create_args[0]} "TEST_COMMAND_ID"
	assert_equal ${option_create_args[1]} "test_option"
	assert_equal ${option_create_args[2]} "option_id"
}

@test ".add_option() assigns the option to the command" {
	hbl::command::add_option "TEST_COMMAND_ID" "test_option" option_id
	hbl::dict::get "TEST_COMMAND_ID_OPTIONS" "test_option" opt
	assert_equal "${opt}" "TEST_COMMAND_ID_TEST_OPTION_ID"
}

@test ".add_option() returns the option id" {
	hbl::command::add_option "TEST_COMMAND_ID" "test_option" option_id
	assert_equal "$option_id" "TEST_COMMAND_ID_TEST_OPTION_ID"
}

