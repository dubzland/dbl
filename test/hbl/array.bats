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

@test ".contains?() when insufficient arguments are passed returns 101" {
	run hbl::array::contains?
	assert_failure 101
}

@test ".contains?() when too many arguments are passed returns 102" {
	run hbl::array::contains? haystack needle extra
	assert_failure 102
}

@test ".contains?() for a non-existent arrray returns 2" {
	run hbl::array::contains? haystack needle
	assert_failure 2
}

@test ".contains?() when the value is not present returns 1" {
	declare -a haystack
	run hbl::array::contains? haystack needle
	assert_failure 1
}

@test ".contains?() when the value is present returns 0" {
	declare -a haystack
	haystack=("needle")
	run hbl::array::contains? haystack needle
	assert_success
}
