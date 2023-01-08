setup() {
	load '../../test_helper/common'
	load '../../test_helper/command'
	common_setup
}

#
# hbl::command::option::create()
#
@test 'hbl::command::option::create() validates its arguments' {
	# insufficient arguments
	run hbl::command::option::create
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::command::option::create '__test__command' 'test_option' \
		'option_id_var' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty command id
	run hbl::command::option::create '' 'test_option' 'option_id_var'
	assert_failure $HBL_ERR_ARGUMENT

	# empty option name
	run hbl::command::option::create '__test_command' '' 'option_id_var'
	assert_failure $HBL_ERR_ARGUMENT

	# empty option id var
	run hbl::command::option::create '__test_command' 'test_option' ''
	assert_failure $HBL_ERR_ARGUMENT

	# invalid command
	function hbl::command::ensure_command() { return 1; }
	run hbl::command::option::create '__test_command' 'test_option' 'option_id'
	assert_failure
	unset hbl::command::ensure_command
}

@test 'hbl::command::option::create() succeeds' {
	hbl_test::mock_command '__test_command'
	run hbl::command::option::create '__test_command' 'test_option' 'option_id'
	assert_success
}

@test 'hbl::command::option::create() creates the option' {
	hbl_test::mock_command '__test_command'
	hbl::command::option::create '__test_command' 'test_option' 'option_id'
	assert_dict '__test_command__option_0'
}

@test 'hbl::command::option::create() assigns the option id' {
	hbl_test::mock_command '__test_command'
	hbl::command::option::create '__test_command' 'test_option' 'option_id'
	assert_equal "${__test_command__option_0[id]}" '__test_command__option_0'
}

@test 'hbl::command::option::create() assigns the option name' {
	hbl_test::mock_command '__test_command'
	hbl::command::option::create '__test_command' 'test_option' 'option_id'
	assert_equal "${__test_command__option_0[name]}" 'test_option'
}

@test 'hbl::command::option::create() assigns the command id' {
	hbl_test::mock_command '__test_command'
	hbl::command::option::create '__test_command' 'test_option' 'option_id'
	assert_equal "${__test_command__option_0[command_id]}" '__test_command'
}

@test 'hbl::command::option::create() assigns the option id to the result var' {
	declare -A __test_command
	hbl::command::option::create '__test_command' 'test_option' 'option_id'
	assert_equal "${option_id}" '__test_command__option_0'
}
