setup() {
	load '../test_helper/common'
	common_setup
}

#
# Array:is_array()
#
@test 'Array.is_array() with an undefined variable fails' {
	run $Array.is_array 'UNDEFINED'
	assert_failure $HBL_ERROR
	refute_output
}

@test 'Array.is_array() with a normal variable fails' {
	declare DEFINED
	run $Array.is_array 'DEFINED'
	assert_failure $HBL_ERROR
	refute_output
}

@test 'Array.is_array() with an associative array fails' {
	declare -A DEFINED
	run $Array.is_array 'DEFINED'
	assert_failure $HBL_ERROR
	refute_output
}

@test 'Array.is_array() with a normal array succeeds' {
	declare -a DEFINED
	run $Array.is_array 'DEFINED'
	assert_success
	refute_output
}

@test 'Array.new() succeeds' {
	local array
	run $Array.new array
	assert_success
}

@test 'array.append() succeeds' {
	local array
	$Array.new array
	run ${!array}.append 'foo'
	assert_success
	refute_output
}

@test 'array.append() stores the value' {
	TRACE=1
	local array myarr
	$Array.new array
	${!array}.append 'foo'
	${!array}.get__raw myarr
	assert_array_contains "$myarr" 'foo'
}

@test 'array.sort() succeeds' {
	$Array.new array
	${!array}.append 'orange' 'apple' 'lemon' 'banana'
	run ${!array}.sort
	assert_success
	refute_output
}

@test 'array.sort() sorts the items' {
	local array myarr
	declare -a expected=(apple banana lemon orange)
	$Array.new array
	${!array}.append 'orange' 'apple' 'lemon' 'banana'
	${!array}.sort
	${!array}.get__raw actual
	assert_array_equals $actual expected
}

@test 'array.contains() succeeds' {
	local array
	$Array.new array
	${!array}.append 'orange' 'apple' 'lemon' 'banana'
	run ${!array}.contains 'apple'
	assert_success
	refute_output
}

@test 'array.contains() for a missing value fails' {
	local array
	$Array.new array
	${!array}.append 'orange' 'apple' 'lemon' 'banana'
	run ${!array}.contains 'pear'
	assert_failure $HBL_ERROR
	refute_output
}

@test 'array.to_array() succeeds' {
	local array myarr
	local -a expected=('orange' 'apple','lemon' 'banana')
	$Array.new array
	${!array}.append "${expected[@]}"
	run ${!array}.to_array myarr
	assert_success
	refute_output
}

@test 'array.to_array() injects the contents into the bash array' {
	local -a array myarr
	local -a expected=('orange' 'apple','lemon' 'banana')
	$Array.new array
	${!array}.append "${expected[@]}"
	${!array}.to_array myarr
	assert_array_equals myarr expected
}
