
#!/usr/bin/env bash
#
# MIT License
#
# Copyright (c) [2022] [Josh Williams]
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

setup() {
	load '../../test_helper/common'
	common_setup
	declare -Ag TEST_COMMAND
	TEST_COMMAND=()
}

@test ".create() creates the option" {
	hbl::command::option::create "TEST_COMMAND" "test_option" option_id
	run hbl::util::is_dict? "TEST_COMMAND_OPTION_0"
	assert_success
}

@test ".create() assigns the option name" {
	hbl::command::option::create "TEST_COMMAND" "test_option" option_id
	run hbl::dict::has_key? "TEST_COMMAND_OPTION_0" "name"
	assert_success
	hbl::dict::get "TEST_COMMAND_OPTION_0" "name" option_name
	assert_equal "${option_name}" "test_option"
}

@test ".create() returns the option id" {
	hbl::command::option::create "TEST_COMMAND" "test_option" option_id
	assert_equal "${option_id}" "TEST_COMMAND_OPTION_0"
}

# @test ".add_option() creates the option" {
# 	local option_id
# 	hbl::command::add_option "HBL_COMMAND_0" option_id
# 	run is_associative_array "HBL_COMMAND_0_OPTION_0"
# 	assert_success
# 	declare | grep ^DL_ >&3
# }

# @test ".add_option() returns the option id" {
# 	local option_id
# 	hbl::command::add_option "HBL_COMMAND_0" option_id
# 	assert_equal $option_id "HBL_COMMAND_0_OPTION_0"
# }

# @test ".add_option() adds the option to the command" {
# 	local option_id
# 	hbl::command::add_option "HBL_COMMAND_0
# }
