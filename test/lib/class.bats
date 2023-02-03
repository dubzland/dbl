#!/usr/bin/env bats

setup() {
  load '../test_helper/common'
  common_setup

  stub __hbl__Object__new stubbed_new
}

teardown() {
  stub_teardown
}

stubbed_new() {
  declare -Ag "$1"
}

@test '__hbl__Class__static__define() succeeds' {
  run __hbl__Class__static__define Tester
  assert_success
  refute_output
}

@test '__hbl__Class__static__define() creates the global object' {
  local obj_id
  __hbl__Class__static__define Tester
  assert_stub_with_args __hbl__Object__new Tester
}

@test '__hbl__Class__static__define() assigns the __class__' {
  __hbl__Class__static__define Tester
  assert_equal "${Tester[__class__]}" Class
}

@test '__hbl__Class__static__define() assigns the __superclass__' {
  __hbl__Class__static__define Tester
  assert_equal "${Tester[__superclass__]}" Object
}

@test '__hbl__Class__static__define() accepts a class definition' {
  local -A classdef
  classdef=(
    [prototype]='_prototype'
    [static_methods]='_static_methods'
    [static_references]='_static_references'
    [references]='_references'
  )
  __hbl__Class__static__define Tester classdef
  assert_equal "${Tester[__prototype__]}" _prototype
  assert_equal "${Tester[__static_methods__]}" _static_methods
  assert_equal "${Tester[__static_references__]}" _static_references
  assert_equal "${Tester[__references__]}" _references
}

@test '__hbl__Class__extend() succeeds' {
  run __hbl__Class__extend Object Tester
  assert_success
  refute_output
}

@test '__hbl__Class__extend() calls .define() to create the class' {
  stub __hbl__Class__static__define
  __hbl__Class__extend Object Tester
  assert_stub_with_args __hbl__Class__static__define Tester
}

@test '__hbl__Class__extend() assigns the proper superclass' {
  __hbl__Class__extend Object Tester
  assert_equal "${Tester[__superclass__]}" Object
}

@test '__hbl__Class__add_static_method() succeeds' {
  function class__static() { return 0; }
  local -A class
  run __hbl__Class__add_static_method class method class__static
  assert_success
  refute_output
}

@test '__hbl__Class__add_static_method() creates the global static_methods' {
  function class__static() { return 0; }
  local -A class
  __hbl__Class__add_static_method class method class__static
  assert_dict class__static_methods
}

@test '__hbl__Class__add_static_method() assigns the static_methods' {
  function class__static() { return 0; }
  local -A class
  __hbl__Class__add_static_method class method class__static
  assert_equal "${class[__static_methods__]}" class__static_methods
}

@test '__hbl__Class__add_static_method() assigns the method' {
  function class__static() { return 0; }
  local -A class
  __hbl__Class__add_static_method class method class__static
  assert_equal "${class__static_methods[method]}" class__static
}

