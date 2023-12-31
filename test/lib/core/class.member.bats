#!/usr/bin/env bats

setup() {
  load '../../test_helper/common'
  common_setup
}

teardown() {
  stub_teardown
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
  stub __dbl__Class__static__define
  $Object.extend Tester
  assert_stub_with_args __dbl__Class__static__define Tester
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
  assert_failure $__dbl__rc__argument_error
  refute_output
}

@test 'Class#static_method() with a non-function argument fails' {
  $Class.define Tester
  run $Tester.static_method method non_function
  assert_failure $__dbl__rc__argument_error
  refute_output
}

@test 'Class#static_reference() calls the object method' {
  $Class.define Tester
  stub __dbl__Object__add_reference
  $Tester.static_reference children
  assert_stub_with_args __dbl__Object__add_reference Tester children
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
  assert_failure $__dbl__rc__argument_error
  refute_output
}

@test 'Class#prototype_method() with a non-function argument fails' {
  $Class.define Tester
  run $Tester.prototype_method method non_function
  assert_failure $__dbl__rc__argument_error
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
  assert_failure $__dbl__rc__argument_error
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
  assert_failure $__dbl__rc__argument_error
  refute_output
}

# vim: ts=2:sw=2:expandtab
