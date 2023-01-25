setup() {
	load '../test_helper/common'
	common_setup
}

teardown() {
	stub_teardown
}

#
# __hbl__Array__static__is_array()
#
@test '__hbl__Array__static__is_array() succeeds' {
	local -a array=()
	run __hbl__Array__static__is_array array
	assert_success
	refute_output
}

@test '__hbl__Array__static__is_array() with insufficient arguments fails' {
	local -a array=()
	run __hbl__Array__static__is_array
	assert_failure $HBL_ERR_ARGUMENT
	refute_output
}

@test '__hbl__Array__static__is_array() with an undefined variable fails' {
	set +u
	run __hbl__Array__static__is_array undefined
	set -u
	assert_failure $HBL_ERR_ARGUMENT
	refute_output
}

@test '__hbl__Array__static__is_array() with a normal variable fails' {
	local defined
	run __hbl__Array__static__is_array defined
	assert_failure $HBL_ERROR
	refute_output
}

@test '__hbl__Array__static__is_array() with an associative array fails' {
	local -A defined=()
	run __hbl__Array__static__is_array defined
	assert_failure $HBL_ERROR
	refute_output
}

#
# __hbl__Array__static__at()
#
@test '__hbl__Array__static__at() succeeds' {
	local -a arr=(foo bar baz)
	run __hbl__Array__static__at arr 0 val
	assert_success
	refute_output
}

@test '__hbl__Array__static__at() returns the item at the specified index' {
	local -a arr=(foo bar baz)
	__hbl__Array__static__at arr 0 myvar
	assert_equal "$myvar" 'foo'
	__hbl__Array__static__at arr 1 myvar
	assert_equal "$myvar" 'bar'
}

@test '__hbl__Array__static__at() with a negative index succeeds' {
	local -a arr=(foo bar baz)
	run __hbl__Array__static__at arr -2 myvar
	assert_success
	refute_output
}

@test '__hbl__Array__static__at() with a negative index returns the proper value' {
	local -a arr=(foo bar baz)
	__hbl__Array__static__at arr -2 myvar
	assert_equal "$myvar" 'bar'
}

@test '__hbl__Array__static__at() with an empty array fails' {
	local -a arr=()
	run __hbl__Array__static__at arr 0 myvar
	assert_failure $HBL_ERR_ARGUMENT
}

@test '__hbl__Array__static__at() with an invalid index fails' {
	local -a arr=(foo bar baz)
	run __hbl__Array__static__at arr 10 myvar
	assert_failure $HBL_ERR_ARGUMENT
}

#
# __hbl__Array__static__shift()
#
@test '__hbl__Array__static__shift() succeeds' {
	local -ag arr=(one two three)
	run __hbl__Array__static__shift arr myvar
	assert_success
	refute_output
}

@test '__hbl__Array__static__shift() removes the first item' {
	local -a arr=(one two three)
	local myvar=""
	__hbl__Array__static__shift arr
	assert_equal "${arr[0]}" 'two'
}

@test '__hbl__Array__static__shift() returns first item' {
	local -a arr=(one two three)
	local myvar=""
	__hbl__Array__static__shift arr myvar
	assert_equal "$myvar" 'one'
}

@test '__hbl__Array__static__shift() without a return argument succeeds' {
	local -a arr=(one two three)
	local myvar=""
	run __hbl__Array__static__shift arr
	assert_success
	refute_output
}

@test '__hbl__Array__static__shift() with insufficient arguments fails' {
	local -a arr=(one two three)
	local myvar=""
	run __hbl__Array__static__shift
	assert_failure $HBL_ERR_ARGUMENT
	refute_output
}

@test '__hbl__Array__static__shift() with an empty array fails' {
	local -a arr=()
	local myvar=""
	run __hbl__Array__static__shift arr
	assert_failure $HBL_ERR_ILLEGAL_INSTRUCTION
}

#
# __hbl__Array__static__unshift()
#
@test '__hbl__Array__static__unshift() succeeds' {
	local -a arr=(one two three)
	run __hbl__Array__static__unshift arr 'zero'
	assert_success
	refute_output
}

@test '__hbl__Array__static__unshift() prepends to the array' {
	local -a arr=(one two three)
	__hbl__Array__static__unshift arr 'zero'
	assert_equal "${arr[0]}" 'zero'
	assert_equal "${arr[1]}" 'one'
}

