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
	assert_equal "${__test_command__option_0[_id]}" '__test_command__option_0'
}

@test 'hbl::command::option::create() assigns the option name' {
	hbl_test::mock_command '__test_command'
	hbl::command::option::create '__test_command' 'test_option' 'option_id'
	assert_equal "${__test_command__option_0[_name]}" 'test_option'
}

@test 'hbl::command::option::create() assigns the command id' {
	hbl_test::mock_command '__test_command'
	hbl::command::option::create '__test_command' 'test_option' 'option_id'
	assert_equal "${__test_command__option_0[_command_id]}" '__test_command'
}

@test 'hbl::command::option::create() wraps set_type()' {
	local option_id
	hbl_test::mock_command '__test_command'
	hbl::command::option::create '__test_command' 'test_option' 'option_id'
	local -n option=$option_id
	run ${option[set_type]}
	assert_output "set_type: [$option_id]"
}

@test 'hbl::command::option::create() wraps set_short_flag()' {
	local option_id
	hbl_test::mock_command '__test_command'
	hbl::command::option::create '__test_command' 'test_option' 'option_id'
	local -n option=$option_id
	run ${option[set_short_flag]}
	assert_output "set_short_flag: [$option_id]"
}

@test 'hbl::command::option::create() wraps set_long_flag()' {
	local option_id
	hbl_test::mock_command '__test_command'
	hbl::command::option::create '__test_command' 'test_option' 'option_id'
	local -n option=$option_id
	run ${option[set_long_flag]}
	assert_output "set_long_flag: [$option_id]"
}

@test 'hbl::command::option::create() wraps set_description()' {
	local option_id
	hbl_test::mock_command '__test_command'
	hbl::command::option::create '__test_command' 'test_option' 'option_id'
	local -n option=$option_id
	run ${option[set_description]}
	assert_output "set_description: [$option_id]"
}

@test 'hbl::command::option::create() assigns the option id to the result var' {
	declare -A __test_command
	hbl::command::option::create '__test_command' 'test_option' 'option_id'
	assert_equal "${option_id}" '__test_command__option_0'
}
