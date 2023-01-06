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

function hbl::util::is_defined?() {
	if declare -p "$1" 2>&1 >/dev/null; then
		return 0
	fi
	return 1
}

function hbl::util::is_function?() {
	declare -f -F "$1" 2>&1 >/dev/null
	return $?
}

function hbl::util::is_array?() {
	if hbl::util::is_defined? "$1"; then
		[[ "$(declare -p $1 2>/dev/null)" == "declare -a"* ]] && return 0
	fi
	return 1
}

function hbl::util::is_dict?() {
	if hbl::util::is_defined? "$1"; then
		[[ "$(declare -p $1 2>/dev/null)" == "declare -A"* ]] && return 0
	fi
	return 1
}

function hbl::util::string_to_constant() {
	local source
	source="$1"
	local -n target__ref="$2"
	local underscore=""
	hbl::util::string_to_underscore "${source}" underscore
	target__ref="${underscore^^}"
}

function hbl::util::string_to_underscore() {
	local source
	source="$1"
	local -n target__ref="$2"
	# Shellcheck doesn't seem to support nameref variables yet.
	# See https://github.com/koalaman/shellcheck/issues/1544.
	# shellcheck disable=SC2034
	target__ref="${source//[^a-zA-Z0-9]/_}"
}
