#!/usr/bin/env bats

setup() {
  load '../test_helper/common'
  common_setup
}

teardown() {
  stub_teardown
}

function obj__test() { return 0; }

@test '__hbl__Object__static__generate_id() succeeds' {
  local obj_id
  run __hbl__Object__static__generate_id Object obj_id
  assert_success
  refute_output
}

@test '__hbl__Object__static__generate_id() generates an id' {
  local obj_id
  __hbl__Object__static__generate_id Object obj_id
  [[ "$obj_id" =~ ^__hbl__Object__[0-9] ]]
}

@test '__hbl__Object__static__generate_id() generates unique ids' {
  local obj_id1 obj_id2
  __hbl__Object__static__generate_id Object obj_id1
  __hbl__Object__static__generate_id Object obj_id2
  assert_not_equal "$obj_id1" "$obj_id2"
}

@test '__hbl__Object__inspect() succeeds' {
  local -A obj=()
  run __hbl__Object__inspect obj
  assert_success
}

@test '__hbl__Object__inspect() displays attributes' {
  local -A obj=()
  obj[_attrA]='red'
  obj[_attrB]='blue'
  run __hbl__Object__inspect obj
  assert_output "<obj _attrB='blue' _attrA='red'>"
}

@test '__hbl__Object__has_method() for a valid method succeeds' {
  local -A obj=([__methods__]='obj__methods')
  local -A obj__methods=([foo]=obj__foo)
  run __hbl__Object__has_method obj foo
  assert_success
  refute_output
}

@test '__hbl__Object__has_method() for an invalid method fails' {
  local -A obj=([__methods__]='obj__methods')
  local -A obj__methods=()
  run __hbl__Object__has_method obj foo
  assert_failure
  refute_output
}

