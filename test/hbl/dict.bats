setup() {
	load '../test_helper/common'

	common_setup
}

@test ".set() when insufficient arguments are passed returns INVALID_ARGS" {
	run hbl::dict::set mydict mykey
	assert_failure $HBL_INVALID_ARGS
}

@test ".set() when the dict does not exist returns UNDEFINED" {
	run hbl::dict::set mydict mykey myval
	assert_failure $HBL_UNDEFINED
}

@test ".set() assigns a value to the dict (by reference)" {
	declare -A mydict
	hbl::dict::set mydict mykey myval
	assert_equal "${mydict[mykey]}" "myval"
}

@test ".set() supports values with spaces" {
	declare -A mydict
	hbl::dict::set mydict mykey myval with space
	assert_equal "${mydict[mykey]}" "myval with space"
}

@test ".has_key() when insufficient arguments are passed returns INVALID_ARGS" {
	declare -A mydict
	run hbl::dict::has_key mydict
	assert_failure $HBL_INVALID_ARGS
}

@test ".has_key() when too many arguments are passed returns INVALID_ARGS" {
	declare -A mydict
	run hbl::dict::has_key mydict myval extra
	assert_failure $HBL_INVALID_ARGS
}

@test ".has_key() when the dict does not exist returns UNDEFINED" {
	run hbl::dict::has_key mydict mykey
	assert_failure $HBL_UNDEFINED
}

@test ".has_key() when the key does not exist returns ERROR" {
	declare -Ag mydict
	run hbl::dict::has_key mydict mykey
	assert_failure $HBL_ERROR
}

@test ".has_key() returns 0" {
	declare -Ag mydict
	mydict[mykey]=myval
	run hbl::dict::has_key mydict mykey
	assert_success
}

@test ".get() when insufficient arguments are passed returns INVALID_ARGS" {
	declare -A mydict
	run hbl::dict::get mydict
	assert_failure $HBL_INVALID_ARGS
}

@test ".get() when too many arguments are passed returns INVALID_ARGS" {
	declare -A mydict
	run hbl::dict::get mydict myval myvar extra
	assert_failure $HBL_INVALID_ARGS
}

@test ".get() when the dict does not exist returns UNDEFINED" {
	run hbl::dict::get mydict mykey myvar
	assert_failure $HBL_UNDEFINED
}

@test ".get() when the key does not exist returns ERROR" {
	declare -Ag mydict
	run hbl::dict::get mydict mykey myvar
	assert_failure $HBL_ERROR
}

@test ".get() succeeds" {
	declare -Ag mydict
	mydict[mykey]=myval
	run hbl::dict::get mydict mykey myvar
	assert_success
}

@test ".get() assigns the value by reference" {
	declare -Ag mydict
	local myvar
	mydict[mykey]="test"
	hbl::dict::get mydict mykey myvar
	assert_equal "$myvar" "test"
}
