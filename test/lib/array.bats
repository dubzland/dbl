#!/usr/bin/env bats

setup() {
  load '../test_helper/common'
  common_setup
}

teardown() {
  stub_teardown
}

@test 'Array.is_array() succeeds' {
  local -a array=()
  run $Array.is_array array
  assert_success
  refute_output
}

@test 'Array.is_array() with insufficient arguments fails' {
  local -a array=()
  run $Array.is_array
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Array.is_array() with an undefined variable fails' {
  set +u
  run $Array.is_array undefined
  set -u
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Array.is_array() with a normal variable fails' {
  local defined
  run $Array.is_array defined
  assert_failure $__hbl__rc__error
  refute_output
}

@test 'Array.is_array() with an associative array fails' {
  local -A defined=()
  run $Array.is_array defined
  assert_failure $__hbl__rc__error
  refute_output
}

@test 'Array.at() succeeds' {
  local -a arr=(foo bar baz)
  run $Array.at arr 0 val
  assert_success
  refute_output
}

@test 'Array.at() returns the item at the specified index' {
  local -a arr=(foo bar baz)
  $Array.at arr 0 myvar
  assert_equal "$myvar" 'foo'
  $Array.at arr 1 myvar
  assert_equal "$myvar" 'bar'
}

@test 'Array.at() with a negative index succeeds' {
  local -a arr=(foo bar baz)
  run $Array.at arr -2 myvar
  assert_success
  refute_output
}

@test 'Array.at() with a negative index returns the proper value' {
  local -a arr=(foo bar baz)
  $Array.at arr -2 myvar
  assert_equal "$myvar" 'bar'
}

@test 'Array.at() with an empty array fails' {
  local -a arr=()
  run $Array.at arr 0 myvar
  assert_failure $__hbl__rc__argument_error
}

@test 'Array.at() with an invalid index fails' {
  local -a arr=(foo bar baz)
  run $Array.at arr 10 myvar
  assert_failure $__hbl__rc__argument_error
}

@test 'Array.shift() succeeds' {
  local -ag arr=(one two three)
  run $Array.shift arr myvar
  assert_success
  refute_output
}

@test 'Array.shift() removes the first item' {
  local -a arr=(one two three)
  local myvar=""
  $Array.shift arr
  assert_equal "${arr[0]}" 'two'
}

@test 'Array.shift() returns first item' {
  local -a arr=(one two three)
  local myvar=""
  $Array.shift arr myvar
  assert_equal "$myvar" 'one'
}

@test 'Array.shift() without a return argument succeeds' {
  local -a arr=(one two three)
  local myvar=""
  run $Array.shift arr
  assert_success
  refute_output
}

@test 'Array.shift() with insufficient arguments fails' {
  local -a arr=(one two three)
  local myvar=""
  run $Array.shift
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Array.shift() with an empty array fails' {
  local -a arr=()
  local myvar=""
  run $Array.shift arr
  assert_failure $__hbl__rc__illegal_instruction
}

@test 'Array.unshift() succeeds' {
  local -a arr=(one two three)
  run $Array.unshift arr 'zero'
  assert_success
  refute_output
}

@test 'Array.unshift() prepends to the array' {
  local -a arr=(one two three)
  $Array.unshift arr 'zero'
  assert_equal "${arr[0]}" 'zero'
  assert_equal "${arr[1]}" 'one'
}

@test 'Array.unshift() with multiple values succeeds' {
  local -a arr=(one two three)
  run $Array.unshift arr inf zero
  assert_success
  refute_output
}

@test 'Array.unshift() with multiple values prepends them to the array' {
  local -a arr=(one two three)
  $Array.unshift arr inf zero
  assert_equal "${arr[0]}" 'inf'
  assert_equal "${arr[1]}" 'zero'
  assert_equal "${arr[2]}" 'one'
}

@test 'Array.push() succeeds' {
  local -a arr=(one two three)
  run $Array.push arr four
  assert_success
  refute_output
}

@test 'Array.push() stores the value' {
  local -a arr=(one two three)
  $Array.push arr four
  assert_equal "${arr[3]}" 'four'
}

@test 'Array.push() with multiple values succeeds' {
  local -a arr=(one two three)
  run $Array.push arr four five
  assert_success
  refute_output
}

@test 'Array.push() with multiple values appends them all' {
  local -a arr=(one two three)
  $Array.push arr four five
  assert_equal "${arr[3]}" 'four'
  assert_equal "${arr[4]}" 'five'
}

