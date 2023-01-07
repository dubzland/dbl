setup() {
	load '../test_helper/common'
	common_setup
	hbl::init
}

@test ".invalid_arg_count() prints the proper error" {
	run hbl::error::invalid_args foo 2 bar
	assert_output "Invalid arguments to foo -- 2 bar"
}

@test ".invalid_arg_count() returns INVALID_ARGS" {
	run hbl::error::invalid_args foo 2 bar
	assert_failure $HBL_INVALID_ARGS
}

@test ".undefined() prints the proper error" {
	run hbl::error::undefined foo bar
	assert_output "error: foo: bar is undefined"
}

@test ".undefined returns UNDEFINED" {
	run hbl::error::undefined foo bar
	assert_failure $HBL_UNDEFINED
}
