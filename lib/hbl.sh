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

HBL_LIB="$(dirname "$(readlink -f "${BASH_SOURCE:-$0}")")/hbl"
# shellcheck source=lib/hbl/array.sh
source "${HBL_LIB}/array.sh"
# shellcheck source=lib/hbl/command.sh
source "${HBL_LIB}/command.sh"
# shellcheck source=lib/hbl/command/option.sh
source "${HBL_LIB}/command/option.sh"
# shellcheck source=lib/hbl/command/examples.sh
source "${HBL_LIB}/command/examples.sh"
# shellcheck source=lib/hbl/dict.sh
source "${HBL_LIB}/dict.sh"
# shellcheck source=lib/hbl/util.sh
source "${HBL_LIB}/util.sh"
unset HBL_LIB


function hbl::init() {
	local script
	script="$(basename "$1")"

	declare -Ag HBL
	HBL=()
	HBL[program]="$1"
	HBL[script]="${script}"
	# DL[command]=""
	# DL[showhelp]=0

	# declare -Ag DL_COMMANDS
	# # shellcheck disable=SC2034
	# DL_COMMANDS=()

	# declare -Ag DL_PARAMS
	# # shellcheck disable=SC2034
	# DL_PARAMS=()
}

function hbl::add_command() {
	local name entrypoint
	name="$1" entrypoint="$2"
	local -n command_id__ref="$3"

	hbl::command::create "$name" "$entrypoint" "${!command_id__ref}"
}
