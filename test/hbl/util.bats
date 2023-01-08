setup() {
	load '../test_helper/common'
	common_setup
}

#
# hbl::util::is_defined()
#
@test ".is_devined() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::util::is_defined
	assert_failure $HBL_ERR_INVOCATION
}

@test ".is_defined() with too many arguments exits with ERR_INVOCATION" {
	run hbl::util::is_defined "var" "extra"
	assert_failure $HBL_ERR_INVOCATION
}

@test ".is_defined() with an empty function name exits with ERR_ARGUMENT" {
	run hbl::util::is_defined ""
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".is_defined() with an undefined variable fails" {
	run hbl::util::is_defined UNDEFINED
	assert_failure $HBL_ERROR
	refute_output
}

@test ".is_defined() with an defined variable succeeds" {
	declare DEFINED
	run hbl::util::is_defined DEFINED
	assert_success
	refute_output
}

#
# hbl::util::is_function()
#
@test ".is_function() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::util::is_function
	assert_failure $HBL_ERR_INVOCATION
}

@test ".is_function() with too many arguments exits with ERR_INVOCATION" {
	run hbl::util::is_function "func" "extra"
	assert_failure $HBL_ERR_INVOCATION
}

@test ".is_function() with an empty function name exits with ERR_ARGUMENT" {
	run hbl::util::is_function ""
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".is_function() with a non-existent function fails" {
	run hbl::util::is_function "nonexistent"
	assert_failure
}

@test ".is_function() with an existing function succeeds" {
	function existent() { return 0; }
	run hbl::util::is_function "existent"
	assert_success
}

#
# hbl::util::is_array()
#
@test ".is_array() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::util::is_array
	assert_failure $HBL_ERR_INVOCATION
}

@test ".is_array() with too many arguments exits with ERR_INVOCATION" {
	run hbl::util::is_array "array" "extra"
	assert_failure $HBL_ERR_INVOCATION
}

@test ".is_array() with an empty array name exits with ERR_ARGUMENT" {
	run hbl::util::is_array ""
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".is_array() with an undefined variable fails" {
	run hbl::util::is_array UNDEFINED
	assert_failure $HBL_ERROR
	refute_output
}

@test ".is_array() with a normal variable fails" {
	declare DEFINED
	run hbl::util::is_array DEFINED
	assert_failure $HBL_ERROR
	refute_output
}

@test ".is_array() with an associative array fails" {
	declare -A DEFINED
	run hbl::util::is_array DEFINED
	assert_failure $HBL_ERROR
	refute_output
}

@test ".is_array() with a normal array succeeds" {
	declare -a DEFINED
	run hbl::util::is_array DEFINED
	assert_success
	refute_output
}

#
# hbl::util::is_dict()
#
@test ".is_dict() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::util::is_dict
	assert_failure $HBL_ERR_INVOCATION
}

@test ".is_dict() with too many arguments exits with ERR_INVOCATION" {
	run hbl::util::is_dict "dict" "extra"
	assert_failure $HBL_ERR_INVOCATION
}

@test ".is_dict() with an empty array name exits with ERR_ARGUMENT" {
	run hbl::util::is_dict ""
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".is_dict() with an undefined variable fails" {
	run hbl::util::is_dict UNDEFINED
	assert_failure $HBL_ERROR
	refute_output
}

@test ".is_dict() with a normal variable fails" {
	declare DEFINED
	run hbl::util::is_dict DEFINED
	assert_failure $HBL_ERROR
	refute_output
}

@test ".is_dict() with a normal array fails" {
	declare -a DEFINED
	run hbl::util::is_dict DEFINED
	assert_failure $HBL_ERROR
	refute_output
}

@test ".is_dict() with an associative array succeeds" {
	declare -A DEFINED
	run hbl::util::is_dict DEFINED
	assert_success
	refute_output
}

#
# hbl::util::string_to_underscore()
#
@test ".string_to_underscore() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::util::string_to_underscore
	assert_failure $HBL_ERR_INVOCATION
}

@test ".string_to_underscore() with too many arguments exits with ERR_INVOCATION" {
	run hbl::util::string_to_underscore "string" "target_var" "extra"
	assert_failure $HBL_ERR_INVOCATION
}

@test ".string_to_underscore() with an empty target variable exits with ERR_ARGUMENT" {
	run hbl::util::string_to_underscore "string" ""
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".string_to_underscore() handles ':'" {
	local result
	hbl::util::string_to_underscore "foo:bar" "result"
	assert_equal "${result}" "foo_bar"
}

@test ".string_to_underscore() handles '-'" {
	local result
	hbl::util::string_to_underscore "foo-bar" result
	assert_equal "${result}" "foo_bar"
}

#
# hbl::util::string_to_constant()
#
@test ".string_to_constant() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::util::string_to_constant
	assert_failure $HBL_ERR_INVOCATION
}

@test ".string_to_constant() with too many arguments exits with ERR_INVOCATION" {
	run hbl::util::string_to_constant "string" "target_var" "extra"
	assert_failure $HBL_ERR_INVOCATION
}

@test ".string_to_constant() with an empty target variable exits with ERR_ARGUMENT" {
	run hbl::util::string_to_constant "string" ""
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".string_to_constant() handles ':'" {
	local result
	hbl::util::string_to_constant "foo:::bar" result
	assert_equal "${result}" "FOO___BAR"
}

@test ".string_to_constant() handles '-'" {
	local result
	hbl::util::string_to_constant "foo-bar" result
	assert_equal "${result}" "FOO_BAR"
}
