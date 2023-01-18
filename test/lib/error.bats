setup() {
	load '../test_helper/common'
	common_setup

	function error_invocation() {
		hbl__error__invocation "foo"
	}

	function error_argument() {
		hbl__error__argument "foo" "bar"
	}

	function error_undefined() {
		hbl__error__undefined "foo"
	}

	function error_invalid_command() {
		hbl__error__invalid_command "foo"
	}

	function error_invalid_array() {
		hbl__error__invalid_array "foo"
	}

	function error_invalid_dict() {
		hbl__error__invalid_dict "foo"
	}

	function error_invalid_option() {
		hbl__error__invalid_option "foo"
	}

	function error_already_defined() {
		hbl__error__already_defined "foo"
	}

	function error_undefined_method() {
		hbl__error__undefined_method "foo"
	}
}

#
# hbl__error__invocation()
#
@test 'hbl__error__invocation() returns ERR_INVOCATION' {
	run error_invocation
	assert_failure $HBL_ERR_INVOCATION
}

@test 'hbl__error__invocation() with TRACE disabled prints a basic error' {
	TRACE=0
	run error_invocation
	assert_output "error_invocation: invalid arguments -- ['foo']"
}

@test 'hbl__error__invocation() with TRACE enabled prints a backtrace' {
	TRACE=1
	run error_invocation
	assert_line --index 0 'Backtrace (most recent call last):'
	assert_line --index -1 -p "in 'error_invocation': invalid arguments -- ['foo'] (HBL_ERR_INVOCATION)"
}

#
# hbl__error__argument()
#
@test 'hbl__error__argument() returns ERR_ARGUMENT' {
	run error_argument
	assert_failure $HBL_ERR_ARGUMENT
}

@test 'hbl__error__argument() with TRACE disabled prints a basic error' {
	TRACE=0
	run error_argument
	assert_output "error_argument: invalid argument for 'foo' -- 'bar'"
}

@test 'hbl__error__argument() with TRACE enabled prints a backtrace' {
	TRACE=1
	run error_argument
	assert_line --index 0 'Backtrace (most recent call last):'
	assert_line --index -1 -p "in 'error_argument': invalid argument for 'foo' -- 'bar' (HBL_ERR_ARGUMENT)"
}

#
# hbl__error__undefined()
#
@test 'hbl__error__undefined() returns ERR_UNDEFINED' {
	run error_undefined
	assert_failure $HBL_ERR_UNDEFINED
}

@test 'hbl__error__undefined() with TRACE disabled prints a basic error' {
	TRACE=0
	run error_undefined
	assert_output "error_undefined: variable is undefined -- 'foo'"
}

@test 'hbl__error__undefined() with TRACE enabled prints a backtrace' {
	TRACE=1
	run error_undefined
	assert_line --index 0 'Backtrace (most recent call last):'
	assert_line --index -1 -p "in 'error_undefined': variable is undefined -- 'foo' (HBL_ERR_UNDEFINED)"
}

#
# hbl__error__invalid_array()
#
@test "hbl__error__invalid_array() returns ERR_INVALID_ARRAY" {
	run error_invalid_array
	assert_failure $HBL_ERR_INVALID_ARRAY
}

@test 'hbl__error__invalid_array() with TRACE disabled prints a basic error' {
	TRACE=0
	run error_invalid_array
	assert_output "error_invalid_array: not an array -- 'foo'"
}

@test 'hbl__error__invalid_array() with TRACE enabled prints a backtrace' {
	TRACE=1
	run error_invalid_array
	assert_line --index 0 'Backtrace (most recent call last):'
	assert_line --index -1 -p "in 'error_invalid_array': not an array -- 'foo' (HBL_ERR_INVALID_ARRAY)"
}

#
# hbl__error__invalid_dict()
#
@test 'hbl__error__invalid_dict() returns ERR_INVALID_DICT' {
	run error_invalid_dict
	assert_failure $HBL_ERR_INVALID_DICT
}

@test 'hbl__error__invalid_dict() with TRACE disabled prints a basic error' {
	TRACE=0
	run error_invalid_dict
	assert_output "error_invalid_dict: not a dictionary -- 'foo'"
}

@test 'hbl__error__invalid_dict() with TRACE enabled prints a backtrace' {
	TRACE=1
	run error_invalid_dict
	assert_line --index 0 'Backtrace (most recent call last):'
	assert_line --index -1 -p "in 'error_invalid_dict': not a dictionary -- 'foo' (HBL_ERR_INVALID_DICT)"
}

#
# hbl__error__invalid_option()
#
@test 'hbl__error__invalid_option() returns ERR_INVALID_OPTION' {
	run error_invalid_option
	assert_failure $HBL_ERR_INVALID_OPTION
}

@test 'hbl__error__invalid_option() with TRACE disabled prints a basic error' {
	TRACE=0
	run error_invalid_option
	assert_output "error_invalid_option: invalid option id -- 'foo'"
}

@test 'hbl__error__invalid_option() with TRACE enabled prints a backtrace' {
	TRACE=1
	run error_invalid_option
	assert_line --index 0 'Backtrace (most recent call last):'
	assert_line --index -1 -p "in 'error_invalid_option': invalid option id -- 'foo' (HBL_ERR_INVALID_OPTION)"
}

#
# hbl__error__already_defined()
#
@test 'hbl__error__already_defined() returns ERR_ALREADY_DEFINED' {
	run error_already_defined
	assert_failure $HBL_ERR_ALREADY_DEFINED
}

@test 'hbl__error__already_defined() with TRACE disabled prints a basic error' {
	TRACE=0
	run error_already_defined
	assert_output "error_already_defined: variable is already defined -- 'foo'"
}

@test 'hbl__error__already_defined() with TRACE enabled prints a backtrace' {
	TRACE=1
	run error_already_defined
	assert_line --index 0 'Backtrace (most recent call last):'
	assert_line --index -1 -p "in 'error_already_defined': variable is already defined -- 'foo' (HBL_ERR_ALREADY_DEFINED)"
}

#
# hbl__error__undefined_method()
#
@test 'hbl__error__undefined_method() returns ERR_UNDEFINED_METHOD' {
	run error_undefined_method
	assert_failure $HBL_ERR_UNDEFINED_METHOD
}

@test 'hbl__error__undefined_method() with TRACE disabled prints a basic error' {
	TRACE=0
	run error_undefined_method
	assert_output "error_undefined_method: object does not respond to method -- 'foo'"
}

@test 'hbl__error__undefined_method() with TRACE enabled prints a backtrace' {
	TRACE=1
	run error_undefined_method
	assert_line --index 0 'Backtrace (most recent call last):'
	assert_line --index -1 -p "in 'error_undefined_method': object does not respond to method -- 'foo' (HBL_ERR_UNDEFINED_METHOD)"
}
