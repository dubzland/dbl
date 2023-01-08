setup() {
	load 'test_helper/common'
	load 'test_helper/command'
	common_setup
	hbl::init
	hbl_test::stub_command_create
}

#
# hbl::add_command()
#
@test 'hbl::add_command() validates its arguments' {
	# insufficient arguments
	run hbl::add_command
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::add_command 'command' 'command_run' 'command_id' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty command name
	run hbl::add_command '' 'command_run' 'command_id'
	assert_failure $HBL_ERR_ARGUMENT

	# empty entrypoint
	run hbl::add_command 'command' '' 'command_id'
	assert_failure $HBL_ERR_ARGUMENT

	# empty command_id_var
	run hbl::add_command 'command' 'command_run' ''
	assert_failure $HBL_ERR_ARGUMENT
}

@test 'hbl::add_command() creates the command' {
	hbl::add_command 'command' 'command_run' 'command_id'
	assert_equal "$command_create_invoked" 1
	assert_equal ${command_create_args[0]} 'command'
	assert_equal ${command_create_args[1]} 'command_run'
	assert_equal ${command_create_args[2]} 'command_id'
}
