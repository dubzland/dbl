setup() {
	load '../test_helper/common'
	common_setup

	function ensure_array() {
		hbl::array::ensure_array "$@"
	}
}

function stub_private() {
	function hbl::array::_contains() { printf "_contains: [$*]\n"; }
	function hbl::array::_append() { printf "_append: [$*]\n"; }
	function hbl::array::_bubble_sort() { printf "_bubble_sort: [$*]\n"; }
}

#
# hbl::array::contains()
#
@test 'hbl::array::contains() validates its arguments' {
	# insufficient arguments
	run hbl::array::contains
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::array::contains 'haystack' 'needle' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty array name
	run hbl::array::contains '' 'needle'
	assert_failure $HBL_ERR_ARGUMENT

	# undefined array
	run hbl::array::contains 'invalid' 'needle'
	assert_failure $HBL_UNDEFINED

	# non-array
	declare -A array
	run hbl::array::contains 'array' 'needle'
	assert_failure $HBL_ERR_INVALID_ARRAY
	unset array
}

@test 'hbl::array::contains() calls the private function' {
	stub_private
	declare -a haystack
	run hbl::array::_contains 'haystack' 'needle'
	assert_output '_contains: [haystack needle]'
}

@test 'hbl::array::_contains() when the value is not present returns ERROR' {
	declare -a haystack
	run hbl::array::_contains 'haystack' 'needle'
	assert_failure $HBL_ERROR
}

@test 'hbl::array::_contains() when the value is present succeeds' {
	declare -a haystack
	haystack=('needle')
	run hbl::array::_contains 'haystack' 'needle'
	assert_success
}

#
# hbl::array::append()
#
@test 'hbl::array::append() validates its arguments' {
	# insufficient arguments
	run hbl::array::append
	assert_failure $HBL_INVALID_ARGS

	# empty array name
	run hbl::array::append '' 'value'
	assert_failure $HBL_ERR_ARGUMENT

	# undefined array
	run hbl::array::append 'notarray' 'foo'
	assert_failure $HBL_ERR_UNDEFINED

	# non-array
	declare -A array
	run hbl::array::append 'array' 'foo'
	assert_failure $HBL_ERR_INVALID_ARRAY
	unset array
}

@test 'hbl::array::append() calls the private function' {
	stub_private
	declare -a myarray
	run hbl::array::append 'myarray' 'foo'
	assert_output '_append: [myarray foo]'
}

@test 'hbl::array::_append() adds to the array' {
	declare -a myarray
	hbl::array::_append 'myarray' 'foo'
	hbl::array::_contains 'myarray' 'foo'
}

#
# hbl::array::bubble_sort()
#
@test 'hbl::array::bubble_sort() validates its arguments' {
	# insufficient arugments
	run hbl::array::bubble_sort
	assert_failure $HBL_INVALID_ARGS

	# too many arguments
	run hbl::array::bubble_sort 'array' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty array name
	run hbl::array::bubble_sort ''
	assert_failure $HBL_ERR_ARGUMENT

	# undefined array
	run hbl::array::bubble_sort 'notarray'
	assert_failure $HBL_ERR_UNDEFINED

	# non-array
	declare -A array
	run hbl::array::bubble_sort 'array'
	assert_failure $HBL_ERR_INVALID_ARRAY
	unset array
}

@test 'hbl::array::bubble_sort() calls the private function' {
	stub_private
	declare -a myarray=('orange' 'apple' 'lemon' 'banana')
	run hbl::array::bubble_sort 'myarray'
	assert_output '_bubble_sort: [myarray]'
}

@test 'hbl::array::_bubble_sort() properly sorts the array' {
	declare -a myarray=('orange' 'apple' 'lemon' 'banana')
	hbl::array::_bubble_sort 'myarray'
	assert_equal "${myarray[*]}" 'apple banana lemon orange'
}

#
# hbl::array::ensure_array()
#
@test 'hbl::array::ensure_array validates its arguments' {
	# insufficient arguments
	run ensure_array
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run ensure_array 'array' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty array name
	run ensure_array ''
	assert_failure $HBL_ERR_ARGUMENT

	# undefined array
	run ensure_array 'array'
	assert_failure $HBL_ERR_UNDEFINED

	# non-array
	declare -A array
	run ensure_array 'array'
	assert_failure $HBL_ERR_INVALID_ARRAY
}

@test 'hbl::array::ensure_array() with a vaild array succeeds' {
	declare -a array
	run ensure_array 'array'
	assert_success
	refute_output
}
