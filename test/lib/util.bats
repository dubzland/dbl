setup() {
	load '../test_helper/common'
	common_setup
}

#
# Util:is_defined()
#
@test 'Util:is_defined() with an undefined variable fails' {
	run $Util:is_defined undefined
	assert_failure $HBL_ERROR
	refute_output
}

@test 'Util:is_defined() with a defined variable succeeds' {
	local defined
	run $Util:is_defined defined
	assert_success
	refute_output
}

#
# Util:is_function()
#
@test 'Util:is_function() with an undefined variable fails' {
	run $Util:is_function undefined
	assert_failure $HBL_ERROR
	refute_output
}

@test 'Util:is_function() with a non-function variable fails' {
	local defined
	run $Util:is_function defined
	assert_failure $HBL_ERROR
	refute_output
}

@test 'Util:is_function() with a function succeeds' {
	function defined() { return 0; }
	run $Util:is_function defined
	assert_success
	refute_output
}

#
# Util:is_array()
#
@test 'Util:is_array() with an undefined variable fails' {
	run $Util:is_array 'UNDEFINED'
	assert_failure $HBL_ERROR
	refute_output
}

@test 'Util:is_array() with a normal variable fails' {
	declare DEFINED
	run $Util:is_array 'DEFINED'
	assert_failure $HBL_ERROR
	refute_output
}

@test 'Util:is_array() with an associative array fails' {
	declare -A DEFINED
	run $Util:is_array 'DEFINED'
	assert_failure $HBL_ERROR
	refute_output
}

@test 'Util:is_array() with a normal array succeeds' {
	declare -a DEFINED
	run $Util:is_array 'DEFINED'
	assert_success
	refute_output
}

#
# Util:is_associative_array()
#
@test 'Util:is_associative_array() with an undefined variable fails' {
	run $Util:is_associative_array 'UNDEFINED'
	assert_failure $HBL_ERROR
	refute_output
}

@test 'Util:is_associative_array() with a normal variable fails' {
	declare DEFINED
	run $Util:is_associative_array 'DEFINED'
	assert_failure $HBL_ERROR
	refute_output
}

@test 'Util:is_associative_array() with a normal array fails' {
	declare -a DEFINED
	run $Util:is_associative_array DEFINED
	assert_failure $HBL_ERROR
	refute_output
}

@test 'Util:is_dict() with an associative array succeeds' {
	declare -A DEFINED
	run $Util:is_dict 'DEFINED'
	assert_success
	refute_output
}