@test '__hbl__Object__has_method() with insufficient arguments fails' {
  run __hbl__Object__has_method
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test '__hbl__Object__has_method() with a non-function argument fails' {
  local -A obj=([__id__]='obj')
  run __hbl__Object__has_method obj test obj__non_function
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test '__hbl__Object__add_method() succeeds' {
  local -A obj=([__id__]='obj')
  run __hbl__Object__add_method obj test obj__test
  assert_success
  refute_output
}

@test '__hbl__Object__add_method() adds the method' {
  local -A obj=([__id__]='obj')
  __hbl__Object__add_method obj test obj__test
  local -n methods="obj__methods"
  assert_equal "${methods[test]}" obj__test
}

@test '__hbl__Object__add_method() with insufficient arguments fails' {
  local -A obj=([__id__]='obj')
  run __hbl__Object__add_method obj
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test '__hbl__Object__add_method() with a non-function argument fails' {
  local -A obj=([__id__]='obj')
  run __hbl__Object__add_method obj test obj__non_function
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test '__hbl__Object__add_getter() succeeds' {
  local -A obj=([__id__]='obj')
  run __hbl__Object__add_getter obj myattr
  assert_success
  refute_output
}

@test '__hbl__Object__add_getter() creates the getter function' {
  local -A obj=([__id__]='obj')
  __hbl__Object__add_getter obj attr
  assert_function "obj__get_attr"
}

@test '__hbl__Object__add_getter() assigns a valid getter' {
  local -A obj=([__id__]='obj')
  stub __hbl__Object__read_attribute
  __hbl__Object__add_getter obj attr
  obj__get_attr obj val
  assert_stub_with_args __hbl__Object__read_attribute obj attr val
}

@test '__hbl__Object__add_getter() assigns the getter method' {
  local -A obj=([__id__]='obj')
  stub __hbl__Object__add_method
  __hbl__Object__add_getter obj attr
  assert_stub_with_args __hbl__Object__add_method obj get_attr obj__get_attr
}

@test '__hbl__Object__add_getter() with insufficient arguments fails' {
  run __hbl__Object__add_getter
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test '__hbl__Object__add_setter() succeeds' {
  local -A obj=([__id__]='obj')
  run __hbl__Object__add_setter obj attr
  assert_success
  refute_output
}

@test '__hbl__Object__add_setter() creates the setter function' {
  local -A obj=([__id__]='obj')
  __hbl__Object__add_setter obj attr
  assert_function "obj__set_attr"
}

@test '__hbl__Object__add_setter() assigns a valid setter' {
  local -A obj=([__id__]='obj')
  stub __hbl__Object__write_attribute
  __hbl__Object__add_setter obj attr
  obj__set_attr obj val
  assert_stub_with_args __hbl__Object__write_attribute obj attr val
}

@test '__hbl__Object__add_setter() assigns the setter method' {
  local -A obj=([__id__]='obj')
  stub __hbl__Object__add_method
  __hbl__Object__add_setter obj attr
  assert_stub_with_args __hbl__Object__add_method obj set_attr obj__set_attr
}

@test '__hbl__Object__add_setter() with insufficient arguments fails' {
  run __hbl__Object__add_setter
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test '__hbl__Object__add_reference() succeeds' {
  local -A obj=([__id__]='obj')
  run __hbl__Object__add_reference obj child
  assert_success
  refute_output
}

@test '__hbl__Object__add_reference() creates the reference function' {
  local -A obj=([__id__]='obj')
  __hbl__Object__add_reference obj child
  assert_function "obj__ref__child"
}

@test '__hbl__Object__add_reference() assigns a valid reference accessor' {
  local -A obj=([__id__]='obj')
  stub __hbl__Object__delegate_to_reference_
  __hbl__Object__add_reference obj child
  obj__ref__child obj size
  assert_stub_with_args __hbl__Object__delegate_to_reference_ obj child size
}

@test '__hbl__Object__add_reference() assigns the reference method' {
  local -A obj=([__id__]='obj')
  stub __hbl__Object__add_method
  __hbl__Object__add_reference obj child
  assert_stub_with_args __hbl__Object__add_method obj child obj__ref__child
}

@test '__hbl__Object__add_reference() with insufficient arguments fails' {
  run __hbl__Object__add_reference
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test '__hbl__Object__read_attribute() succeeds' {
  local -A obj=([__id__]='obj')
  local myvar
  obj[foo]='bar'
  run __hbl__Object__read_attribute obj foo myvar
  assert_success
  refute_output
}

@test '__hbl__Object__read_attribute() retrieves the value' {
  local -A obj=([__id__]='obj')
  local myvar
  obj[foo]='bar'
  __hbl__Object__read_attribute obj foo myvar
  assert_equal "$myvar" 'bar'
}

@test '__hbl__Object__read_attribute() with insufficient arguments fails' {
  run __hbl__Object__read_attribute
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test '__hbl__Object__write_attribute() succeeds' {
  local -A obj=([__id__]='obj')
  local myvar
  run __hbl__Object__write_attribute obj foo bar
  assert_success
  refute_output
}

@test '__hbl__Object__write_attribute() retrieves the value' {
  local -A obj=([__id__]='obj')
  local myvar
  __hbl__Object__write_attribute obj foo bar
  assert_equal "${obj[foo]}" 'bar'
}

@test '__hbl__Object__write_attribute() with insufficient arguments fails' {
  run __hbl__Object__write_attribute
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test '__hbl__Object__new() succeeds' {
  run __hbl__Object__new myobj
  assert_success
  refute_output
}

@test '__hbl__Object__new() creates the global object' {
  __hbl__Object__new myobj
  assert_dict myobj
}

@test '__hbl__Object__new() assigns the dispatcher' {
  __hbl__Object__new myobj
  assert_equal "${myobj[0]}" "__hbl__Object__dispatch_ myobj "
}

@test '__hbl__Object__new() assigns the __id__' {
  __hbl__Object__new myobj
  assert_equal "${myobj[__id__]}" myobj
}

@test '__hbl__Object__new() adds the object to __hbl__objects' {
  __hbl__Object__new myobj
  assert_array_contains __hbl__objects myobj
}

# vim: ts=2:sw=2:expandtab
