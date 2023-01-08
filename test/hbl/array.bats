setup() {
	load '../test_helper/common'
	common_setup

	function validate_array() {
		hbl::array::validate "$@"
	}
}

#
# hbl::array::contains()
#
@test ".contains() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::array::contains
	assert_failure $HBL_ERR_INVOCATION
	assert_output "hbl::array::contains: invalid arguments -- ''"
}

@test ".contains() with too many arguments exits with ERR_INVOCATION" {
	run hbl::array::contains "haystack" "needle" "extra"
	assert_failure $HBL_ERR_INVOCATION
	assert_output "hbl::array::contains: invalid arguments -- 'haystack needle extra'"
}

@test ".contains() with an empty array name exits with ERR_ARGUMENT" {
	run hbl::array::contains "" "needle"
	assert_failure $HBL_ERR_ARGUMENT
	assert_output "hbl::array::contains: invalid argument for 'haystack' -- ''"
}

@test ".contains() with an undefined array exits with ERR_UNDEFINED" {
	run hbl::array::contains "invalid" "needle"
	assert_failure $HBL_UNDEFINED
	assert_output "hbl::array::contains: variable is undefined -- 'invalid'"
}

@test ".contains() with a non-array exits with ERR_INVALID_ARRAY" {
	declare -A array
	run hbl::array::contains "array" "needle"
	assert_failure $HBL_ERR_INVALID_ARRAY
	assert_output "hbl::array::contains: not an array -- 'array'"
}

@test ".contains() when the value is not present returns ERROR" {
	declare -a haystack
	run hbl::array::contains "haystack" "needle"
	assert_failure $HBL_ERROR
}

@test ".contains() when the value is present succeeds" {
	declare -a haystack
	haystack=("needle")
	run hbl::array::contains "haystack" "needle"
	assert_success
}

#
# hbl::array::append()
#
@test ".append() with insufficient arguments exits with INVALID_ARGS" {
	run hbl::array::append
	assert_failure $HBL_INVALID_ARGS
	assert_output "hbl::array::append: invalid arguments -- ''"
}

@test ".append() with an empty array name exits with ERR_ARGUMENT" {
	run hbl::array::append '' 'value'
	assert_failure $HBL_ERR_ARGUMENT
	assert_output "hbl::array::append: invalid argument for 'array' -- ''"
}

@test ".append() with a non-existent array exits with ERR_UNDEFINED" {
	run hbl::array::append "notarray" "foo"
	assert_failure $HBL_ERR_UNDEFINED
}

@test ".append() with a non-array exits with ERR_INVALID_ARRAY" {
	declare -A array
	run hbl::array::append "array" "foo"
	assert_failure $HBL_ERR_INVALID_ARRAY
}

@test ".append() adds to the array" {
	declare -a myarray
	hbl::array::append "myarray" "foo"
	hbl::array::contains "myarray" "foo"
}

#
# hbl::array::bubble_sort()
#
@test ".bubble_sort() with insufficient arguments exits with INVALID_ARGS" {
	run hbl::array::bubble_sort
	assert_failure $HBL_INVALID_ARGS
	assert_output "hbl::array::bubble_sort: invalid arguments -- ''"
}

@test ".bubble_sort() with more than one argument returns ERR_INVOCATION" {
	run hbl::array::bubble_sort "array" "extra"
	assert_failure $HBL_ERR_INVOCATION
	assert_output "hbl::array::bubble_sort: invalid arguments -- 'array extra'"
}
@test ".bubble_sort() with an empty array name exits with ERR_ARGUMENT" {
	run hbl::array::bubble_sort ""
	assert_failure $HBL_ERR_ARGUMENT
	assert_output "hbl::array::bubble_sort: invalid argument for 'array' -- ''"
}

@test ".bubble_sort() with a non-existent array exits with ERR_UNDEFINED" {
	run hbl::array::bubble_sort "notarray"
	assert_failure $HBL_ERR_UNDEFINED
}

@test ".bubble_sort() with a non-array exits with ERR_INVALID_ARRAY" {
	declare -A array
	run hbl::array::bubble_sort "array"
	assert_failure $HBL_ERR_INVALID_ARRAY
}
@test ".bubble_sort() properly sorts the array" {
	declare -a myarray=("orange" "apple" "lemon" "banana")
	hbl::array::bubble_sort "myarray"
	assert_equal "${myarray[*]}" "apple banana lemon orange"
}

#
# hbl::array::validate()
#
@test ".validate() with no arguments returns ERR_INVOCATION" {
	run validate_array
	assert_failure $HBL_ERR_INVOCATION
	assert_output "hbl::array::validate: invalid arguments -- ''"
}

@test ".validate() with more than one argument returns ERR_INVOCATION" {
	run validate_array "array" "extra"
	assert_failure $HBL_ERR_INVOCATION
	assert_output "hbl::array::validate: invalid arguments -- 'array extra'"
}

@test ".validate() with an empty array name returns ERR_ARGUMENT" {
	run validate_array ""
	assert_failure $HBL_ERR_ARGUMENT
	assert_output "hbl::array::validate: invalid argument for 'array' -- ''"
}

@test ".validate() with an undefined variable returns ERR_UNDEFINED" {
	run validate_array "array"
	assert_failure $HBL_ERR_UNDEFINED
	assert_output "validate_array: variable is undefined -- 'array'"
}

@test ".validate() with a non-array variable returns ERR_INVALID_ARRAY" {
	declare -A array
	run validate_array "array"
	assert_failure $HBL_ERR_INVALID_ARRAY
	assert_output "validate_array: not an array -- 'array'"
}

@test ".validate() with a valid array succeeds" {
	declare -a array
	run validate_array "array"
	assert_success
	refute_output
}
