#!/usr/bin/env bats

setup() {
  load '../../test_helper/common'
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

# vim: ts=2:sw=2:expandtab
