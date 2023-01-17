setup() {
	load '../test_helper/common'
	common_setup
}

@test 'Array:new succeeds' {
	local array
	run $Array:new array
	assert_success
}

@test 'appending to an array succeeds' {
	local array
	$Array:new array
	run $array:append 'foo'
	assert_success
	refute_output
}

@test 'appending to an array stores the value' {
	local array myarr
	$Array:new array
	$array:append 'foo'
	$array._raw myarr
	assert_array_contains $myarr 'foo'
}

@test 'arrays can be sorted' {
	local array myarr
	declare -a expected=(apple banana lemon orange)
	$Array:new array
	$array:append 'orange' 'apple' 'lemon' 'banana'
	$array:sort
	$array._raw actual
	assert_array_equals $actual expected
}

@test 'arrays are aware of their contents' {
	local array
	$Array:new array
	$array:append 'orange' 'apple' 'lemon' 'banana'
	run $array:contains 'apple'
	assert_success
	refute_output

	run $array:contains 'pear'
	assert_failure $HBL_ERROR
	refute_output
}

@test 'arrays can be converted to bash arrays' {
	local -a array myarr
	local -a expected=('orange' 'apple','lemon' 'banana')
	$Array:new array
	$array:append "${expected[@]}"
	$array:to_array myarr
	assert_array_equals myarr expected
}
