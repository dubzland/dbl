#!/usr/bin/env bats

setup() {
  load '../../test_helper/common'
  common_setup
}

teardown() {
  stub_teardown
}

# @test 'Dict.get() succeeds' {
#   local myvar
#   local -A dict=([color]='red')

#   run $Dict.get dict 'color' myvar

#   assert_success
#   refute_output
# }

# @test 'Dict.get() retrieves the value' {
#   local myvar
#   local -A dict=([color]='red')

#   $Dict.get dict 'color' myvar

#   assert_equal "$myvar" 'red'
# }

# @test 'Dict.get() with insufficient arguments fails' {
#   run $Dict.get

#   assert_failure $__hbl__rc__argument_error
#   refute_output
# }

# @test 'Dict.get() with a non-associative array fails' {
#   local myvar
#   local dict

#   run $Dict.get dict 'color' myvar

#   assert_failure $__hbl__rc__argument_error
#   refute_output
# }

# @test 'Dict.get() with a blank key fails' {
#   local myvar
#   local -A dict=([color]='red')

#   run $Dict.get dict '' myvar

#   assert_failure $__hbl__rc__argument_error
#   refute_output
# }

# @test 'Dict.get() with an empty target variable fails' {
#   local myvar
#   local -A dict=([color]='red')

#   run $Dict.get dict 'color' ''

#   assert_failure $__hbl__rc__argument_error
#   refute_output
# }

# @test 'Dict.set() succeeds' {
#   local -A dict=()

#   run $Dict.set dict 'color' 'red'

#   assert_success
#   refute_output
# }

# @test 'Dict.set() assigns the value' {
#   local -A dict=()

#   $Dict.set dict 'color' 'red'

#   assert_equal "${dict[color]}" 'red'
# }

# @test 'Dict.set() with insufficient arguments fails' {
#   run $Dict.set

#   assert_failure $__hbl__rc__argument_error
#   refute_output
# }

# @test 'Dict.set() with a non-associative array fails' {
#   local dict

#   run $Dict.set dict 'color' 'red'

#   assert_failure $__hbl__rc__argument_error
#   refute_output
# }

@test 'Dict.has_key() succeeds' {
  local -A dict=([color]='red')

  run $Dict.has_key dict 'color'

  assert_success
  refute_output
}

@test 'Dict.has_key() for a missing key fails' {
  local -A dict=([color]='red')

  run $Dict.has_key dict 'size'

  assert_failure
  refute_output
}

@test 'Dict.has_key() with insufficient arguments fails' {
  run $Dict.has_key

  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Dict.has_key() with a non-associative array fails' {
  local dict

  run $Dict.has_key dict 'color'

  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Dict.get() with a blank key fails' {
  local -A dict=([color]='red')

  run $Dict.has_key dict ''

  assert_failure $__hbl__rc__argument_error
  refute_output
}

@test 'Dict.new() succeeds' {
  local dict

  run $Dict.new dict

  assert_success
  refute_output
}

@test 'Dict.new() initializes the size' {
  local dict dict_size

  $Dict.new dict
  $dict.read_attribute size dict_size

  assert_equal $dict_size 0
}

# vim: ts=2:sw=2:expandtab
