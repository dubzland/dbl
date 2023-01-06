setup() {
	load '../test_helper/common'
	common_setup
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

@test ".is_defined() with an undefined variable fails" {
	run hbl::util::is_defined UNDEFINED
	assert_failure
}

@test ".is_defined() with an defined variable succeeds" {
	declare DEFINED
	run hbl::util::is_defined DEFINED
	assert_success
}

@test ".is_array() with an undefined variable fails" {
	run hbl::util::is_array UNDEFINED
	assert_failure
}

@test ".is_array() with a normal variable fails" {
	declare DEFINED
	run hbl::util::is_array DEFINED
	assert_failure
}

@test ".is_array() with a normal array succeeds" {
	declare -a DEFINED
	run hbl::util::is_array DEFINED
	assert_success
}

@test ".is_array() with an associative array fails" {
	declare -A DEFINED
	run hbl::util::is_array DEFINED
	assert_failure
}

@test ".is_dict() with an undefined variable fails" {
	run hbl::util::is_dict UNDEFINED
	assert_failure
}

@test ".is_dict() with a normal variable fails" {
	declare DEFINED
	run hbl::util::is_dict DEFINED
	assert_failure
}

@test ".is_dict() with a normal array fails" {
	declare -a DEFINED
	run hbl::util::is_dict DEFINED
	assert_failure
}

@test ".is_dict() with an associative array succeeds" {
	declare -A DEFINED
	run hbl::util::is_dict DEFINED
	assert_success
}

@test ".string_to_underscore() handles ':'" {
	local result
	result=""
	hbl::util::string_to_underscore "foo:bar" result
	assert_equal "${result}" "foo_bar"
}

@test ".string_to_underscore() handles '-'" {
	local result
	result=""
	hbl::util::string_to_underscore "foo-bar" result
	assert_equal "${result}" "foo_bar"
}

@test ".string_to_constant() handles ':'" {
	local result
	result=""
	hbl::util::string_to_constant "foo:::bar" result
	assert_equal "${result}" "FOO___BAR"
}

@test ".string_to_constant() handles '-'" {
	local result
	result=""
	hbl::util::string_to_constant "foo-bar" result
	assert_equal "${result}" "FOO_BAR"
}
