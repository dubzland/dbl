setup() {
	load '../test_helper/common'
	common_setup
}

#
# hbl::string::to_underscore()
#
@test 'hbl::string::to_underscore() validates its arguments' {
	# insufficient arguments
	run hbl::string::to_underscore
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::string::to_underscore 'string' 'target_var' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty target variable name
	run hbl::string::to_underscore 'string' ''
	assert_failure $HBL_ERR_ARGUMENT
}

@test 'hbl::string::to_underscore() succeeds' {
	local result
	run hbl::string::to_underscore 'foo bar' 'result'
	assert_success
}

@test 'hbl::string::to_underscore() formats the string' {
	local result
	hbl::string::to_underscore 'foo bar' 'result'
	assert_equal "${result}" 'foo_bar'
}

@test 'hbl::string::to_underscore() handles ":"' {
	local result
	hbl::string::to_underscore 'foo:bar' 'result'
	assert_equal "${result}" 'foo_bar'
}

@test 'hbl::string::to_underscore() handles "-"' {
	local result
	hbl::string::to_underscore 'foo-bar' result
	assert_equal "${result}" 'foo_bar'
}

#
# hbl::string::to_constant()
#
@test 'hbl::string::to_constant() validates its arguments' {
	# insufficient arguments
	run hbl::string::to_constant
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::string::to_constant 'string' 'target_var' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty target variable name
	run hbl::string::to_constant 'string' ''
	assert_failure $HBL_ERR_ARGUMENT
}

@test 'hbl::string::to_constant() succeeds' {
	local result
	run hbl::string::to_constant 'foobar' 'result'
	assert_success
}

@test 'hbl::string::to_constant() converts the string' {
	local result
	hbl::string::to_constant 'foobar' 'result'
	assert_equal "$result" 'FOOBAR'
}

@test 'hbl::string::to_constant() handles ":"' {
	local result
	hbl::string::to_constant "foo:::bar" result
	assert_equal "${result}" "FOO___BAR"
}

@test 'hbl::string::to_constant() handles "-"' {
	local result
	hbl::string::to_constant 'foo-bar' result
	assert_equal "${result}" 'FOO_BAR'
}
