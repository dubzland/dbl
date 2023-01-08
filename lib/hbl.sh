#!/usr/bin/env bash

HBL_LIB="$(dirname "$(readlink -f "${BASH_SOURCE:-$0}")")"
# shellcheck source=lib/hbl/array.sh
source "${HBL_LIB}/hbl/array.sh"
# shellcheck source=lib/hbl/command.sh
source "${HBL_LIB}/hbl/command.sh"
# shellcheck source=lib/hbl/command/option.sh
source "${HBL_LIB}/hbl/command/option.sh"
# shellcheck source=lib/hbl/command/usage.sh
source "${HBL_LIB}/hbl/command/usage.sh"
# shellcheck source=lib/hbl/dict.sh
source "${HBL_LIB}/hbl/dict.sh"
# shellcheck source=lib/hbl/error.sh
source "${HBL_LIB}/hbl/error.sh"
# shellcheck source=lib/hbl/util.sh
source "${HBL_LIB}/hbl/util.sh"

function hbl::init() {
	local script
	script="$(basename "$1")"

	declare -Ag __hbl
	__hbl=()
	__hbl[program]="$1"
	__hbl[script]="${script}"
}

function hbl::add_command() {
	[[ $# -eq 3 ]] || hbl::error::invocation "$@" || exit
	[[ -n "$1" ]] || hbl::error::argument "name" "$1"|| exit
	[[ -n "$2" ]] || hbl::error::argument "entrypoint" "$2" || exit
	[[ -n "$3" ]] || hbl::error::argument "command_id_var" "$3" || exit

	local name entrypoint
	name="$1" entrypoint="$2" command_id_var="$3"

	local -n command_id__ref="$command_id_var"
	command_id__ref=""

	hbl::command::create "$name" "$entrypoint" "${!command_id__ref}"
}
