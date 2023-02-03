#!/usr/bin/env bats

setup() {
  load '../test_helper/common'
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

@test 'Class#inspect() succeeds' {
  $Class.define Tester
  run $Tester.inspect
  assert_success
}

@test 'Class#inspect() displays the class' {
  $Class.define Tester
  run $Tester.inspect
  assert_output '<Class:Tester>'
}

@test 'Class#extend() succeeds' {
  run $Object.extend Tester
  assert_success
  refute_output
}

@test 'Class#extend() calls .define() to create the class' {
  stub __hbl__Class__static__define
  $Object.extend Tester
  assert_stub_with_args __hbl__Class__static__define Tester
}

@test 'Class#extend() assigns the proper superclass' {
  $Object.extend Tester
  $Class.define Tester
  assert_equal "${Tester[__superclass__]}" Object
}

@test 'Class#static_method() succeeds' {
  function class__static() { return 0; }
  $Class.define Tester
  run $Tester.static_method method class__static
  assert_success
  refute_output
}

@test 'Class#static_method() creates the global static_methods' {
  function class__static() { return 0; }
  $Class.define Tester
  $Tester.static_method method class__static
  assert_dict Tester__static_methods
}

@test 'Class#static_method() assigns the static_methods' {
  function class__static() { return 0; }
  $Class.define Tester
  $Tester.static_method method class__static
  assert_equal "${Tester[__static_methods__]}" Tester__static_methods
}

@test 'Class#static_method() assigns the method' {
  function class__static() { return 0; }
  $Class.define Tester
  $Tester.static_method method class__static
  assert_equal "${Tester__static_methods[method]}" class__static
}

@test 'Class#static_method() with insufficient arguments fails' {
  $Class.define Tester
  run $Tester.static_method
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Class#static_method() with a non-function argument fails' {
  $Class.define Tester
  run $Tester.static_method method non_function
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Class#static_reference() calls the object method' {
  $Class.define Tester
  stub __hbl__Object__add_reference
  $Tester.static_reference method reference
  assert_stub_with_args __hbl__Object__add_reference Tester method reference
}

@test 'Class#prototype_method() succeeds' {
  function prototype__method() { return 0; }
  $Class.define Tester
  run $Tester.prototype_method method prototype__method
  assert_success
  refute_output
}

@test 'Class#prototype_method() creates the prototype' {
  function prototype__method() { return 0; }
  $Class.define Tester
  $Tester.prototype_method method prototype__method
  assert_dict Tester__prototype
}

@test 'Class#prototype_method() assigns the prototype' {
  function prototype__method() { return 0; }
  $Class.define Tester
  $Tester.prototype_method method prototype__method
  assert_equal "${Tester[__prototype__]}" Tester__prototype
}

@test 'Class#prototype_method() creates the prototype methods' {
  function prototype__method() { return 0; }
  $Class.define Tester
  $Tester.prototype_method method prototype__method
  assert_dict Tester__prototype__methods
}

@test 'Class#prototype_method() assigns the prototype methods' {
  function prototype__method() { return 0; }
  $Class.define Tester
  $Tester.prototype_method method prototype__method
  assert_equal "${Tester__prototype[__methods__]}" Tester__prototype__methods
}

@test 'Class#prototype_method() assigns the method' {
  function prototype__method() { return 0; }
  $Class.define Tester
  $Tester.prototype_method method prototype__method
  assert_equal "${Tester__prototype__methods[method]}" prototype__method
}

@test 'Class#prototype_method() with insufficient arguments fails' {
  $Class.define Tester
  run $Tester.prototype_method
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Class#prototype_method() with a non-function argument fails' {
  $Class.define Tester
  run $Tester.prototype_method method non_function
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Class#prototype_attribute() succeeds' {
  $Class.define Tester
  run $Tester.prototype_attribute attr
  assert_success
  refute_output
}

@test 'Class#prototype_attribute() creates the prototype' {
  $Class.define Tester
  $Tester.prototype_attribute attr
  assert_dict Tester__prototype
}

@test 'Class#prototype_attribute() assigns the prototype' {
  $Class.define Tester
  $Tester.prototype_attribute attr
  assert_equal "${Tester[__prototype__]}" Tester__prototype
}

@test 'Class#prototype_attribute() creates the prototype attributes' {
  $Class.define Tester
  $Tester.prototype_attribute attr
  assert_dict Tester__prototype__attributes
}

@test 'Class#prototype_attribute() assigns the prototype attributes' {
  $Class.define Tester
  $Tester.prototype_attribute attr
  assert_equal "${Tester__prototype[__attributes__]}" Tester__prototype__attributes
}

@test 'Class#prototype_attribute() assigns the attribute' {
  $Class.define Tester
  $Tester.prototype_attribute attr
  [[ -v Tester__prototype__attributes[attr] ]]
}

@test 'Class#prototype_attribute() with insufficient arguments fails' {
  $Class.define Tester
  run $Tester.prototype_attribute
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Class#prototype_reference() succeeds' {
  $Class.define Tester
  run $Tester.prototype_reference ref Object
  assert_success
  refute_output
}

@test 'Class#prototype_reference() creates the prototype' {
  $Class.define Tester
  $Tester.prototype_reference ref Object
  assert_dict Tester__prototype
}

@test 'Class#prototype_reference() assigns the prototype' {
  $Class.define Tester
  $Tester.prototype_reference ref Object
  assert_equal "${Tester[__prototype__]}" Tester__prototype
}

@test 'Class#prototype_reference() creates the prototype references' {
  $Class.define Tester
  $Tester.prototype_reference ref Object
  assert_dict Tester__prototype__references
}

@test 'Class#prototype_reference() assigns the prototype references' {
  $Class.define Tester
  $Tester.prototype_reference ref Object
  assert_equal "${Tester__prototype[__references__]}" Tester__prototype__references
}

@test 'Class#prototype_reference() assigns the reference' {
  $Class.define Tester
  $Tester.prototype_reference ref Object
  assert_equal "${Tester__prototype__references[ref]}" Object
}

@test 'Class#prototype_reference() with insufficient arguments fails' {
  $Class.define Tester
  run $Tester.prototype_reference
  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Class#new() succeeds' {
  $Class.define Tester
  run $Tester.new tester
  assert_success
  refute_output
}

@test 'Class#new() returns the dispatcher' {
  $Class.define Tester
  stub __hbl__Object__static__generate_id dummy_id
  $Tester.new tester
  assert_equal "$tester" "__hbl__Object__dispatch_ __hbl__Tester__0 "
}

@test 'Class#new() enables prototype methods' {
  function Tester__test() { printf "Tester test\n"; }
  $Class.define Tester
  $Tester.prototype_method test Tester__test
  $Tester.new tester
  run $tester.test
  assert_success
  assert_output 'Tester test'
}

@test 'Class#new() enables prototype attributes' {
  local color
  $Class.define Tester
  $Tester.prototype_attribute color
  $Tester.new tester
  $tester.set_color blue
  $tester.get_color color
  assert_equal "$color" blue
}

# vim: ts=2:sw=2:expandtab
