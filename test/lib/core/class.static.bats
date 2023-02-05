#!/usr/bin/env bats

setup() {
  load '../../test_helper/common'
  common_setup
}

teardown() {
  stub_teardown
}

dummy_id() {
  local -n id__ref="$2"
  id__ref="__hbl__${1}__0"
}

@test 'Class.define() succeeds' {
  run $Class.define Tester
  assert_success
  refute_output
}

@test 'Class.define() creates the global object' {
  local obj_id
  $Class.define Tester
  assert_dict Tester
}

@test 'Class.define() assigns the __class__' {
  $Class.define Tester
  assert_equal "${Tester[__class__]}" Class
}

@test 'Class.define() assigns the __superclass__' {
  $Class.define Tester
  assert_equal "${Tester[__superclass__]}" Object
}

@test 'Class.define() accepts a class definition' {
  local -A classdef
  classdef=(
    [prototype]='_prototype'
    [static_methods]='_static_methods'
    [static_references]='_static_references'
    [references]='_references'
  )
  $Class.define Tester classdef
  assert_equal "${Tester[__prototype__]}" _prototype
  assert_equal "${Tester[__static_methods__]}" _static_methods
  assert_equal "${Tester[__static_references__]}" _static_references
  assert_equal "${Tester[__references__]}" _references
}

@test 'Class.new() succeeds' {
  $Class.define Tester
  run $Tester.new tester
  assert_success
  refute_output
}

@test 'Class.new() returns the dispatcher' {
  $Class.define Tester
  stub __hbl__Object__static__generate_id dummy_id
  $Tester.new tester
  assert_equal "$tester" "__hbl__Object__dispatch_ __hbl__Tester__0 "
}

@test 'Class.new() enables prototype methods' {
  function Tester__test() { printf "Tester test\n"; }
  $Class.define Tester
  $Tester.prototype_method test Tester__test
  $Tester.new tester
  run $tester.test
  assert_success
  assert_output 'Tester test'
}

@test 'Class.new() enables prototype attributes' {
  local color
  $Class.define Tester
  $Tester.prototype_attribute color
  $Tester.new tester
  $tester.set_color blue
  $tester.get_color color
  assert_equal "$color" blue
}

# vim: ts=2:sw=2:expandtab