@test '__hbl__Class__add_static_method() with insufficient arguments fails' {
  run __hbl__Class__add_static_method class method class__static
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test '__hbl__Class__add_static_method() with a non-function argument fails' {
  local -A class
  run __hbl__Class__add_static_method class method non_function
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test '__hbl__Class__add_static_reference() calls the object method' {
  stub __hbl__Object__add_reference
  __hbl__Class__add_static_reference class method reference
  assert_stub_with_args __hbl__Object__add_reference class method reference
}

@test '__hbl__Class__add_prototype_method() succeeds' {
  local -A class
  function prototype__method() { return 0; }
  run __hbl__Class__add_prototype_method class method prototype__method
  assert_success
  refute_output
}

@test '__hbl__Class__add_prototype_method() creates the prototype' {
  local -A class
  function prototype__method() { return 0; }
  __hbl__Class__add_prototype_method class method prototype__method
  assert_dict class__prototype
}

@test '__hbl__Class__add_prototype_method() assigns the prototype' {
  local -A class
  function prototype__method() { return 0; }
  __hbl__Class__add_prototype_method class method prototype__method
  assert_equal "${class[__prototype__]}" class__prototype
}

@test '__hbl__Class__add_prototype_method() creates the prototype methods' {
  local -A class
  function prototype__method() { return 0; }
  __hbl__Class__add_prototype_method class method prototype__method
  assert_dict class__prototype__methods
}

@test '__hbl__Class__add_prototype_method() assigns the prototype methods' {
  local -A class
  function prototype__method() { return 0; }
  __hbl__Class__add_prototype_method class method prototype__method
  assert_equal "${class__prototype[__methods__]}" class__prototype__methods
}

@test '__hbl__Class__add_prototype_method() assigns the method' {
  local -A class
  function prototype__method() { return 0; }
  __hbl__Class__add_prototype_method class method prototype__method
  assert_equal "${class__prototype__methods[method]}" prototype__method
}

@test '__hbl__Class__add_prototype_method() with insufficient arguments fails' {
  local -A class
  run __hbl__Class__add_prototype_method class
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test '__hbl__Class__add_prototype_method() with a non-function argument fails' {
  local -A class
  run __hbl__Class__add_prototype_method class method non_function
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test '__hbl__Class__add_prototype_attribute() succeeds' {
  local -A class
  run __hbl__Class__add_prototype_attribute class attr
  assert_success
  refute_output
}

@test '__hbl__Class__add_prototype_attribute() creates the prototype' {
  local -A class
  __hbl__Class__add_prototype_attribute class attr
  assert_dict class__prototype
}

@test '__hbl__Class__add_prototype_attribute() assigns the prototype' {
  local -A class
  __hbl__Class__add_prototype_attribute class attr
  assert_equal "${class[__prototype__]}" class__prototype
}

@test '__hbl__Class__add_prototype_attribute() creates the prototype attributes' {
  local -A class
  __hbl__Class__add_prototype_attribute class attr
  assert_dict class__prototype__attributes
}

@test '__hbl__Class__add_prototype_attribute() assigns the prototype attributes' {
  local -A class
  __hbl__Class__add_prototype_attribute class attr
  assert_equal "${class__prototype[__attributes__]}" class__prototype__attributes
}

@test '__hbl__Class__add_prototype_attribute() assigns the attribute' {
  local -A class
  __hbl__Class__add_prototype_attribute class attr
  [[ -v class__prototype__attributes[attr] ]]
}

@test '__hbl__Class__add_prototype_attribute() with insufficient arguments fails' {
  local -A class
  run __hbl__Class__add_prototype_attribute class
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test '__hbl__Class__add_prototype_reference() succeeds' {
  local -A class
  run __hbl__Class__add_prototype_reference class ref Object
  assert_success
  refute_output
}

@test '__hbl__Class__add_prototype_reference() creates the prototype' {
  local -A class
  __hbl__Class__add_prototype_reference class ref Object
  assert_dict class__prototype
}

@test '__hbl__Class__add_prototype_reference() assigns the prototype' {
  local -A class
  __hbl__Class__add_prototype_reference class ref Object
  assert_equal "${class[__prototype__]}" class__prototype
}

@test '__hbl__Class__add_prototype_reference() creates the prototype references' {
  local -A class
  __hbl__Class__add_prototype_reference class ref Object
  assert_dict class__prototype__references
}

@test '__hbl__Class__add_prototype_reference() assigns the prototype references' {
  local -A class
  __hbl__Class__add_prototype_reference class ref Object
  assert_equal "${class__prototype[__references__]}" class__prototype__references
}

@test '__hbl__Class__add_prototype_reference() assigns the reference' {
  local -A class
  __hbl__Class__add_prototype_reference class ref Object
  assert_equal "${class__prototype__references[ref]}" Object
}

@test '__hbl__Class__add_prototype_reference() with insufficient arguments fails' {
  local -A class
  run __hbl__Class__add_prototype_reference class
  assert_failure $__hbl__rc__argument_error
  refute_output
}

# vim: ts=2:sw=2:expandtab
