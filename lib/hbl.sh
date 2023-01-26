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

# ATTRIBUTE ACCESS
HBL_ATRR_NONE=0
HBL_ATTR_GETTER=1
HBL_ATTR_SETTER=2
HBL_ATTR_BOTH=3

# OPTION TYPES
HBL_OPTION_TYPES=(string number flag dir)
readonly HBL_OPTION_TYPES

declare -Ag __hbl
__hbl=()

declare -g __hbl__object__id
__hbl__object__id=0

declare -ag __hbl__objects
__hbl__objects=()

declare -ag __hbl__stack
__hbl__stack=()

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
source "${HBL_LIB}/hbl/dict.sh"

# shellcheck source=lib/hbl/command.sh
source "${HBL_LIB}/hbl/command.sh"
# shellcheck source=lib/hbl/option.sh
source "${HBL_LIB}/hbl/option.sh"
# # shellcheck source=lib/hbl/command/usage.sh
# source "${HBL_LIB}/hbl/command/usage.sh"
# # shellcheck source=lib/hbl/util.sh
source "${HBL_LIB}/hbl/util.sh"

#################################################################################
## Class
#################################################################################
declare -Agr __hbl__Class__prototype__methods=(
	[new]=__hbl__Class__new
	[extend]=__hbl__Class__extend
	[inspect]=__hbl__Class__inspect
	[static_method]=__hbl__Class__add_static_method
	[prototype_method]=__hbl__Class__add_prototype_method
	[attribute]=__hbl__Class__add_prototype_attribute
)

declare -Agr __hbl__Class__prototype=(
	[__methods__]=__hbl__Class__prototype__methods
)

declare -Agr __hbl__Class__static_methods=(
	[define]=__hbl__Class__static__define
)

declare -A __hbl__Class__classdef=(
	[prototype]=__hbl__Class__prototype
	[static_methods]=__hbl__Class__static_methods
)

__hbl__Class__static__define Class __hbl__Class__classdef || exit

unset __hbl__Class__classdef

#################################################################################
## Object
#################################################################################
declare -Agr __hbl__Object__prototype__methods=(
	[__init]=__hbl__Object__init
	[inspect]=__hbl__Object__inspect
	[methods]=__hbl__Object__get_methods
	[method]=__hbl__Object__add_method
	[read_attribute]=__hbl__Object__read_attribute
	[write_attribute]=__hbl__Object__write_attribute
	[getter]=__hbl__Object__add_getter
	[setter]=__hbl__Object__add_setter
	[add_reference]=__hbl__Object__add_reference
	[assign_reference]=__hbl__Object__assign_reference
	[delegate_to_reference]=__hbl__Object__delegate_to_reference
	[_get_id_]=__hbl__Object__get_id_
)

declare -Agr __hbl__Object__prototype=(
	[__methods__]=__hbl__Object__prototype__methods
)

declare -A __hbl__Object__classdef=(
	[prototype]=__hbl__Object__prototype
)

__hbl__Class__static__define Object __hbl__Object__classdef || exit

unset __hbl__Object__classdef

__hbl__Object__add_method Object new __hbh__Object__new || exit
# $Object.method new __hbl__Object__new || exit

