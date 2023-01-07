setup() {
	load 'test_helper/common'
	load 'test_helper/command'
	common_setup
	hbl::init
	hbl_test::stub_command_create
}

@test ".add_command() when insufficient arguments are passed returns INVALID_ARGS" {
	run hbl::add_command
	assert_failure $HBL_INVALID_ARGS
	assert_output -p "Invalid arguments to hbl::add_command --"
}

@test ".add_command() when too many arguments are passed returns INVALID_ARGS" {
	run hbl::add_command "command" command_run command_id extra
	assert_failure $HBL_INVALID_ARGS
	assert_output -p "Invalid arguments to hbl::add_command --"
}

@test ".add_command() creates the command" {
	hbl::add_command "command" command_run command_id
	assert_equal "$command_create_invoked" 1
	assert_equal ${command_create_args[0]} "command"
	assert_equal ${command_create_args[1]} "command_run"
	assert_equal ${command_create_args[2]} "command_id"
}
