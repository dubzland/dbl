#!/usr/bin/env bats

#setup() {
# load '../../test_helper/common'
# load '../../test_helper/command'
# common_setup

# # declare -Ag TEST_COMMAND
# # TEST_COMMAND=([name]="test-command" [entrypoint]="test_command__run")

# declare -a usage_examples_args
# usage_examples_args=()
# usage_examples_invoked=0
# function hbl__command__usage__examples() {
#   usage_examples_invoked=1
#   usage_examples_args=("$@")
#   echo "Examples"
#   return 0
# }

# declare -a usage_description_args
# usage_description_args=()
# usage_description_invoked=0
# function hbl__command__usage__description() {
#   usage_description_invoked=1
#   usage_description_args=("$@")
#   echo "Description"
#   return 0
# }

# declare -a usage_subcommands_args
# usage_subcommands_args=()
# usage_subcommands_invoked=0
# function hbl__command__usage__subcommands() {
#   usage_subcommands_invoked=1
#   usage_subcommands_args=("$@")
#   echo "Subcommands"
#   return 0
# }
#}

##
## hbl__command__usage__show()
##
#@test 'hbl__command__usage__show() validates its arguments' {
# # insufficient arguments
# run hbl__command__usage__show
# assert_failure $HBL_ERR_INVOCATION

# # too many arguments
# run hbl__command__usage__show '__test_command' 'extra'
# assert_failure $HBL_ERR_INVOCATION

# # empty command id
# run hbl__command__usage__show ''
# assert_failure $HBL_ERR_ARGUMENT

# # invalid command
# function hbl__command__ensure_command() { return 1; }
# run hbl__command__usage__show '__test_command'
# assert_failure
# unset hbl__command__ensure_command
#}

#@test 'hbl__command__usage__show() succeeds' {
# hbl_test__mock_command '__test_command'
# run hbl__command__usage__show '__test_command'
# assert_success
#}

#@test 'hbl__command__usage__show() displays the examples' {
# hbl_test__mock_command '__test_command'
# hbl__command__usage__show '__test_command'
# assert_equal $usage_examples_invoked 1
# assert_equal ${#usage_examples_args[@]} 1
# assert_equal ${usage_examples_args[0]} '__test_command'
#}

#@test 'hbl__command__usage__show() displays the description' {
# hbl_test__mock_command '__test_command'
# hbl__command__usage__show '__test_command'
# assert_equal $usage_description_invoked 1
# assert_equal ${#usage_description_args[@]} 1
# assert_equal ${usage_description_args[0]} '__test_command'
#}

#@test 'hbl__command__usage__show() displays the subcommands' {
# hbl_test__mock_command '__test_command'
# hbl__command__usage__show '__test_command'
# assert_equal $usage_subcommands_invoked 1
# assert_equal ${#usage_subcommands_args[@]} 1
# assert_equal ${usage_subcommands_args[0]} '__test_command'
#}

# vim: ts=2:sw=2:expandtab
