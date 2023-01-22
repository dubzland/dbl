#setup() {
#	load '../test_helper/common'
#	common_setup

#	function error_invocation() {
#		$Error.invocation 'method' "foo"
#	}

#	function error_argument() {
#		$Error.argument 'method' 'foo' 'bar'
#	}

#	function error_undefined() {
#		$Error.undefined 'foo'
#	}

#	function error_already_defined() {
#		$Error.already_defined 'foo'
#	}

#	function error_undefined_method() {
#		$Error.undefined_method 'Object' 'foo'
#	}

#	function error_illegal_instruction() {
#		$Error.illegal_instruction 'Object.__name=' 'system values cannot be set'
#	}
#}

##
## Error.invocation()
##
## @test 'Error.invocation() returns ERR_INVOCATION' {
## 	run error_invocation
## 	assert_failure $HBL_ERR_INVOCATION
## }

#@test 'Error.invocation() with TRACE disabled prints a basic error' {
#	TRACE=0
#	run error_invocation
#	assert_output -p "in 'error_invocation': invalid arguments -- ['foo']"
#}

## @test 'Error.invocation() with TRACE enabled prints a backtrace' {
## 	TRACE=1
## 	run error_invocation
## 	assert_line --index 0 'Backtrace (most recent call last):'
## 	assert_line --index -1 -p "invalid arguments to 'method' -- ['foo'] (HBL_ERR_INVOCATION)"
## }

###
### Error.argument()
###
##@test 'Error.argument() returns ERR_ARGUMENT' {
##	run error_argument
##	assert_failure $HBL_ERR_ARGUMENT
##}

##@test 'Error.argument() with TRACE disabled prints a basic error' {
##	TRACE=0
##	run error_argument
##	assert_output -p "invalid argument to 'method' for 'foo' -- 'bar'"
##}

##@test 'Error.argument() with TRACE enabled prints a backtrace' {
##	TRACE=1
##	run error_argument
##	assert_line --index 0 'Backtrace (most recent call last):'
##	assert_line --index -1 -p "invalid argument to 'method' for 'foo' -- 'bar' (HBL_ERR_ARGUMENT)"
##}

###
### Error.undefined()
###
##@test 'Error.undefined() returns ERR_UNDEFINED' {
##	run error_undefined
##	assert_failure $HBL_ERR_UNDEFINED
##}

##@test 'Error.undefined() with TRACE disabled prints a basic error' {
##	TRACE=0
##	run error_undefined
##	assert_output -p "variable is undefined -- 'foo'"
##}

##@test 'Error.undefined() with TRACE enabled prints a backtrace' {
##	TRACE=1
##	run error_undefined
##	assert_line --index 0 'Backtrace (most recent call last):'
##	assert_line --index -1 -p ": variable is undefined -- 'foo' (HBL_ERR_UNDEFINED)"
##}

###
### Error.already_defined()
###
##@test 'Error.already_defined() returns ERR_ALREADY_DEFINED' {
##	run error_already_defined
##	assert_failure $HBL_ERR_ALREADY_DEFINED
##}

##@test 'Error.already_defined() with TRACE disabled prints a basic error' {
##	TRACE=0
##	run error_already_defined
##	assert_output -p ": variable is already defined -- 'foo'"
##}

##@test 'Error.already_defined() with TRACE enabled prints a backtrace' {
##	TRACE=1
##	run error_already_defined
##	assert_line --index 0 'Backtrace (most recent call last):'
##	assert_line --index -1 -p ": variable is already defined -- 'foo' (HBL_ERR_ALREADY_DEFINED)"
##}

###
### Error.undefined_method()
###
##@test 'Error.undefined_method() returns ERR_UNDEFINED_METHOD' {
##	run error_undefined_method
##	assert_failure $HBL_ERR_UNDEFINED_METHOD
##}

##@test 'Error.undefined_method() with TRACE disabled prints a basic error' {
##	TRACE=0
##	run error_undefined_method
##	assert_output -p ": Object does not respond to method -- 'foo'"
##}

##@test 'Error.undefined_method() with TRACE enabled prints a backtrace' {
##	TRACE=1
##	run error_undefined_method
##	assert_line --index 0 'Backtrace (most recent call last):'
##	assert_line --index -1 -p ": Object does not respond to method -- 'foo' (HBL_ERR_UNDEFINED_METHOD)"
##}

###
### Error.illegal_instruction()
###
##@test 'Error.illegal_instruction() returns ERR_ILLEGAL_INSTRUCTION' {
##	run error_illegal_instruction
##	assert_failure $HBL_ERR_ILLEGAL_INSTRUCTION
##}

##@test 'Error.illegal_instruction() with TRACE disabled prints a basic error' {
##	TRACE=0
##	run error_illegal_instruction
##	assert_output -p ": illegal instruction (Object.__name=) -- 'system values cannot be set'"
##}

##@test 'Error.illegal_instruction() with TRACE enabled prints a backtrace' {
##	TRACE=1
##	run error_illegal_instruction
##	assert_line --index 0 'Backtrace (most recent call last):'
##	assert_line --index -1 -p ": illegal instruction (Object.__name=) -- 'system values cannot be set' (HBL_ERR_ILLEGAL_INSTRUCTION)"
##}
