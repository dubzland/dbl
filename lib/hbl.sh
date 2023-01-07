#!/usr/bin/env bash

HBL_LIB="$(dirname "$(readlink -f "${BASH_SOURCE:-$0}")")/hbl"
# shellcheck source=lib/hbl/array.sh
source "${HBL_LIB}/array.sh"
# shellcheck source=lib/hbl/command.sh
source "${HBL_LIB}/command.sh"
# shellcheck source=lib/hbl/command/option.sh
source "${HBL_LIB}/command/option.sh"
# shellcheck source=lib/hbl/command/usage.sh
source "${HBL_LIB}/command/usage.sh"
# shellcheck source=lib/hbl/dict.sh
source "${HBL_LIB}/dict.sh"
# shellcheck source=lib/hbl/error.sh
source "${HBL_LIB}/error.sh"
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
}

function hbl::add_command() {
	[[ $# -eq 3 ]] || hbl::error::invalid_args "${FUNCNAME[0]}" "$@" || return

	local name entrypoint
	name="$1" entrypoint="$2"
	local -n command_id__ref="$3"

	hbl::command::create "$name" "$entrypoint" "${!command_id__ref}"
}
