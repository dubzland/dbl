setup() {
	load '../test_helper/common'
	common_setup
}

#
# hbl::util::is_defined()
#
@test 'hbl::util::is_defined() validates its arguments' {
	# insufficient arguments
	run hbl::util::is_defined
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::util::is_defined 'var' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty variable name
	run hbl::util::is_defined ''
	assert_failure $HBL_ERR_ARGUMENT
}

@test 'hbl::util::is_defined() with an undefined variable fails' {
	run hbl::util::is_defined 'UNDEFINED'
	assert_failure $HBL_ERROR
	refute_output
}

@test 'hbl::util::is_defined() with a defined variable succeeds' {
	declare DEFINED
	run hbl::util::is_defined 'DEFINED'
	assert_success
	refute_output
}

#
# hbl::util::is_function()
#
@test 'hbl::util::is_function() validates its arguments' {
	# insufficient arguments
	run hbl::util::is_function
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::util::is_function 'func' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty function name
	run hbl::util::is_function ''
	assert_failure $HBL_ERR_ARGUMENT
}

@test 'hbl::util::is_function() with an undefined variable fails' {
	run hbl::util::is_function "nonexistent"
	assert_failure
}

@test 'hbl::util::is_function() with a non-function fails' {
	declare -a FUNCTION
	run hbl::util::is_function 'FUNCTION'
	assert_failure
}

@test 'hbl::util::is_function() with an existing function succeeds' {
	function existent() { return 0; }
	run hbl::util::is_function "existent"
	assert_success
}

#
# hbl::util::is_array()
#
@test 'hbl::util::is_array() validates its arguments' {
	# insufficient arguments
	run hbl::util::is_array
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::util::is_array 'array' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty array name
	run hbl::util::is_array ''
	assert_failure $HBL_ERR_ARGUMENT
}

@test 'hbl::util::is_array() with an undefined variable fails' {
	run hbl::util::is_array 'UNDEFINED'
	assert_failure $HBL_ERROR
	refute_output
}

@test 'hbl::util::is_array() with a normal variable fails' {
	declare DEFINED
	run hbl::util::is_array 'DEFINED'
	assert_failure $HBL_ERROR
	refute_output
}

@test 'hbl::util::is_array() with an associative array fails' {
	declare -A DEFINED
	run hbl::util::is_array 'DEFINED'
	assert_failure $HBL_ERROR
	refute_output
}

@test 'hbl::util::is_array() with a normal array succeeds' {
	declare -a DEFINED
	run hbl::util::is_array 'DEFINED'
	assert_success
	refute_output
}

#
# hbl::util::is_dict()
#
@test 'hbl::util::is_dict() validates its arguments' {
	# insufficient arguments
	run hbl::util::is_dict
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::util::is_dict 'dict' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty dict name
	run hbl::util::is_dict ''
	assert_failure $HBL_ERR_ARGUMENT
}

@test 'hbl::util::is_dict() with an undefined variable fails' {
	run hbl::util::is_dict 'UNDEFINED'
	assert_failure $HBL_ERROR
	refute_output
}

@test 'hbl::util::is_dict() with a normal variable fails' {
	declare DEFINED
	run hbl::util::is_dict 'DEFINED'
	assert_failure $HBL_ERROR
	refute_output
}

@test 'hbl::util::is_dict() with a normal array fails' {
	declare -a DEFINED
	run hbl::util::is_dict DEFINED
	assert_failure $HBL_ERROR
	refute_output
}

@test 'hbl::util::is_dict() with an associative array succeeds' {
	declare -A DEFINED
	run hbl::util::is_dict 'DEFINED'
	assert_success
	refute_output
}
