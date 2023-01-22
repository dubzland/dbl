setup() {
	load '../test_helper/common'
	common_setup
}

teardown() {
	stub_teardown
}

#
# __hbl__Util__static__is_defined()
#
@test '__hbl__Util__static__is_defined() succeeds' {
	local defined
	run __hbl__Util__static__is_defined defined
	assert_success
	refute_output
}

@test '__hbl__Util__static__is_defined() with insufficient arguments fails' {
	run __hbl__Util__static__is_defined
	assert_failure $HBL_ERR_ARGUMENT
	refute_output
}

@test '__hbl__Util__static__is_defined() with an undefined variable fails' {
	run __hbl__Util__static__is_defined undefined
	assert_failure $HBL_ERROR
	refute_output
}

@test '__ubl__Util__static__is_defined() with an empty variable name fails' {
	run __hbl__Util__static__is_defined ''
	assert_failure $HBL_ERR_ARGUMENT
	refute_output
}

#
# __hbl__Util__static__is_function()
#
@test '__hbl__Util__static__is_function() succeeds' {
	function defined() { return 0; }
	run __hbl__Util__static__is_function defined
	assert_success
	refute_output
}

@test '__hbl__Util__static__is_function() with insufficient arguments fails' {
	run __hbl__Util__static__is_function
	assert_failure $HBL_ARGUMENT
	refute_output
}

@test '__hbl__Util__static__is_function() with an undefined variable fails' {
	run __hbl__Util__static__is_function undefined
	assert_failure $HBL_ERROR
	refute_output
}

@test '__hbl__Util__static__is_function() with a non-function variable fails' {
	local defined
	run __hbl__Util__static__is_function defined
	assert_failure $HBL_ERROR
	refute_output
}

@test '__hbl__Util__static__is_function() with an empty variable fails' {
	run __hbl__Util__static__is_function ''
	assert_failure $HBL_ARGUMENT
	refute_output
}

#
# __hbl__Util__static__is_associative_array()
#
@test '__hbl__Util__static__is_associative_array() succeeds' {
	declare -A defined
	run __hbl__Util__static__is_associative_array defined
	assert_success
	refute_output
}

@test '__hbl__Util__static__is_associative_array() with an undefined variable fails' {
	run __hbl__Util__static__is_associative_array undefined
	assert_failure $HBL_ERROR
	refute_output

	# Try again forcing BASH4 compatability
	FORCE_BASH4=1 run __hbl__Util__static__is_associative_array undefined
	assert_failure $HBL_ERROR
	refute_output
}

@test '__hbl__Util__static__is_associative_array() with a normal variable fails' {
	declare defined
	run __hbl__Util__static__is_associative_array defined
	assert_failure $HBL_ERROR
	refute_output
}

@test '__hbl__Util__static__is_associative_array() with a normal array fails' {
	declare -a defined
	run __hbl__Util__static__is_associative_array defined
	assert_failure $HBL_ERROR
	refute_output
}

@test '__hbl__Util__static__is_associative_array() with insufficent arguments fails' {
	run __hbl__Util__static__is_associative_array
	assert_failure $HBL_ERR_ARGUMENT
	refute_output
}

@test '__hbl__Util__static__is_associative_array() with an empty variable fails' {
	run __hbl__Util__static__is_associative_array ''
	assert_failure $HBL_ERR_ARGUMENT
	refute_output
}

#
# __hbl__Util__static__dump_associative_array()
#
@test '__hbl__Util__static__dump_associative_array() succeeds' {
	declare -A defined
	defined=( [size]=large [color]=red )
	run __hbl__Util__static__dump_associative_array defined
	assert_success
	assert_output
}

@test '__hbl__Util__static__dump_associative_array() prints the array contents' {
	declare -A defined
	defined=( [size]=large [color]=red )
	run __hbl__Util__static__dump_associative_array defined
	assert_line --index 0 '=============== defined ================'
	assert_line --index 1 'color:          red'
	assert_line --index 2 'size:           large'
	assert_line --index 3 '^^^^^^^^^^^^^^^ defined ^^^^^^^^^^^^^^^^'
}

@test '__hbl__Util__static__dump_associative_array() with insufficient arguments fails' {
	run __hbl__Util__static__dump_associative_array
	assert_failure $HBL_ERR_ARGUMENT
	refute_output
}

@test '__hbl__Util__static__dump_associative_array() with an empty array name fails' {
	run __hbl__Util__static__dump_associative_array ''
	assert_failure $HBL_ERR_ARGUMENT
	refute_output
}

@test '__hbl__Util__static__dump_associative_array() with a non-array fails' {
	run __hbl__Util__static__dump_associative_array undefined
	assert_failure $HBL_ERR_ARGUMENT
	refute_output
}

#
# Util.is_defined()
#
@test 'Util.is_defined() calls the static function' {
	stub __hbl__Util__static__is_defined
	$Util.is_defined var
	assert_stub_with_args __hbl__Util__static__is_defined var
}

#
# Util.is_function()
#
@test 'Util.is_function() calls the static function' {
	stub __hbl__Util__static__is_function
	$Util.is_function var
	assert_stub_with_args __hbl__Util__static__is_function var
}

#
# Util.is_associative_array()
#
@test 'Util.is_associative_array() calls the static function' {
	stub __hbl__Util__static__is_associative_array
	$Util.is_associative_array var
	assert_stub_with_args __hbl__Util__static__is_associative_array var
}

#
# Util.is_defined()
#
@test 'Util.dump_associative_array() calls the static function' {
	stub __hbl__Util__static__dump_associative_array
	$Util.dump_associative_array var
	assert_stub_with_args __hbl__Util__static__dump_associative_array var
}
