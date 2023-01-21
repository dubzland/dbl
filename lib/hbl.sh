#!/usr/bin/env bash

[[ $__hbl__imported -eq 1 ]] && return || true

# Error codes
HBL_SUCCESS=0
HBL_ERROR=1
HBL_ERR_UNDEFINED=2
HBL_ERR_INVOCATION=101
HBL_ERR_ARGUMENT=102
HBL_ERR_ALREADY_DEFINED=103
HBL_ERR_UNDEFINED_METHOD=104
HBL_ERR_ILLEGAL_INSTRUCTION=105

readonly HBL_SUCCESS
readonly HBL_ERROR
readonly HBL_ERR_UNDEFINED
readonly HBL_ERR_INVOCATION
readonly HBL_ERR_ARGUMENT
readonly HBL_ERR_ALREADY_DEFINED
readonly HBL_ERR_UNDEFINED_METHOD
readonly HBL_ERR_ILLEGAL_INSTRUCTION

# ATTRIBUTE TYPES
HBL_STRING=1
HBL_NUMBER=2
HBL_ARRAY=3
HBL_ASSOCIATIVE_ARRAY=4
readonly HBL_STRING
readonly HBL_NUMBER
readonly HBL_ARRAY
readonly HBL_ASSOCIATIVE_ARRAY

# selector types
HBL_SELECTOR_METHOD=1
HBL_SELECTOR_GETTER=2
HBL_SELECTOR_SETTER=3
HBL_SELECTOR_REFERENCE=4
readonly HBL_SELECTOR_METHOD
readonly HBL_SELECTOR_GETTER
readonly HBL_SELECTOR_SETTER
readonly HBL_SELECTOR_REFERENCE

# OPTION TYPES
HBL_OPTION_TYPES=(string number flag dir)
readonly HBL_OPTION_TYPES

declare -Ag __hbl
__hbl=()

declare -ag __hbl__classes
__hbl__classes=()

declare -ag __hbl__objects
__hbl__objects=()

declare -ag __hbl__stack
__hbl__stack=()

declare -Ag __hbl__dispatch_cache
__hbl__dispatch_cache=()

declare HBL_LIB

function _dirname() {
	local tmp
	tmp=${1:-.}
	local -n dirname__ref="$2"

	[[ $tmp != *[!/]* ]] && dirname__ref='/' && return
	tmp=${tmp%%"${tmp##*[!/]}"}
	[[ $tmp != */* ]] && dirname__ref='.' && return
	tmp=${tmp%/*}
	tmp=${tmp%%"${tmp##*[!/]}"}
	dirname__ref="${tmp:-/}"
}

_dirname "${BASH_SOURCE[0]:-$0}" HBL_LIB

# shellcheck source=lib/hbl/object.sh
source "${HBL_LIB}/hbl/object.sh"
# shellcheck source=lib/hbl/class.sh
source "${HBL_LIB}/hbl/class.sh"
# shellcheck source=lib/hbl/error.sh
source "${HBL_LIB}/hbl/error.sh"
# shellcheck source=lib/hbl/array.sh
source "${HBL_LIB}/hbl/array.sh"
# shellcheck source=lib/hbl/dict.sh
source "${HBL_LIB}/hbl/dict.sh"

# shellcheck source=lib/hbl/command.sh
source "${HBL_LIB}/hbl/command.sh"
# shellcheck source=lib/hbl/option.sh
source "${HBL_LIB}/hbl/option.sh"
# # shellcheck source=lib/hbl/command/usage.sh
# source "${HBL_LIB}/hbl/command/usage.sh"
# # shellcheck source=lib/hbl/util.sh
source "${HBL_LIB}/hbl/util.sh"

declare -g __hbl__imported
__hbl__imported=1
