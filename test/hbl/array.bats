setup() {
	load '../test_helper/common'
	common_setup
}

@test ".contains() when insufficient arguments are passed returns INVALID_ARGS" {
	run hbl::array::contains
	assert_failure $HBL_INVALID_ARGS
}

@test ".contains() when too many arguments are passed returns INVALID_ARGS" {
	run hbl::array::contains haystack needle extra
	assert_failure $HBL_INVALID_ARGS
}

@test ".contains() for a non-existent arrray returns 2" {
	run hbl::array::contains haystack needle
	assert_failure 2
}

@test ".contains() when the value is not present returns 1" {
	declare -a haystack
	run hbl::array::contains haystack needle
	assert_failure 1
}

@test ".contains() when the value is present returns 0" {
	declare -a haystack
	haystack=("needle")
	run hbl::array::contains haystack needle
	assert_success
}
