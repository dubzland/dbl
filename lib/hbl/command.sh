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

readonly HBL_COMMAND_PREFIX="HBL"

function hbl::command::create() {
	local parent_id name desc namespace module
	parent_id="$1" name="$2" desc="$3" namespace="" module=""
	local -n command_id__ref="$4"

	hbl::util::string_to_underscore "${name}" namespace
	hbl::util::string_to_constant "${name}" module

	if [[ -n "${parent_id}" ]]; then
		local -n parent__ref="${HBL_COMMANDS[${parent_id}]}"
		namespace="${parent__ref[namespace]}::${namespace}"
		module="${parent__ref[module]}_${module}"
		fullname="${parent__ref[name]} ${name}"
		command_id__ref="${parent__ref[name]}::${name}"
	else
		fullname="${name}"
		module="${HBL_COMMAND_PREFIX}_${module}"
		command_id__ref="${name}"
	fi

	declare -Ag "${module}"
	local -n command__ref="${module}"
	command__ref=( \
		[id]="${command_id__ref}" \
		[parent]="${parent_id}" \
		[name]="${name}" \
		[fullname]="${fullname}" \
		[namespace]="${namespace}" \
		[module]="${module}" \
		[desc]="${desc}" \
	)

	HBL_COMMANDS["${command_id__ref}"]="${command__ref[module]}"

	# Options
	hbl::command::options::init "${command_id__ref}"

	# Examples
	hbl::command::examples::init "${command_id__ref}"

	# Subcommands
	hbl::command::subcommands::init "${command_id__ref}"

	# If this is a subcommand, add it to the parent
	if [[ -n "${parent_id}" ]]; then
		hbl::command::subcommands::add "${parent_id}" "${command_id__ref}"
	fi
}

function hbl::command::init() {
	declare -Ag HBL_COMMAND
	HBL_COMMAND=()
	HBL_COMMAND[name]=""

	declare -Ag HBL_PARAMS
	HBL_PARAMS=()
	HBL_PARAMS[verbose]=0
	HBL_PARAMS[showhelp]=0

	declare -Ag HBL_COMMANDS
}
