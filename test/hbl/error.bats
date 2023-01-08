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

@test ".invocation() prints the proper error" {
	run error_invocation
	assert_output "error_invocation: invalid arguments -- 'foo'"
}

@test ".invocation() returns ERR_INVOCATION" {
	run error_invocation
	assert_failure $HBL_ERR_INVOCATION
}

@test ".argument() prints the proper error" {
	run error_argument
	assert_output "error_argument: invalid argument for 'foo' -- 'bar'"
}

@test ".argument() returns ERR_ARGUMENT" {
	run error_argument
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".undefined() prints the proper error" {
	run error_undefined
	assert_output "error_undefined: variable is undefined -- 'foo'"
}

@test ".undefined() returns ERR_UNDEFINED" {
	run error_undefined
	assert_failure $HBL_ERR_UNDEFINED
}

@test ".invalid_command() prints the proper error" {
	run error_invalid_command
	assert_output "error_invalid_command: invalid command id -- 'foo'"
}

@test ".invalid_command() returns ERR_INVALID_COMMAND" {
	run error_invalid_command
	assert_failure $HBL_ERR_INVALID_COMMAND
}

@test ".invalid_array() prints the proper error" {
	run error_invalid_array
	assert_output "error_invalid_array: not an array -- 'foo'"
}

@test ".invalid_array() returns ERR_INVALID_ARRAY" {
	run error_invalid_array
	assert_failure $HBL_ERR_INVALID_ARRAY
}

@test ".invalid_dict() prints the proper error" {
	run error_invalid_dict
	assert_output "error_invalid_dict: not a dictionary -- 'foo'"
}

@test ".invalid_dict() returns ERR_INVALID_DICT" {
	run error_invalid_dict
	assert_failure $HBL_ERR_INVALID_DICT
}

@test ".invalid_option() prints the proper error" {
	run error_invalid_option
	assert_output "error_invalid_option: invalid option id -- 'foo'"
}

@test ".invalid_option() returns ERR_INVALID_OPTION" {
	run error_invalid_option
	assert_failure $HBL_ERR_INVALID_OPTION
}
