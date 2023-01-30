#!/usr/bin/env bats

setup() {
  load '../test_helper/common'
  common_setup
}

@test 'Dict.new() succeeds' {
  run $Dict.new dict
  assert_success
  refute_output
}

@test 'Dict#get_size() succeeds' {
  $Dict.new dict
  run $dict.get_size mysize
  assert_success
  refute_output
}

@test 'Dict#set()  succeeds' {
  $Dict.new dict
  run $dict.set 'foo' 'bar'
  assert_success
  refute_output
}

@test 'Dict#set() stores the value' {
  local -A mydict
  $Dict.new dict
  $dict.set 'foo' 'bar'
  $dict.to_associative_array mydict
  assert_dict mydict
  assert_dict_has_key mydict foo
  assert_equal "${mydict[foo]}" 'bar'
}

@test 'Dict#get() succeeds' {
  local dict
  $Dict.new dict
  $dict.set 'foo' 'bar'
  run $dict.get 'foo' val
  assert_success
  refute_output
}

@test 'Dict#get() returns the value' {
  local dict myval
  $Dict.new dict
  $dict.set 'foo' 'bar'
  $dict.get 'foo' myval
  assert_equal "$myval" 'bar'
}

@test 'Dict#has_key() succeeds' {
  local dict
  $Dict.new dict
  $dict.set 'foo' 'bar'
  run $dict.has_key 'foo'
  assert_success
  refute_output
}

@test 'Dict#has_key() for a missing value fails' {
  local dict
  $Dict.new dict
  run $dict.has_key 'foo'
  assert_failure $__hbl__rc__error
  refute_output
}

@test 'Dict#to_associative_array() succeeds' {
  local dict
  declare -Ag myaarr
  $Dict.new dict
  run $dict.to_associative_array myaarr
  assert_success
  refute_output
}

@test 'Dict#to_associative_array() populates the associative array' {
  local dict
  declare -Ag myaarr
  $Dict.new dict
  $dict.set 'foo' 'bar'
  $dict.to_associative_array myaarr
  assert_dict_has_key myaarr 'foo'
  assert_equal "${myaarr[foo]}" 'bar'
}

# vim: ts=2:sw=2:expandtab
