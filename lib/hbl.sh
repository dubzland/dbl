#!/usr/bin/env bash

[[ -v __hbl__imported && $__hbl__imported -eq 1 ]] && return || true

FORCE_BASH4=${FORCE_BASH4:-0}

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

declare -g __hbl__object__id
__hbl__object__id=0

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

# shellcheck source=lib/hbl/class.sh
source "${HBL_LIB}/hbl/class.sh"
# shellcheck source=lib/hbl/object.sh
source "${HBL_LIB}/hbl/object.sh"
# shellcheck source=lib/hbl/error.sh
# source "${HBL_LIB}/hbl/error.sh"
# shellcheck source=lib/hbl/array.sh
source "${HBL_LIB}/hbl/array.sh"
# shellcheck source=lib/hbl/dict.sh
# source "${HBL_LIB}/hbl/dict.sh"

# shellcheck source=lib/hbl/command.sh
# source "${HBL_LIB}/hbl/command.sh"
# shellcheck source=lib/hbl/option.sh
# source "${HBL_LIB}/hbl/option.sh"
# # shellcheck source=lib/hbl/command/usage.sh
# source "${HBL_LIB}/hbl/command/usage.sh"
# # shellcheck source=lib/hbl/util.sh
source "${HBL_LIB}/hbl/util.sh"

#################################################################################
## Class
#################################################################################
declare -Ag __hbl__Class__prototype__methods
__hbl__Class__prototype__methods=(
	[new]=__hbl__Class__new
	[extend]=__hbl__Class__extend
	[method]=__hbl__Object__add_method
	[inspect]=__hbl__Class__inspect
	# [method]=__hbl__Class__method
	# [instance_method]=__hbl__Class_instance_method
	# [define]=__hbl__Class__define
	# [reference]=__hbl__Class__reference
)
readonly __hbl__Class__prototype__methods

declare -Ag __hbl__Class__prototype
__hbl__Class__prototype=(
	[__methods__]=__hbl__Class__prototype__methods
)

declare -Ag Class
__hbl__Object__init Class
Class[__class__]=Class
Class[__superclass__]=Object
Class[__prototype__]=__hbl__Class__prototype

$Class.method define __hbl__Class__static__define || exit

#################################################################################
## Object
#################################################################################
declare -Ag __hbl__Object__prototype__methods
__hbl__Object__prototype__methods=(
	[inspect]=__hbl__Object__inspect
	[methods]=__hbl__Object__get_methods
)
readonly __hbl__Object__prototype__methods

declare -Ag __hbl__Object__prototype
__hbl__Object__prototype=(
	[__methods__]=__hbl__Object__prototype__methods
)
readonly __hbl__Object__prototype

$Class.define Object __hbl__Object__prototype || return
$Object.method new __hbl__Object__new

################################################################################
# Array
################################################################################
declare -Ag __hbl__Array__methods
__hbl__Array__methods=(
	[is_array]=__hbl__Array__static__is_array
	[at]=__hbl__Array__static__at
	[shift]=__hbl__Array__static__shift
	[unshift]=__hbl__Array__static__unshift
	[push]=__hbl__Array__static__push
	[pop]=__hbl__Array__static__pop
	[sort]=__hbl__Array__static__sort
	[contains]=__hbl__Array__static__contains
)
readonly __hbl__Array__methods

declare -Ag __hbl__Array__prototype__methods
__hbl__Array__prototype__methods=(
	[__init]=__hbl__Array__init
	[at]=__hbl__Array__at
	[shift]=__hbl__Array__shift
	[unshift]=__hbl__Array__unshift
	[push]=__hbl__Array__push
	[pop]=__hbl__Array__pop
	[sort]=__hbl__Array__sort
	[contains]=__hbl__Array__contains
	[to_array]=__hbl__Array__to_array
)
readonly __hbl__Array__prototype__methods

declare -Ag __hbl__Array__prototype
__hbl__Array__prototype=(
	[__methods__]=__hbl__Array__prototype__methods
)
readonly __hbl__Array__prototype

$Object.extend Array __hbl__Array__prototype

declare -g __hbl__imported
__hbl__imported=1