################################################################################
# Array
################################################################################
declare -Agr __hbl__Array__prototype__methods=(
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

declare -Agr __hbl__Array__prototype__attributes=(
	[size]=$HBL_ATTR_GETTER
)

declare -Agr __hbl__Array__prototype=(
	[__methods__]=__hbl__Array__prototype__methods
	[__attributes__]=__hbl__Array__prototype__attributes
)

declare -Agr __hbl__Array__static_methods=(
	[at]=__hbl__Array__static__at
	[shift]=__hbl__Array__static__shift
	[unshift]=__hbl__Array__static__unshift
	[push]=__hbl__Array__static__push
	[pop]=__hbl__Array__static__pop
	[sort]=__hbl__Array__static__sort
	[contains]=__hbl__Array__static__contains
	[to_array]=__hbl__Array__static__to_array
)

declare -A __hbl__Array__classdef=(
	[prototype]=__hbl__Array__prototype
	[static_methods]=__hbl__Array__static_methods
)

__hbl__Class__extend Object Array __hbl__Array__classdef
# $Object.extend Array __hbl__Array__classdef

unset __hbl__Array__classdef

################################################################################
# Util
################################################################################
declare -Agr __hbl__Util__static_methods=(
	[is_defined]=__hbl__Util__static__is_defined
	[is_function]=__hbl__Util__static__is_function
	[is_associative_array]=__hbl__Util__static__is_associative_array
	[dump_associative_array]=__hbl__Util__static__dump_associative_array
)

declare -A __hbl__Util__classdef=(
	[static_methods]=__hbl__Util__static_methods
)

__hbl__Class__static__define Util __hbl__Util__classdef || exit
# $Class.define Util __hbl__Util__classdef

unset __hbl__Util__classdef

################################################################################
# Command
################################################################################
declare -Agr __hbl__Command__prototype__methods=(
	[__init]=__hbl__Command__init
	[add_example]=__hbl__Command__add_example
	[add_option]=__hbl__Command__add_option
	[add_subcommand]=__hbl__Command__add_subcommand
)

declare -Agr __hbl__Command__prototype__attributes=(
	[name]=$HBL_ATTR_BOTH
	[entrypoint]=$HBL_ATTR_BOTH
	[description]=$HBL_ATTR_BOTH
)

declare -Agr __hbl__Command__prototype__references=(
	[examples]="Array"
	[options]="Dict"
	[subcommands]="Array"
)

declare -Agr __hbl__Command__prototype=(
	[__methods__]=__hbl__Command__prototype__methods
	[__attributes__]=__hbl__Command__prototype__attributes
	[__references__]=__hbl__Command__prototype__references
)

declare -A __hbl__Command__classdef=(
	[prototype]=__hbl__Command__prototype
)

__hbl__Class__extend Object Command __hbl__Command__classdef
# $Object.extend Command __hbl__Command__classdef

unset __hbl__Command__classdef

################################################################################
# Option
################################################################################
declare -Agr __hbl__Option__prototype__methods=(
	[__init]=__hbl__Option__init
	# [command]=Command
)

declare -Agr __hbl__Option__prototype__attributes=(
	[name]=$HBL_ATTR_BOTH
	[type]=$HBL_ATTR_BOTH
	[short_flag]=$HBL_ATTR_BOTH
	[long_flag]=$HBL_ATTR_BOTH
	[description]=$HBL_ATTR_BOTH
	# [command]=Command
)

declare -Agr __hbl__Option__prototype=(
	[__methods__]=__hbl__Option__prototype__methods
	[__attributes__]=__hbl__Option__prototype__attributes
)

declare -A __hbl__Option__classdef=(
	[prototype]=__hbl__Option__prototype
)

__hbl__Class__extend Object Option __hbl__Option__classdef
# $Object.extend Option __hbl__Option__classdef

################################################################################
# Dict
################################################################################

declare -Agr __hbl__Dict__prototype__methods=(
	[__init]=__hbl__Dict__init
	[set]=__hbl__Dict__set
	[get]=__hbl__Dict__get
	[has_key]=__hbl__Dict__has_key
	[to_associative_array]=__hbl__Dict__to_associative_array
)

declare -Agr __hbl__Dict__prototype__attributes=(
	[size]=$HBL_ATTR_GETTER
)

declare -Agr __hbl__Dict__prototype=(
	[__methods__]=__hbl__Dict__prototype__methods
	[__attributes__]=__hbl__Dict__prototype__attributes
)

declare -A __hbl__Dict__classdef=(
	[prototype]=__hbl__Dict__prototype
)

__hbl__Class__extend Object Dict __hbl__Dict__classdef
# $Object.extend Dict __hbl__Dict__classdef

declare -g __hbl__imported
__hbl__imported=1
