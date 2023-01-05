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

readonly HBL_SUBCOMMANDS_SUFFIX="_SUBCOMMANDS"

function hbl::command::subcommands::init() {
	local command_id="$1"
	local -n command__ref="${HBL_COMMANDS[${command_id}]}"

	command__ref[subcommands]="${command__ref[module]}${HBL_SUBCOMMANDS_SUFFIX}"
	declare -Ag "${command__ref[subcommands]}"
	local -n command_subcommands__ref="${command__ref[subcommands]}"
	command_subcommands__ref=()
}

function hbl::command::subcommands::add() {
	local command_id subcommand_id
	command_id="$1"
	subcommand_id="$2"

	local -n command__ref="${HBL_COMMANDS[${command_id}]}"
	local -n subcommands__ref="${command__ref[subcommands]}"
	subcommands__ref+=("${subcommand_id}")
}
