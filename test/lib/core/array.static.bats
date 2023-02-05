#!/usr/bin/env bats

setup() {
  load '../../test_helper/common'
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
  local val
  local -a arr=(one two three)

  run $Array.at arr 0 val

  assert_success
  refute_output
}

@test 'Array.at() returns the item at the specified index' {
  local val
  local -a arr=(one two three)

  $Array.at arr 0 val
  assert_equal "$val" 'one'

  $Array.at arr 1 val
  assert_equal "$val" 'two'
}

@test 'Array.at() with a negative index succeeds' {
  local val
  local -a arr=(one two three)

  run $Array.at arr -2 val

  assert_success
  refute_output
}

@test 'Array.at() with a negative index returns the proper value' {
  local val
  local -a arr=(one two three)

  $Array.at arr -1 val

  assert_equal "$val" 'three'
}

@test 'Array.at() with insufficient arguments fails' {
  local val
  local arr

  run $Array.at arr 0

  assert_failure $__hbl__rc__argument_error
}

@test 'Array.at() with a non-array fails' {
  local val
  local arr

  run $Array.at arr 0 val

  assert_failure $__hbl__rc__argument_error
}

@test 'Array.at() with an empty array fails' {
  local val
  local -a arr=()

  run $Array.at arr 0 val

  assert_failure $__hbl__rc__argument_error
}

@test 'Array.at() with an invalid index fails' {
  local val
  local -a arr=(one two three)

  run $Array.at arr 10 val

  assert_failure $__hbl__rc__argument_error
}

@test 'Array.at() with a non-integer index fails' {
  local val
  local -a arr=(one two three)

  run $Array.at arr 'four' val

  assert_failure $__hbl__rc__argument_error
}

@test 'Array.at() with an empty target variable fails' {
  local val
  local arr

  run $Array.at arr 0 ''

  assert_failure $__hbl__rc__argument_error
}

@test 'Array.shift() succeeds' {
  local -a arr=(one two three)

  run $Array.shift arr myvar

  assert_success
  refute_output
}

@test 'Array.shift() removes the first item' {
  local myvar=""
  local -a arr=(one two three)

  $Array.shift arr myvar
  assert_equal "${arr[0]}" 'two'
}

@test 'Array.shift() returns first item' {
  local myvar=""
  local -a arr=(one two three)

  $Array.shift arr myvar

  assert_equal "$myvar" 'one'
}

@test 'Array.shift() without a return argument succeeds' {
  local -a arr=(one two three)

  run $Array.shift arr

  assert_success
  refute_output
}

@test 'Array.shift() with insufficient arguments fails' {
  local -a arr=(one two three)

  run $Array.shift

  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Array.shift() with a non-array fails' {
  local arr

  run $Array.shift arr

  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Array.shift() with an empty array fails' {
  local myvar=""
  local -a arr=()

  run $Array.shift arr

  assert_failure $__hbl__rc__illegal_instruction
  refute_output
}

@test 'Array.shift() with an empty target variable fails' {
  local -a arr=(one two three)

  run $Array.shift arr ''

  assert_failure $__hbl__rc__argument_error
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

@test 'Array.unshift() with a non-array fails' {
  local arr

  run $Array.unshift arr

  assert_failure $__hbl__rc__argument_error
  refute_output
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

@test 'Array.push() with a non-array fails' {
  local arr

  run $Array.push arr 'four'

  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Array.pop() succeeds' {
  local myvar=""
  local -a arr=(one two three)

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
  local myvar=""
  local -a arr=(one two three)

  $Array.pop arr myvar

  assert_equal "$myvar" 'three'
}

@test 'Array.pop() with insufficient arguments fails' {
  run $Array.pop

  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Array.pop() with a non-array fails' {
  local arr

  run $Array.pop arr

  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Array.pop() with an empty array fails' {
  local -a arr=()

  run $Array.pop arr

  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Array.pop() with an empty target variable fails' {
  local -a arr=(one two three)

  run $Array.pop arr ''

  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Array.sort() succeeds' {
  local -a arr=(one two three)

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
  local -a arr=(one two three)

  $Array.sort arr

  assert_equal "${arr[0]}" one
  assert_equal "${arr[1]}" three
  assert_equal "${arr[2]}" two
}

@test 'Array.sort() with insufficient arguments fails' {
  run $Array.sort

  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Array.sort() with a non-array fails' {
  local arr

  run $Array.sort arr

  assert_failure $__hbl__rc__argument_error
  refute_output
}

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

@test 'Array.contains() with insufficient arguments fails' {
  run $Array.contains

  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Array.contains() with a non-array fails' {
  local arr

  run $Array.contains arr 'two'

  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Array.new() succeeds' {
  local arr

  run $Array.new arr

  assert_success
  refute_output
}

@test 'Array.new() initializes the values' {
  local arr arr_raw

  $Array.new arr one two three
  $arr.read_attribute _raw arr_raw

  local -n arr__ref="$arr_raw"

  assert_equal "${arr__ref[0]}" one
  assert_equal "${arr__ref[1]}" two
  assert_equal "${arr__ref[2]}" three
}

@test 'Array.new() initializes the size' {
  local arr arr_size

  $Array.new arr one two three
  $arr.read_attribute size arr_size

  assert_equal $arr_size 3
}

# vim: ts=2:sw=2:expandtab
