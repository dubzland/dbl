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
	assert_dict 'HBL_COMMAND_0'
}

@test 'hbl::command::create() returns the id to caller' {
	hbl::command::create 'test-command' 'test_command_run' 'command_id'
	assert_equal "${command_id}" 'HBL_COMMAND_0'
}

@test 'hbl::command::create() sets the proper id' {
	hbl::command::create 'test-command' 'test_command_run' 'command_id'
	assert_equal "${HBL_COMMAND_0[id]}" 'HBL_COMMAND_0'
}

@test 'hbl::command::create() sets an empty parent' {
	hbl::command::create 'test-command' 'test_command_run' 'command_id'
	assert_equal "${HBL_COMMAND_0[parent]}" ''
}

@test 'hbl::command::create() sets the name' {
	hbl::command::create 'test-command' 'test_command_run' 'command_id'
	assert_equal "${HBL_COMMAND_0[name]}" 'test-command'
}

@test 'hbl::command::create() sets the entrypoint' {
	hbl::command::create 'test-command' 'test_command_run' 'command_id'
	run hbl::dict::has_key 'HBL_COMMAND_0' 'entrypoint'
	assert_success
	assert_equal "${HBL_COMMAND_0[entrypoint]}" 'test_command_run'
}

@test 'hbl::command::create() assigns to the global HBL_COMMANDS array' {
	declare -a HBL_COMMANDS
	hbl::command::create 'test-command' 'test_command_run' 'command_id'
	assert_array_contains HBL_COMMANDS 'HBL_COMMAND_0'
}

@test 'hbl::command::create() with an existing command sets the proper id' {
	HBL_COMMANDS+=('HBL_COMMAND_0')
	hbl::command::create 'test-command' 'test_command_run' 'command_id'
	assert_equal "$command_id" 'HBL_COMMAND_1'
}
