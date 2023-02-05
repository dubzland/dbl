#!/usr/bin/env bats

setup() {
  load '../../test_helper/common'
  common_setup
}

teardown() {
  stub_teardown
}

@test 'Dict#get_size() succeeds' {
  local dict

  $Dict.new dict

  run $dict.get_size mysize

  assert_success
  refute_output
}

@test 'Dict#get_size() returns the proper size' {
  local dict dict_size

  $Dict.new dict
  $dict.set 'color' 'red'
  $dict.get_size dict_size

  assert_equal $dict_size 1
}

@test 'Dict#get() calls the static function' {
  local dict val

  stub __hbl__Dict__static__get_

  $Dict.new dict
  $dict.get 'color' val

  assert_stub_with_args __hbl__Dict__static__get_ _anything_ 'color' val
}

@test 'Dict#get() with insufficient arguments fails' {
  local dict

  stub __hbl__Dict__static__get_

  $Dict.new dict
  run $dict.get

  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Dict#get() with a blank key fails' {
  local dict val

  stub __hbl__Dict__static__get_

  $Dict.new dict
  run $dict.get '' val

  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Dict#get() with an empty target variable fails' {
  local dict

  stub __hbl__Dict__static__get_

  $Dict.new dict
  run $dict.get 'color' ''

  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Dict#get() when the static function returns an error fails' {
  local dict val

  function failure() { return 99; }

  stub __hbl__Dict__static__get_ failure

  $Dict.new dict
  run $dict.get 'color' val

  assert_failure 99
  refute_output
}

@test 'Dict#set() calls the static function' {
  local dict

  stub __hbl__Dict__static__set_

  $Dict.new dict
  $dict.set 'color' 'red'

  assert_stub_with_args __hbl__Dict__static__set_ _anything_ 'color' 'red'
}

@test 'Dict#set() with insufficient arguments fails' {
  local dict

  stub __hbl__Dict__static__set_

  $Dict.new dict
  run $dict.set

  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Dict#set() with a blank key fails' {
  local dict

  stub __hbl__Dict__static__set_

  $Dict.new dict
  run $dict.set '' 'red'

  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Dict#set() when the static function returns an error fails' {
  local dict

  function failure() { return 99; }

  stub __hbl__Dict__static__set_ failure

  $Dict.new dict
  run $dict.set 'color' 'red'

  assert_failure 99
  refute_output
}

@test 'Dict#has_key() calls the static function' {
  local dict

  stub __hbl__Dict__static__has_key_

  $Dict.new dict
  $dict.has_key 'color'

  assert_stub_with_args __hbl__Dict__static__has_key_ _anything_ 'color'
}

@test 'Dict#has_key() with insufficient arguments fails' {
  local dict

  stub __hbl__Dict__static__has_key_

  $Dict.new dict
  run $dict.has_key

  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Dict#has_key() with a blank key fails' {
  local dict

  stub __hbl__Dict__static__has_key_

  $Dict.new dict
  run $dict.has_key ''

  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Dict#has_key() when the static function returns an error fails' {
  local dict

  function failure() { return 99; }

  stub __hbl__Dict__static__has_key_ failure

  $Dict.new dict
  run $dict.has_key 'color'

  assert_failure 99
  refute_output
}

@test 'Dict#to_associative_array() succeeds' {
  local dict
  local -Ag myaarr

  $Dict.new dict
  run $dict.to_associative_array myaarr

  assert_success
  refute_output
}

@test 'Dict#to_associative_array() populates the associative array' {
  local dict
  local -Ag myaarr

  $Dict.new dict
  $dict.set 'foo' 'bar'
  $dict.to_associative_array myaarr

  assert_dict_has_key myaarr 'foo'
  assert_equal "${myaarr[foo]}" 'bar'
}

@test 'Dict#to_associative_array() with insufficient arguments fails' {
  local dict

  $Dict.new dict
  run $dict.to_associative_array

  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Dict#to_associative_array() with an empty target variable fails' {
  local dict

  $Dict.new dict
  run $dict.to_associative_array ''

  assert_failure $__hbl__rc__argument_error
  refute_output
}

# vim: ts=2:sw=2:expandtab
