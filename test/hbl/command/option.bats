setup() {
	load '../../test_helper/common'
	load '../../test_helper/command'
	common_setup
	hbl::init
	hbl::command::init

	declare -Ag TEST_OPTION
	TEST_OPTION=()

	function ensure_option() {
		hbl::command::option::ensure_option "$@"
	}
}

#
# hbl::command::option::set_type()
#
@test 'hbl::command::option::set_type() validates its arguments' {
	# insufficient arguments
	run hbl::command::option::set_type
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::command::option::set_type 'TEST_OPTION' 'number' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty option id
	run hbl::command::option::set_type '' 'number'
	assert_failure $HBL_ERR_ARGUMENT

	# empty type
	run hbl::command::option::set_type 'TEST_OPTION' ''
	assert_failure $HBL_ERR_ARGUMENT

	# invalid type
	run hbl::command::option::set_type 'TEST_OPTION' 'invalid'
	assert_failure $HBL_ERR_ARGUMENT

	# invalid option
	function hbl::command::option::ensure_option() { return 1; }
	run hbl::command::option::set_type 'TEST_OPTION' 'number'
	assert_failure $HBL_INVALID_ARGS
	unset hbl::command::option::ensure_option
}

@test 'hbl::command::option::set_type() succeeds' {
	run hbl::command::option::set_type 'TEST_OPTION' 'number'
	assert_success
}

@test 'hbl::command::option::set_type() assigns the type to the option' {
	hbl::command::option::set_type 'TEST_OPTION' 'number'
	assert_equal "${TEST_OPTION[type]}" 'number'
}

#
# hbl::command::option::ensure_option()
#
@test 'hbl::command::option::ensure_option() validates its arguments' {
	# insufficient arguments
	run ensure_option
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run ensure_option 'OPTION_ID' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty option id
	run ensure_option ''
	assert_failure $HBL_ERR_ARGUMENT
}

@test "hbl::command::option::ensure_option() with an undefined option exits with ERR_UNDEFINED" {
	run ensure_option 'OPTION_ID'
	assert_failure $HBL_ERR_UNDEFINED
}

@test "hbl::command::option::ensure_option() with a non-dict variable returns ERR_INVALID_OPTION" {
	declare -a OPTION_ID
	run ensure_option 'OPTION_ID'
	assert_failure $HBL_ERR_INVALID_OPTION
}

@test "hbl::command::option::ensure_option() with a valid option succeeds" {
	declare -A OPTION_ID
	run ensure_option 'OPTION_ID'
	assert_success
	refute_output
}
