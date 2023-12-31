#!/usr/bin/env bats

setup() {
  load '../../test_helper/common'
  common_setup
}

@test 'Command.new() succeeds' {
  local cmd
  run $Command.new cmd 'test-command'
  assert_success
  refute_output
}

@test 'Command.new() requires a name' {
  local cmd
  run $Command.new cmd ''
  assert_failure $__dbl__rc__argument_error
  refute_output
}

@test 'Command#set_description() sets the description on the command' {
  local cmd actual expected
  expected='A simple command'
  $Command.new cmd 'test-command'
  $cmd.set_description "$expected"
  run $cmd.get_description actual
  assert_success
  refute_output

  $cmd.get_description actual
  assert_equal "$actual" "$expected"
}

@test 'Command#add_example() succeeds' {
  $Command.new cmd 'test-command'
  run $cmd.add_example 'foo -h'
  assert_success
  refute_output
}

@test 'Command#add_example() adds to the examples reference' {
  $Command.new cmd 'test-command'
  $cmd.add_example 'foo -h'
  $cmd.examples.to_array examples_arr
  assert_equal ${#examples_arr[@]} 1
  assert_equal "${examples_arr[0]}" 'foo -h'
}

@test 'Command#add_option() succeeds' {
  $Command__Option.new opt verbose
  $Command.new cmd 'test-command'
  run $cmd.add_option "$opt"
  assert_success
  refute_output
}

@test 'Command#add_option() adds the option to the reference' {
  $Command__Option.new opt verbose
  $Command.new cmd 'test-command'
  $cmd.add_option "$opt"
  $cmd.options.to_associative_array options_dict

  assert_equal ${#options_dict[@]} 1
  assert_equal "${options_dict[verbose]}" "$opt"
}

@test 'Command#add_subcommand() succeeds' {
  $Command.new sub 'sub-command'

  $Command.new cmd 'test-command'
  run $cmd.add_subcommand "$sub"
  assert_success
  refute_output
}

@test 'Command#add_subcommand() adds the subcommand to the reference' {
  $Command.new sub 'sub-command'
  $Command.new cmd 'test-command'
  $cmd.add_subcommand "$sub"
  $cmd.subcommands.to_array subcommands_arr

  assert_equal ${#subcommands_arr[@]} 1
  assert_equal "${subcommands_arr[0]}" "$sub"
}

# vim: ts=2:sw=2:expandtab