@test 'Array.push() with insufficient arguments fails' {
  local -a arr=()
  run $Array.push
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Array.push() without a value fails' {
  local -a arr=()
  run $Array.push arr
  assert_failure $__hbl__rc__argument_error
}

@test 'Array.pop() succeeds' {
  local -a arr=(one two three)
  local myvar=""
  run $Array.pop arr myvar
  assert_success
  refute_output
}

@test 'Array.pop() without a return argument succeeds' {
  local -a arr=(one two three)
  run $Array.pop arr
  assert_success
  refute_output
}

@test 'Array.pop() removes the last item' {
  local -a arr=(one two three)
  $Array.pop arr
  assert_equal "${arr[-1]}" 'two'
}

@test 'Array.pop() returns the item removed' {
  local -a arr=(one two three)
  local myvar=""
  $Array.pop arr myvar
  assert_equal "$myvar" 'three'
}

@test 'Array.pop() with insufficient arguments fails' {
  run $Array.pop
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Array.pop() with an empty array fails' {
  local -a arr=()
  run $Array.pop arr
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Array.sort() succeeds' {
  local -a arr=(orange apple lemon banana)
  run $Array.sort arr
  assert_success
  refute_output
}

@test 'Array.sort() with an empty array succeeds' {
  local -a arr=()
  run $Array.sort arr
  assert_success
  refute_output
}

@test 'Array.sort() sorts the items' {
  local -a arr=(orange apple lemon banana)
  $Array.sort arr
  assert_equal "${arr[0]}" apple
  assert_equal "${arr[1]}" banana
  assert_equal "${arr[2]}" lemon
  assert_equal "${arr[3]}" orange
}

@test 'Array.sort() with insufficient arguments fails' {
  run $Array.sort
  assert_failure $__hbl__rc__argument_error
  refute_output
}

#
# Array.contains()
#
@test 'Array.contains() succeeds' {
  local -a arr=(one two three)
  run $Array.contains arr 'two'
  assert_success
  refute_output
}

@test 'Array.contains() for a missing value fails' {
  local -a arr=(one two three)
  run $Array.contains arr 'four'
  assert_failure $__hbl__rc__error
  refute_output
}

@test 'Array.congtains() with insufficient arguments fails' {
  run $Array.contains
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Array#at() calls the static function' {
  local -a arra
  stub __hbl__Array__static__at
  $Array.new array 'foo' 'bar'
  $array.at 0 myvar
  assert_stub_with_args __hbl__Array__static__at _anything_ 0 myvar
}

 @test 'Array#shift() calls the static function' {
   local -a array
   stub __hbl__Array__static__shift
   $Array.new array 'foo' 'bar'
   $array.shift myvar
   assert_stub_with_args __hbl__Array__static__shift _anything_ myvar
 }

 @test 'Array#unshift() calls the static function' {
   local -a array
   stub __hbl__Array__static__unshift
   $Array.new array 'foo' 'bar'
   $array.unshift 'baz'
   assert_stub_with_args __hbl__Array__static__unshift _anything_ 'baz'
 }

 @test 'Array#push() calls the static function' {
   local -a array
   stub __hbl__Array__static__push
   $Array.new array 'foo' 'bar'
   $array.push 'baz'
   assert_stub_with_args __hbl__Array__static__push _anything_ 'baz'
 }

 @test 'Array#pop() calls the static function' {
   local -a array
   stub __hbl__Array__static__pop
   $Array.new array 'foo' 'bar'
   $array.pop myvar
   assert_stub_with_args __hbl__Array__static__pop _anything_ myvar
 }

 @test 'Array#sort() calls the static function' {
   local -a array
   stub __hbl__Array__static__sort
   $Array.new array 'foo' 'bar'
   $array.sort
   assert_stub_with_args __hbl__Array__static__sort _anything_
 }

 @test 'Array#contains() calls the static function' {
   local -a array
   stub __hbl__Array__static__contains
   $Array.new array 'foo' 'bar'
   $array.contains 'needle'
   assert_stub_with_args __hbl__Array__static__contains _anything_ 'needle'
 }

@test 'Array#to_array() succeeds' {
  local -a expected=('orange' 'apple' 'lemon' 'banana')
  $Array.new array "${expected[@]}"
  run $array.to_array myarr
  assert_success
  refute_output
}

@test 'Array#to_array() injects the contents into the bash array' {
  local -a expected=('orange' 'apple' 'lemon' 'banana')
  $Array.new array "${expected[@]}"
  $array.to_array myarr
  assert_array_equals myarr expected
}

# vim: ts=2:sw=2:expandtab
