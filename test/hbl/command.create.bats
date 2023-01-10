setup() {
	load '../test_helper/common'
	load '../test_helper/command'
	common_setup
	hbl::init
	hbl::command::init
}

#
# hbl::command::create()
#
@test 'hbl::command::create() validates its arguments' {
	# insufficient arguments
	run hbl::command::create
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::command::create 'test-command' 'test_command_run' 'command_id' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty command name
	run hbl::command::create '' 'test_command_run' 'command_id'
	assert_failure $HBL_ERR_ARGUMENT

	# empty entrypoint
	run hbl::command::create 'test-command' '' 'command_id'
	assert_failure $HBL_ERR_ARGUMENT

	# empty subcommand id var
	run hbl::command::create 'test-command' 'test_command_run' ''
	assert_failure $HBL_ERR_ARGUMENT
}

@test 'hbl::command::create() succeeds' {
	run hbl::command::create 'test-command' 'test_command_run' 'command_id'
	assert_success
}

@test 'hbl::command::create() creates the global command dict' {
	hbl::command::create 'test-command' 'test_command_run' 'command_id'
	assert_dict '__hbl_command_0'
}

@test 'hbl::command::create() returns the id to caller' {
	hbl::command::create 'test-command' 'test_command_run' 'command_id'
	assert_equal "${command_id}" '__hbl_command_0'
}

@test 'hbl::command::create() sets the proper id' {
	hbl::command::create 'test-command' 'test_command_run' 'command_id'
	assert_equal "${__hbl_command_0[_id]}" '__hbl_command_0'
}

@test 'hbl::command::create() sets an empty parent' {
	hbl::command::create 'test-command' 'test_command_run' 'command_id'
	assert_equal "${__hbl_command_0[_parent]}" ''
}

@test 'hbl::command::create() sets the name' {
	hbl::command::create 'test-command' 'test_command_run' 'command_id'
	assert_equal "${__hbl_command_0[_name]}" 'test-command'
}

@test 'hbl::command::create() sets the entrypoint' {
	hbl::command::create 'test-command' 'test_command_run' 'command_id'
	assert_equal "${__hbl_command_0[_entrypoint]}" 'test_command_run'
}

@test 'hbl::command::create() assigns to the global __hbl_commands array' {
	hbl::command::create 'test-command' 'test_command_run' 'command_id'
	assert_array_contains __hbl_commands '__hbl_command_0'
}

@test 'hbl::command::create() with an existing command sets the proper id' {
	hbl_test::mock_command '__test_command'
	__hbl_commands+=('__test_command')
	hbl::command::create 'test-command' 'test_command_run' 'command_id'
	assert_equal "$command_id" '__hbl_command_1'
}
