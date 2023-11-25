#!/usr/bin/env bats

setup() {
  load '../../test_helper/common'
  common_setup
}

teardown() {
  stub_teardown
}

@test 'Util.is_defined() succeeds' {
  local defined

  run $Util.is_defined defined

  assert_success
  refute_output
}

@test 'Util.is_defined() with insufficient arguments fails' {
  run $Util.is_defined

  assert_failure $__dbl__rc__argument_error
  refute_output
}

@test 'Util.is_defined() with an undefined variable fails' {
  run $Util.is_defined undefined

  assert_failure $__dbl__rc__error
  refute_output
}

@test 'Util.is_defined() with an empty variable name fails' {
  run $Util.is_defined ''

  assert_failure $__dbl__rc__argument_error
  refute_output
}

@test 'Util.is_function() succeeds' {
  function defined() { return 0; }

  run $Util.is_function defined

  assert_success
  refute_output
}

@test 'Util.is_function() with insufficient arguments fails' {
  run $Util.is_function

  assert_failure $__dbl__rc__argument_error
  refute_output
}

@test 'Util.is_function() with an undefined variable fails' {
  run $Util.is_function undefined

  assert_failure $__dbl__rc__error
  refute_output
}

@test 'Util.is_function() with a non-function variable fails' {
  local defined

  run $Util.is_function defined

  assert_failure $__dbl__rc__error
  refute_output
}

@test 'Util.is_function() with an empty variable fails' {
  run $Util.is_function ''

  assert_failure $__dbl__rc__argument_error
  refute_output
}

@test 'Util.is_associative_array() succeeds' {
  declare -A defined

  run $Util.is_associative_array defined

  assert_success
  refute_output
}

@test 'Util.is_associative_array() with an undefined variable fails' {
  run $Util.is_associative_array undefined

  assert_failure $__dbl__rc__error
  refute_output

  # Try again forcing BASH4 compatability
  FORCE_BASH4=1 run $Util.is_associative_array undefined

  assert_failure $__dbl__rc__error
  refute_output
}

@test 'Util.is_associative_array() with a normal variable fails' {
  declare defined

  run $Util.is_associative_array defined

  assert_failure $__dbl__rc__error
  refute_output
}

@test 'Util.is_associative_array() with a normal array fails' {
  declare -a defined

  run $Util.is_associative_array defined

  assert_failure $__dbl__rc__error
  refute_output
}

@test 'Util.is_associative_array() with insufficent arguments fails' {
  run $Util.is_associative_array

  assert_failure $__dbl__rc__argument_error
  refute_output
}

@test 'Util.is_associative_array() with an empty variable fails' {
  run $Util.is_associative_array ''

  assert_failure $__dbl__rc__argument_error
  refute_output
}

@test 'Util.dump_associative_array() succeeds' {
  declare -A defined
  defined=( [size]=large [color]=red )

  run $Util.dump_associative_array defined

  assert_success
  assert_output
}

@test 'Util.dump_associative_array() prints the array contents' {
  declare -A defined
  defined=( [size]=large [color]=red )

  run $Util.dump_associative_array defined

  assert_line --index 0 '=============== defined ================'
  assert_line --index 1 'color:          red'
  assert_line --index 2 'size:           large'
  assert_line --index 3 '^^^^^^^^^^^^^^^ defined ^^^^^^^^^^^^^^^^'
}

@test 'Util.dump_associative_array() with insufficient arguments fails' {
  run $Util.dump_associative_array

  assert_failure $__dbl__rc__argument_error
  refute_output
}

@test 'Util.dump_associative_array() with an empty array name fails' {
  run $Util.dump_associative_array ''

  assert_failure $__dbl__rc__argument_error
  refute_output
}

@test 'Util.dump_associative_array() with a non-array fails' {
  run $Util.dump_associative_array undefined

  assert_failure $__dbl__rc__argument_error
  refute_output
}

# vim: ts=2:sw=2:expandtab
