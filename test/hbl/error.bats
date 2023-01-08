setup() {
	load '../test_helper/common'
	common_setup
	hbl::init

	function error_invocation() {
		hbl::error::invocation "foo"
	}

	function error_argument() {
		hbl::error::argument "foo" "bar"
	}

	function error_undefined() {
		hbl::error::undefined "foo"
	}

	function error_invalid_command() {
		hbl::error::invalid_command "foo"
	}

	function error_invalid_array() {
		hbl::error::invalid_array "foo"
	}

	function error_invalid_dict() {
		hbl::error::invalid_dict "foo"
	}

	function error_invalid_option() {
		hbl::error::invalid_option "foo"
	}
}

#
# hbl::error::invocation()
#
@test 'hbl::error::invocation() returns ERR_INVOCATION' {
	run error_invocation
	assert_failure $HBL_ERR_INVOCATION
}

@test 'hbl::error::invocation() with TRACE disabled prints nothing' {
	run error_invocation
	refute_output
}

@test 'hbl::error::invocation() with TRACE enabled prints the proper error' {
	TRACE=1
	run error_invocation
	assert_output -p "Backtrace (most recent call last)"
	assert_output -p "invalid arguments -- 'foo'"
}

#
# hbl::error::argument()
#
@test 'hbl::error::argument() returns ERR_ARGUMENT' {
	run error_argument
	assert_failure $HBL_ERR_ARGUMENT
}

@test 'hbl::error::argument() with TRACE disabled prints nothing' {
	run error_argument
	refute_output
}

@test 'hbl::error::argument() prints the proper error' {
	TRACE=1
	run error_argument
	assert_output -p "Backtrace (most recent call last)"
	assert_output -p "invalid argument for 'foo' -- 'bar'"
}

#
# hbl::error::undefined()
#
@test 'hbl::error::undefined() returns ERR_UNDEFINED' {
	run error_undefined
	assert_failure $HBL_ERR_UNDEFINED
}

@test 'hbl::error::undefined() with TRACE disabled prints nothing' {
	run error_undefined
	refute_output
}

@test 'hbl::error::undefined() with TRACE enabled prints the proper error' {
	TRACE=1
	run error_undefined
	assert_output -p "Backtrace (most recent call last)"
	assert_output -p "variable is undefined -- 'foo'"
}

#
# hbl::error::invalid_array()
#
@test "hbl::error::invalid_array() returns ERR_INVALID_ARRAY" {
	run error_invalid_array
	assert_failure $HBL_ERR_INVALID_ARRAY
}

@test 'hbl::error::invalid_array() with TRACE disabled prints nothing' {
	run error_invalid_array
	refute_output
}

@test 'hbl::error::invalid_array() with TRACE enabled prints the proper error' {
	TRACE=1
	run error_invalid_array
	assert_output -p "Backtrace (most recent call last)"
	assert_output -p "not an array -- 'foo'"
}

#
# hbl::error::invalid_dict()
#
@test 'hbl::error::invalid_dict() returns ERR_INVALID_DICT' {
	run error_invalid_dict
	assert_failure $HBL_ERR_INVALID_DICT
}

@test 'hbl::error::invalid_dict() with TRACE disabled prints nothing' {
	run error_invalid_dict
	refute_output
}

@test 'hbl::error::invalid_dict() with TRACE enabled prints the proper error' {
	TRACE=1
	run error_invalid_dict
	assert_output -p "Backtrace (most recent call last):"
	assert_output -p "not a dictionary -- 'foo'"
}

#
# hbl::error::invalid_option()
#
@test 'hbl::error::invalid_option() returns ERR_INVALID_OPTION' {
	run error_invalid_option
	assert_failure $HBL_ERR_INVALID_OPTION
}

@test 'hbl::error::invalid_option() with TRACE disabled prints nothing' {
	run error_invalid_option
	refute_output
}

@test 'hbl::error::invalid_option() with TRACE enabled prints the proper error' {
	TRACE=1
	# export TRACE
	run error_invalid_option
	assert_output -p "Backtrace (most recent call last)"
	assert_output -p "invalid option id -- 'foo'"
}
