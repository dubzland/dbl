#!/usr/bin/env bats

setup() {
  load '../test_helper/common'
  common_setup
}

teardown() {
  stub_teardown
}

function obj__test() { return 0; }

@test 'Object.generate_id() succeeds' {
  local obj_id
  run $Object.generate_id Object obj_id
  assert_success
  refute_output
}

@test 'Object.generate_id() generates an id' {
  local obj_id
  $Object.generate_id Object obj_id
  [[ "$obj_id" =~ ^__hbl__Object__[0-9] ]]
}

@test 'Object.generate_id() generates unique ids' {
  local obj_id1 obj_id2
  $Object.generate_id Object obj_id1
  $Object.generate_id Object obj_id2
  assert_not_equal "$obj_id1" "$obj_id2"
}

@test 'Object#inspect() succeeds' {
  local tester
  $Object.extend Tester
  $Tester.new tester
  run $tester.inspect
  assert_success
}

@test 'Object#inspect() displays attributes' {
  local tester
  $Object.extend Tester
  $Tester.prototype_attribute color
  $Tester.prototype_attribute size
  $Tester.new tester
  $tester.set_color 'red'
  $tester.set_size 'large'
  run $tester.inspect
  assert_output "<__hbl__Tester__0 color='red' size='large'>"
}

@test 'Object#read_attribute() succeeds' {
  local tester val
  $Object.extend Tester
  $Tester.new tester
  run $tester.read_attribute 'color' val
  assert_success
  refute_output
}

@test 'Object#read_attribute() retrieves the value' {
  local tester tester_id val
  $Object.extend Tester
  $Tester.new tester
  $tester._get_id_ tester_id
  local -n tester__ref="$tester_id"
  tester__ref[color]='red'
  $tester.read_attribute 'color' val
  assert_equal "$val" 'red'
}

@test 'Object#read_attribute() with insufficient arguments fails' {
  local tester
  $Object.extend Tester
  $Tester.new tester
  run $tester.read_attribute
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Object#write_attribute() succeeds' {
  local tester val
  $Object.extend Tester
  $Tester.new tester
  run $tester.write_attribute 'color' 'red'
  assert_success
  refute_output
}

@test 'Object#write_attribute() sets the value' {
  local tester tester_id val
  $Object.extend Tester
  $Tester.new tester
  $tester._get_id_ tester_id
  local -n tester__ref="$tester_id"
  $tester.write_attribute 'color' 'red'
  assert_equal "${tester__ref[color]}" 'red'
}

@test 'Object#write_attribute() with insufficient arguments fails' {
  local tester
  $Object.extend Tester
  $Tester.new tester
  run $tester.write_attribute
  assert_failure $__hbl__rc__argument_error
}

@test 'Object#has_method() for a valid method succeeds' {
  function Tester__test() { return 0; }
  local tester
  $Object.extend Tester
  $Tester.new tester
  $tester.add_method test Tester__test
  run $tester.has_method test
  assert_success
  refute_output
}

@test 'Object#has_method() for an invalid method fails' {
  local tester
  $Object.extend Tester
  $Tester.new tester
  run $tester.has_method test
  assert_failure
  refute_output
}

@test 'Object#has_method() with insufficient arguments fails' {
  local tester
  $Object.extend Tester
  $Tester.new tester
  run $tester.has_method
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Object#add_method() succeeds' {
  function Tester__test() { return 0; }
  local tester
  $Object.extend Tester
  $Tester.new tester
  run $tester.add_method test Tester__test
  assert_success
  refute_output
}

@test 'Object#add_method() adds the method' {
  function Tester__test() { printf "Tester test\n"; }
  local tester
  $Object.extend Tester
  $Tester.new tester
  $tester.add_method test Tester__test
  run $tester.test
  assert_success
  assert_output 'Tester test'
}

@test 'Object#add_method() with insufficient arguments fails' {
  local tester
  $Object.extend Tester
  $Tester.new tester
  run $tester.add_method
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Object#add_method() with a non-function argument fails' {
  local tester
  $Object.extend Tester
  $Tester.new tester
  run $tester.add_method test Tester__undefined
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Object#add_getter() succeeds' {
  local tester
  $Object.extend Tester
  $Tester.new tester
  run $tester.add_getter color
  assert_success
  refute_output
}

@test 'Object#add_getter() adds a getter' {
  local tester val
  $Object.extend Tester
  $Tester.new tester
  $tester.add_getter color
  $tester._get_id_ tester_id
  local -n tester__ref="$tester_id"
  tester__ref[color]='red'
  $tester.get_color val
  assert_equal "$val" 'red'
}

@test 'Object#add_getter() with insufficient arguments fails' {
  local tester
  $Object.extend Tester
  $Tester.new tester
  run $tester.add_getter
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Object#add_setter() succeeds' {
  local tester
  $Object.extend Tester
  $Tester.new tester
  run $tester.add_setter color
  assert_success
  refute_output
}

@test 'Object#add_setter() adds a setter' {
  local tester
  $Object.extend Tester
  $Tester.new tester
  $tester.add_setter color
  $tester._get_id_ tester_id
  local -n tester__ref="$tester_id"
  $tester.set_color 'red'
  assert_equal "${tester__ref[color]}" 'red'
}

@test 'Object#add_setter() with insufficient arguments fails' {
  local tester
  $Object.extend Tester
  $Tester.new tester
  run $tester.add_setter
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Object#add_reference() succeeds' {
  local tester
  $Object.extend Tester
  $Tester.new tester
  run $tester.add_reference child
  assert_success
  refute_output
}

@test 'Object#add_reference() adds a reference accessor' {
  stub __hbl__Object__delegate_to_reference_
  local tester
  $Object.extend Tester
  $Tester.new tester
  $tester.add_reference child
  $tester.child.foo
  assert_stub_with_args __hbl__Object__delegate_to_reference_ child '.foo'
}

@test 'Object#add_reference() with insufficient arguments fails' {
  local tester
  $Object.extend Tester
  $Tester.new tester
  run $tester.add_reference
  assert_failure $__hbl__rc__argument_error
  refute_output
}

# vim: ts=2:sw=2:expandtab
