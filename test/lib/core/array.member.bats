#!/usr/bin/env bats

setup() {
  load '../../test_helper/common'
  common_setup
  declare -ag arr
  $Array.new arr 'one' 'two' 'three'
}

teardown() {
  stub_teardown
}

@test 'Array#at() calls the static function' {
  local myvar

  stub __dbl__Array__static__at_

  $arr.at 0 myvar

  assert_stub_with_args __dbl__Array__static__at_ _anything_ 0 myvar
}

@test 'Array#at() with insufficient arguments fails' {
  stub __dbl__Array__static__at_

  run $arr.at

  assert_failure $__dbl__rc__argument_error
}

@test 'Array#at() with an empty index fails' {
  local myvar

  stub __dbl__Array__static__at_

  run $arr.at '' myvar

  assert_failure $__dbl__rc__argument_error
}

@test 'Array#at() with a non-integer index fails' {
  local myvar

  stub __dbl__Array__static__at_

  run $arr.at 'var' myvar

  assert_failure $__dbl__rc__argument_error
}

@test 'Array#at() with an empty target variable fails' {
  stub __dbl__Array__static__at_

  run $arr.at 0 ''

  assert_failure $__dbl__rc__argument_error
}

@test 'Array#at() when the static function returns an error fails' {
  local myvar

  function failure() { return 99; }

  stub __dbl__Array__static__at_ failure

  run $arr.at 0 myvar

  assert_failure 99
}

@test 'Array#shift() calls the static function' {
  local myvar

  stub __dbl__Array__static__shift_

  $arr.shift myvar

  assert_stub_with_args __dbl__Array__static__shift_ _anything_ myvar
}

@test 'Array#shift() updates the size' {
  local arr_size

  $arr.shift
  $arr.get_size arr_size

  assert_equal $arr_size 2
}

@test 'Array#shift() when the static function returns an error fails' {
  local myvar

  function failure() { return 99; }

  stub __dbl__Array__static__shift_ failure

  run $arr.shift myvar

  assert_failure 99
}

@test 'Array#unshift() calls the static function' {
  stub __dbl__Array__static__unshift_

  $arr.unshift 'four'

  assert_stub_with_args __dbl__Array__static__unshift_ _anything_ 'four'
}

@test 'Array#unshift() updates the size' {
  local arr_size

  $arr.unshift 'four'
  $arr.get_size arr_size

  assert_equal $arr_size 4
}

@test 'Array#unshift() with insufficient arguments fails' {
  stub __dbl__Array__static__unshift_

  run $arr.unshift

  assert_failure $__dbl__rc__argument_error
}

@test 'Array#unshift() when the static function returns an error fails' {
  function failure() { return 99; }

  stub __dbl__Array__static__unshift_ failure

  run $arr.unshift 'four'

  assert_failure 99
}

@test 'Array#push() calls the static function' {
  stub __dbl__Array__static__push_

  $arr.push 'four'

  assert_stub_with_args __dbl__Array__static__push_ _anything_ 'four'
}

@test 'Array#push() updates the size' {
  local arr_size

  $arr.push 'four'
  $arr.get_size arr_size

  assert_equal $arr_size 4
}

@test 'Array#push() with insufficient arguments fails' {
  stub __dbl__Array__static__push_

  run $arr.push

  assert_failure $__dbl__rc__argument_error
}

@test 'Array#push() when the static function returns an error fails' {
  function failure() { return 99; }

  stub __dbl__Array__static__push_ failure

  run $arr.push 'four'

  assert_failure 99
}

@test 'Array#pop() calls the static function' {
  local myvar

  stub __dbl__Array__static__pop_

  $arr.pop myvar

  assert_stub_with_args __dbl__Array__static__pop_ _anything_ myvar
}

@test 'Array#pop() updates the size' {
  local arr_size

  $arr.pop
  $arr.get_size arr_size

  assert_equal $arr_size 2
}

@test 'Array#pop() when the static function returns an error fails' {
  function failure() { return 99; }

  stub __dbl__Array__static__pop_ failure

  run $arr.pop

  assert_failure 99
}

@test 'Array#sort() calls the static function' {
  stub __dbl__Array__static__sort_

  $arr.sort

  assert_stub_with_args __dbl__Array__static__sort_ _anything_
}

@test 'Array#sort() with any arguments fails' {
  stub __dbl__Array__static__sort_

  run $arr.sort ''

  assert_failure $__dbl__rc__argument_error
}

@test 'Array#sort() when the static function returns an error fails' {
  function failure() { return 99; }

  stub __dbl__Array__static__sort_ failure

  run $arr.sort

  assert_failure 99
}

@test 'Array#contains() calls the static function' {
  stub __dbl__Array__static__contains_

  $arr.contains 'two'

  assert_stub_with_args __dbl__Array__static__contains_ _anything_ 'two'
}

@test 'Array#contains() with insufficient arguments fails' {
  stub __dbl__Array__static__contains_

  run $arr.contains

  assert_failure $__dbl__rc__argument_error
}

@test 'Array#contains() when the static function returns an error fails' {
  function failure() { return 99; }

  stub __dbl__Array__static__contains_ failure

  run $arr.contains 'three'

  assert_failure 99
}

@test 'Array#to_array() succeeds' {
  local -a myarr

  run $arr.to_array myarr

  assert_success
  refute_output
}

@test 'Array#to_array() injects the contents into the bash array' {
  local -a expected=('one' 'two' 'three')
  local -a myarr

  $arr.to_array myarr

  assert_array_equals myarr expected
}

@test 'Array#to_array() with insufficient arguments fails' {
  run $arr.to_array

  assert_failure $__dbl__rc__argument_error
}

# vim: ts=2:sw=2:expandtab