@test '__hbl__Array__static__unshift() with multiple values succeeds' {
	local -a arr=(one two three)
	run __hbl__Array__static__unshift arr inf zero
	assert_success
	refute_output
}

@test '__hbl__Array__static__unshift() with multiple values prepends them to the array' {
	local -a arr=(one two three)
	__hbl__Array__static__unshift arr inf zero
	assert_equal "${arr[0]}" 'inf'
	assert_equal "${arr[1]}" 'zero'
	assert_equal "${arr[2]}" 'one'
}

#
# __hbl__Array__static__push()
#
@test '__hbl__Array__static__push() succeeds' {
	local -a arr=(one two three)
	run __hbl__Array__static__push arr four
	assert_success
	refute_output
}

@test '__hbl__Array__static__push() stores the value' {
	local -a arr=(one two three)
	__hbl__Array__static__push arr four
	assert_equal "${arr[3]}" 'four'
}

@test '__hbl__Array__static__push() with multiple values succeeds' {
	local -a arr=(one two three)
	run __hbl__Array__static__push arr four five
	assert_success
	refute_output
}

@test '__hbl__Array__static__push() with multiple values appends them all' {
	local -a arr=(one two three)
	__hbl__Array__static__push arr four five
	assert_equal "${arr[3]}" 'four'
	assert_equal "${arr[4]}" 'five'
}

@test '__hbl__Array__static__push() with insufficient arguments fails' {
	local -a arr=()
	run __hbl__Array__static__push
	assert_failure $HBL_ERR_ARGUMENT
	refute_output
}

@test '__hbl__Array__static__push() without a value fails' {
	local -a arr=()
	run __hbl__Array__static__push arr
	assert_failure $HBL_ERR_ARGUMENT
}

#
# __hbl__Array__static__pop()
#
@test '__hbl__Array__static__pop() succeeds' {
	local -a arr=(one two three)
	local myvar=""
	run __hbl__Array__static__pop arr myvar
	assert_success
	refute_output
}

@test '__hbl__Array__static__pop() without a return argument succeeds' {
	local -a arr=(one two three)
	run __hbl__Array__static__pop arr
	assert_success
	refute_output
}

@test '__hbl__Array__static__pop() removes the last item' {
	local -a arr=(one two three)
	__hbl__Array__static__pop arr
	assert_equal "${arr[-1]}" 'two'
}

@test '__hbl__Array__static__pop() returns the item removed' {
	local -a arr=(one two three)
	local myvar=""
	__hbl__Array__static__pop arr myvar
	assert_equal "$myvar" 'three'
}

@test '__hbl__Array__static__pop() with insufficient arguments fails' {
	run __hbl__Array__static__pop
	assert_failure $HBL_ERR_ARGUMENT
	refute_output
}

@test '__hbl__Array__static__pop() with an empty array fails' {
	local -a arr=()
	run __hbl__Array__static__pop arr
	assert_failure $HBL_ERR_ARGUMENT
	refute_output
}

@test '__hbl__Array__static__sort() succeeds' {
	local -a arr=(orange apple lemon banana)
	run __hbl__Array__static__sort arr
	assert_success
	refute_output
}

@test '__hbl__Array__static__sort() with an empty array succeeds' {
	local -a arr=()
	run __hbl__Array__static__sort arr
	assert_success
	refute_output
}

@test '__hbl__Array__static__sort() sorts the items' {
	local -a arr=(orange apple lemon banana)
	__hbl__Array__static__sort arr
	assert_equal "${arr[0]}" apple
	assert_equal "${arr[1]}" banana
	assert_equal "${arr[2]}" lemon
	assert_equal "${arr[3]}" orange
}

@test '__hbl__Array__static__sort() with insufficient arguments fails' {
	run __hbl__Array__static__sort
	assert_failure $HBL_ERR_ARGUMENT
	refute_output
}

#
# __hbl__Array__static__contains()
#
@test '__hbl__Array__static__contains() succeeds' {
	local -a arr=(one two three)
	run __hbl__Array__static__contains arr 'two'
	assert_success
	refute_output
}

@test '__hbl__Array__static__contains() for a missing value fails' {
	local -a arr=(one two three)
	run __hbl__Array__static__contains arr 'four'
	assert_failure $HBL_ERROR
	refute_output
}

