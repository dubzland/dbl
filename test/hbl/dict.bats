#
# MIT License
#
# Copyright (c) 2023 Josh Williams <jdubz@holodekk.io>
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
	load '../test_helper/common'

	common_setup
}

@test ".set() returns 3 when insufficient arguments are passed" {
	run hbl::dict::set mydict mykey
	assert_failure 3
}

@test ".set() returns 2 when the dict does not exist" {
	run hbl::dict::set mydict mykey myval
	assert_failure 2
}

@test ".set() assigns a value to the dict (by reference)" {
	declare -A mydict
	hbl::dict::set mydict mykey myval
	assert_equal "${mydict[mykey]}" "myval"
}

@test ".set() supports values with spaces" {
	declare -A mydict
	hbl::dict::set mydict mykey myval with space
	assert_equal "${mydict[mykey]}" "myval with space"
}

@test ".has_key?() returns 3 when insufficient arguments are passed" {
	declare -A mydict
	run hbl::dict::has_key? mydict
	assert_failure 3
}

@test ".has_key?() returns 4 when too many arguments are passed" {
	declare -A mydict
	run hbl::dict::has_key? mydict myval extra
	assert_failure 4
}

@test ".has_key?() returns 2 when the dict does not exist" {
	run hbl::dict::has_key? mydict mykey
	assert_failure 2
}

@test ".has_key?() returns 1 when the key does not exist" {
	declare -Ag mydict
	run hbl::dict::has_key? mydict mykey
	assert_failure 1
}

@test ".has_key?() returns 0 when the key exists" {
	declare -Ag mydict
	mydict[mykey]=myval
	run hbl::dict::has_key? mydict mykey
	assert_success
}

@test ".get() returns 3 when insufficient arguments are passed" {
	declare -A mydict
	run hbl::dict::get mydict
	assert_failure 3
}

@test ".get() returns 4 when too many arguments are passed" {
	declare -A mydict
	run hbl::dict::get mydict myval myvar extra
	assert_failure 4
}

@test ".get() returns 2 when the dict does not exist" {
	run hbl::dict::get mydict mykey myvar
	assert_failure 2
}

@test ".get() returns 1 when the key does not exist" {
	declare -Ag mydict
	run hbl::dict::get mydict mykey myvar
	assert_failure 1
}

@test ".get() returns 0 when the key exists" {
	declare -Ag mydict
	mydict[mykey]=myval
	run hbl::dict::get mydict mykey myvar
	assert_success
}

@test ".get() assigns the value by reference" {
	declare -Ag mydict
	local myvar
	mydict[mykey]="test"
	hbl::dict::get mydict mykey myvar
	assert_equal "$myvar" "test"
}
