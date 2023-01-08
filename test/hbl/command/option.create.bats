setup() {
	load '../../test_helper/common'
	common_setup
	declare -Ag TEST_COMMAND
	TEST_COMMAND=()
}

#
# hbl::command::option::create()
#
@test 'hbl::command::option::create() validates its arguments' {
	# insufficient arguments
	run hbl::command::option::create
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::command::option::create 'TEST_COMMAND' 'test_option' \
		'option_id_var' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty command id
	run hbl::command::option::create '' 'test_option' 'option_id_var'
	assert_failure $HBL_ERR_ARGUMENT

	# empty option name
	run hbl::command::option::create 'TEST_COMMAND' '' 'option_id_var'
	assert_failure $HBL_ERR_ARGUMENT

	# empty option id var
	run hbl::command::option::create 'TEST_COMMAND' 'test_option' ''
	assert_failure $HBL_ERR_ARGUMENT

	# invalid command
	function hbl::command::ensure_command() { return 1; }
	run hbl::command::option::create 'TEST_COMMAND' 'test_option' 'option_id'
	assert_failure
	unset hbl::command::ensure_command
}

@test 'hbl::command::option::create() succeeds' {
	run hbl::command::option::create 'TEST_COMMAND' 'test_option' 'option_id'
	assert_success
}

@test 'hbl::command::option::create() creates the option' {
	hbl::command::option::create 'TEST_COMMAND' 'test_option' 'option_id'
	assert_dict 'TEST_COMMAND_OPTION_0'
}

@test 'hbl::command::option::create() assigns the option name' {
	hbl::command::option::create 'TEST_COMMAND' 'test_option' 'option_id'
	assert_equal "${TEST_COMMAND_OPTION_0[name]}" 'test_option'
}

@test 'hbl::command::option::create() assigns the option id' {
	hbl::command::option::create 'TEST_COMMAND' 'test_option' 'option_id'
	assert_equal "${option_id}" 'TEST_COMMAND_OPTION_0'
}
