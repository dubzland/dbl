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
	run $Array.new array
	assert_success
}

@test 'Array#at() succeeds' {
	$Array.new array 'foo' 'bar'
	run ${!array}.at 0 myvar
	assert_success
	refute_output
}

@test 'Array#at() returns the item at the specified index' {
	$Array.new array 'foo' 'bar'
	${!array}.at 0 myvar
	assert_equal "$myvar" 'foo'
	${!array}.at 1 myvar
	assert_equal "$myvar" 'bar'
}

@test 'Array#at() with a negative index succeeds' {
	$Array.new array
	for i in {1..10}; do
		${!array}.push "val$i"
	done
	run ${!array}.at -2 myvar
	assert_success
	refute_output
}

@test 'Array#at() with a negative index returns the proper value' {
	$Array.new array
	for i in {1..10}; do
		${!array}.push "val$i"
	done
	${!array}.at -2 myvar
	assert_equal "$myvar" 'val9'
}

@test 'Array#at() with an empty array fails' {
	$Array.new array
	run ${!array}.at 0 myvar
	assert_failure $HBL_ERR_ARGUMENT
}

@test 'Array#at() with an invalid index fails' {
	$Array.new array
	for i in {1..10}; do
		${!array}.push "val$i"
	done
	run ${!array}.at 10 myvar
	assert_failure $HBL_ERR_ARGUMENT
}

@test 'Array#shift() succeeds' {
	$Array.new array 'foo' 'bar'
	run ${!array}.shift myvar
	assert_success
	refute_output
}

@test 'Array#shift() removes the first item' {
	$Array.new array 'foo' 'bar'
	${!array}.shift
	${!array}.at 0 myvar
	assert_equal "$myvar" 'bar'
}

@test 'Array#shift() returns first item' {
	$Array.new array 'foo' 'bar'
	${!array}.shift myvar
	assert_equal "$myvar" 'foo'
}

@test 'Array#shift() without an argument succeeds' {
	$Array.new array 'foo' 'bar'
	run ${!array}.shift
	assert_success
	refute_output
}

@test 'Array#shift() with an empty array fails' {
	$Array.new array
	run ${!array}.shift
	assert_failure $HBL_ERR_ILLEGAL_INSTRUCTION
}

@test 'Array#unshift() succeeds' {
	$Array.new array 'foo' 'bar'
	run ${!array}.unshift 'baz'
	assert_success
	refute_output
}

@test 'Array#unshift() prepends to the array' {
	$Array.new array 'foo' 'bar'
	${!array}.unshift 'baz'
	${!array}.at 0 myvar
	assert_equal "$myvar" 'baz'
}

@test 'Array#unshift() with multiple values succeeds' {
	$Array.new array 'foo' 'bar'
	run ${!array}.unshift 'baz' 'biz'
	assert_success
	refute_output
}

@test 'Array#unshift() with multiple values prepends them to the array' {
	local -a expected=(baz biz foo bar)
	$Array.new array 'foo' 'bar'
	${!array}.unshift 'baz' 'biz'
	${!array}.to_array myvar
	assert_array_equals myvar expected
}

@test 'Array#push() succeeds' {
	$Array.new array
	run ${!array}.push 'foo'
	assert_success
	refute_output
}

@test 'Array#push() stores the value' {
	$Array.new array
	${!array}.push 'foo'
	${!array}.get_raw myarr
	assert_array_contains "$myarr" 'foo'
}

@test 'Array#pop() succeeds' {
	$Array.new array 'foo' 'bar'
	run ${!array}.pop myvar
	assert_success
	refute_output
}

@test 'Array#pop() returns the last value' {
	$Array.new array 'foo' 'bar'
	${!array}.pop myvar
	assert_equal "$myvar" 'bar'
}

@test 'Array#pop() works without an argument' {
	$Array.new array 'foo' 'bar'
	run ${!array}.pop
	assert_success
	refute_output
}

@test 'Array#pop() removes the last value' {
	$Array.new array 'foo' 'bar'
	${!array}.pop
	local -n arr__ref="${array}"
	local -n raw__ref="${arr__ref[_raw]}"
	assert_equal ${#raw__ref[@]} 1
	assert_equal "${raw__ref[0]}" 'foo'
}

@test 'Array#sort() succeeds' {
	$Array.new array 'orange' 'apple' 'lemon' 'banana'
	run ${!array}.sort
	assert_success
	refute_output
}

@test 'Array#sort() sorts the items' {
	declare -a expected=(apple banana lemon orange)
	$Array.new array 'orange' 'apple' 'lemon' 'banana'
	${!array}.sort
	${!array}.get_raw actual
	assert_array_equals $actual expected
}

@test 'Array#contains() succeeds' {
	$Array.new array 'orange' 'apple' 'lemon' 'banana'
	run ${!array}.contains 'apple'
	assert_success
	refute_output
}

@test 'Array#contains() for a missing value fails' {
	$Array.new array 'orange' 'apple' 'lemon' 'banana'
	run ${!array}.contains 'pear'
	assert_failure $HBL_ERROR
	refute_output
}

@test 'Array#to_array() succeeds' {
	local -a expected=('orange' 'apple','lemon' 'banana')
	$Array.new array "${expected[@]}"
	run ${!array}.to_array myarr
	assert_success
	refute_output
}

@test 'Array#to_array() injects the contents into the bash array' {
	local -a expected=('orange' 'apple','lemon' 'banana')
	$Array.new array "${expected[@]}"
	${!array}.to_array myarr
	assert_array_equals myarr expected
}
