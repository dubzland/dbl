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
@test ".set_type() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::command::option::set_type
	assert_failure $HBL_ERR_INVOCATION
}

@test ".set_type() with too many arguments exits with ERR_INVOCATION" {
	run hbl::command::option::set_type "TEST_OPTION" "int" "extra"
	assert_failure $HBL_ERR_INVOCATION
}

@test ".set_type() with an empty option id exits with ERR_ARGUMENT" {
	run hbl::command::option::set_type "" "int"
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".set_type() with an empty type exits with ERR_ARGUMENT" {
	run hbl::command::option::set_type "TEST_OPTION" ""
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".set_type() with an invalid type exits with ERR_ARGUMENT" {
	run hbl::command::option::set_type "TEST_OPTION" "invalid"
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".set_type() with a non-existent option exits with INVALID_ARGS" {
	run hbl::command::option::set_type "INVALID_OPTION" "int"
	assert_failure $HBL_INVALID_ARGS
}

@test ".set_type() assigns the type to the option" {
	hbl::command::option::set_type "TEST_OPTION" "number"
	assert_equal "${TEST_OPTION[type]}" "number"
}

#
# hbl::command::option::ensure_option()
#
@test ".ensure_option() with no arguments exits with ERR_INVOCATION" {
	run ensure_option
	assert_failure $HBL_ERR_INVOCATION
	assert_output "hbl::command::option::ensure_option: invalid arguments -- ''"
}

@test ".ensure_option() with too many arguments exits with ERR_INVOCATION" {
	run ensure_option "OPTION_ID" "extra"
	assert_failure $HBL_ERR_INVOCATION
	assert_output "hbl::command::option::ensure_option: invalid arguments -- 'OPTION_ID extra'"
}

@test ".ensure_option() with an empty option id exits with ERR_ARGUMENT" {
	run ensure_option ""
	assert_failure $HBL_ERR_ARGUMENT
	assert_output "hbl::command::option::ensure_option: invalid argument for 'option_id' -- ''"
}

@test ".ensure_option() with an undefined option exits with ERR_UNDEFINED" {
	run ensure_option "OPTION_ID"
	assert_failure $HBL_ERR_UNDEFINED
	assert_output "ensure_option: variable is undefined -- 'OPTION_ID'"
}

@test ".ensure_option() with a non-dict variable returns ERR_INVALID_OPTION" {
	declare -a option_id
	run ensure_option "option_id"
	assert_failure $HBL_ERR_INVALID_OPTION
	assert_output "ensure_option: invalid option id -- 'option_id'"
}

@test ".ensure_option() with a valid option succeeds" {
	declare -A option_id
	run ensure_option "option_id"
	assert_success
	refute_output
}
