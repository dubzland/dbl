setup() {
	load '../../test_helper/common'
	common_setup
	declare -Ag TEST_COMMAND
	TEST_COMMAND=()
}

#
# hbl::command::option::create()
#
@test ".create() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::command::option::create
	assert_failure $HBL_ERR_INVOCATION
	assert_output \
		"hbl::command::option::create: invalid arguments -- ''"
}

@test ".create() with too many arguments exits with ERR_INVOCATION" {
	run hbl::command::option::create "TEST_COMMAND" "test_option" \
		"option_id_var" "extra"
	assert_failure $HBL_ERR_INVOCATION
	assert_output \
		"hbl::command::option::create: invalid arguments -- 'TEST_COMMAND test_option option_id_var extra'"
}

@test ".create() with an empty command id exits with ERR_ARGUMENT" {
	run hbl::command::option::create "" "test_option" "option_id_var"
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".create() with an empty option name exits with ERR_ARGUMENT" {
	run hbl::command::option::create "TEST_COMMAND" "" "option_id_var"
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".create() with an empty option id var exits with ERR_ARGUMENT" {
	run hbl::command::option::create "TEST_COMMAND" "test_option" ""
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".create() with an undefined command exits with ERR_UNDEFINED" {
	run hbl::command::option::create "UNDEFINED_COMMAND" "test_option" "option_id"
	assert_failure $HBL_ERR_UNDEFINED
}

@test ".create() with a non-command argument exits with ERR_INVALID_COMMAND" {
	declare -a INVALID_COMMAND
	run hbl::command::option::create "INVALID_COMMAND" "test_option" "option_id"
	assert_failure $HBL_ERR_INVALID_COMMAND
}

@test ".create() creates the option" {
	hbl::command::option::create "TEST_COMMAND" "test_option" option_id
	run hbl::util::is_dict "TEST_COMMAND_OPTION_0"
	assert_success
}

@test ".create() assigns the option name" {
	hbl::command::option::create "TEST_COMMAND" "test_option" option_id
	run hbl::dict::has_key "TEST_COMMAND_OPTION_0" "name"
	assert_success
	hbl::dict::get "TEST_COMMAND_OPTION_0" "name" option_name
	assert_equal "${option_name}" "test_option"
}

@test ".create() returns the option id" {
	hbl::command::option::create "TEST_COMMAND" "test_option" option_id
	assert_equal "${option_id}" "TEST_COMMAND_OPTION_0"
}