@test '__hbl__Array__static__congtains() with insufficient arguments fails' {
	run __hbl__Array__static__contains
	assert_failure $HBL_ERR_ARGUMENT
	refute_output
}

#
# Array class methods
#

@test 'Array.at() calls the static function' {
	stub __hbl__Array__static__at
	$Array.at arr 0 myvar
	assert_stub_with_args __hbl__Array__static__at arr 0 myvar
}

@test 'Array.shift() calls the static function' {
	stub __hbl__Array__static__shift
	$Array.shift arr myvar
	assert_stub_with_args __hbl__Array__static__shift arr myvar
}

@test 'Array.unshift() calls the static function' {
	stub __hbl__Array__static__unshift
	$Array.unshift arr 'val'
	assert_stub_with_args __hbl__Array__static__unshift arr 'val'
}

@test 'Array.push() calls the static function' {
	stub __hbl__Array__static__push
	$Array.push arr 'foo'
	assert_stub_with_args __hbl__Array__static__push arr 'foo'
}

@test 'Array.pop() calls the static function' {
	stub __hbl__Array__static__pop
	$Array.pop arr myvar
	assert_stub_with_args __hbl__Array__static__pop arr myvar
}

@test 'Array.sort() calls the static function' {
	stub __hbl__Array__static__sort
	$Array.sort arr
	assert_stub_with_args __hbl__Array__static__sort arr
}

@test 'Array.contains() calls the static function' {
	stub __hbl__Array__static__contains
	$Array.contains arr 'needle'
	assert_stub_with_args __hbl__Array__static__contains arr 'needle'
}

#
# Array instance methods
#
@test 'Array#at() calls the static function' {
	local -a array
	stub __hbl__Array__static__at
	$Array.new array 'foo' 'bar' && local -n __ref="$array"
	${!array}.at 0 myvar
	assert_stub_with_args __hbl__Array__static__at "${__ref[_raw]}" 0 myvar
}

@test 'Array#shift() calls the static function' {
	local -a array
	stub __hbl__Array__static__shift
	$Array.new array 'foo' 'bar' && local -n __ref="$array"
	${!array}.shift myvar
	assert_stub_with_args __hbl__Array__static__shift "${__ref[_raw]}" myvar
}

@test 'Array#unshift() calls the static function' {
	local -a array
	stub __hbl__Array__static__unshift
	$Array.new array 'foo' 'bar' && local -n __ref="$array"
	${!array}.unshift 'baz'
	assert_stub_with_args __hbl__Array__static__unshift "${__ref[_raw]}" 'baz'
}

@test 'Array#push() calls the static function' {
	local -a array
	stub __hbl__Array__static__push
	$Array.new array 'foo' 'bar' && local -n __ref="$array"
	${!array}.push 'baz'
	assert_stub_with_args __hbl__Array__static__push "${__ref[_raw]}" 'baz'
}

@test 'Array#pop() calls the static function' {
	local -a array
	stub __hbl__Array__static__pop
	$Array.new array 'foo' 'bar' && local -n __ref="$array"
	${!array}.pop myvar
	assert_stub_with_args __hbl__Array__static__pop "${__ref[_raw]}" myvar
}

@test 'Array#sort() calls the static function' {
	local -a array
	stub __hbl__Array__static__sort
	$Array.new array 'foo' 'bar' && local -n __ref="$array"
	${!array}.sort
	assert_stub_with_args __hbl__Array__static__sort "${__ref[_raw]}"
}

@test 'Array#contains() calls the static function' {
	local -a array
	stub __hbl__Array__static__contains
	$Array.new array 'foo' 'bar' && local -n __ref="$array"
	${!array}.contains 'needle'
	assert_stub_with_args __hbl__Array__static__contains "${__ref[_raw]}" 'needle'
}

@test 'Array#to_array() succeeds' {
	local -a expected=('orange' 'apple' 'lemon' 'banana')
	$Array.new array "${expected[@]}"
	run ${!array}.to_array myarr
	assert_success
	refute_output
}

@test 'Array#to_array() injects the contents into the bash array' {
	local -a expected=('orange' 'apple' 'lemon' 'banana')
	$Array.new array "${expected[@]}"
	${!array}.to_array myarr
	assert_array_equals myarr expected
}
