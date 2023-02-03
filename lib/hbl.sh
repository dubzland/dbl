#!/usr/bin/env bash

# shellcheck disable=2015
[[ -v __hbl__imported && $__hbl__imported -eq 1 ]] && return || true

declare -gr __hbl__path="${BASH_SOURCE%/*}"

declare -ir __hbl__force_bash4=${FORCE_BASH4:-0}

###############################################
#    E R R O R   C O D E S
# shellcheck disable=2034
declare -igr __hbl__rc__success=0
declare -igr __hbl__rc__error=1
declare -igr __hbl__rc__argument_error=102
declare -igr __hbl__rc__undefined_method=103
declare -igr __hbl__rc__illegal_instruction=104

# ATTRIBUTE ACCESS
declare -igr __hbl__attr__none=0
declare -igr __hbl__attr__getter=1
declare -igr __hbl__attr__setter=2
declare -igr __hbl__attr__both=3

declare -g __hbl__object__id=0

declare -Ag __hbl__dispatcher=()

declare -ag __hbl__objects=()

declare -ag __hbl__stack=()

# shellcheck source=lib/hbl/core/class.sh
source "${__hbl__path}/hbl/core/class.sh"   &&
# shellcheck source=lib/hbl/core/object.sh
source "${__hbl__path}/hbl/core/object.sh"  &&
# shellcheck source=lib/hbl/error.sh
source "${__hbl__path}/hbl/error.sh"   &&
# shellcheck source=lib/hbl/array.sh
source "${__hbl__path}/hbl/array.sh"   &&
# shellcheck source=lib/hbl/dict.sh
source "${__hbl__path}/hbl/dict.sh"    &&

# shellcheck source=lib/hbl/command.sh
source "${__hbl__path}/hbl/command.sh" &&
# shellcheck source=lib/hbl/command/option.sh
source "${__hbl__path}/hbl/command/option.sh"  &&
# # shellcheck source=lib/hbl/command/usage.sh
# source "${__hbl__path}/hbl/command/usage.sh"
# # shellcheck source=lib/hbl/util.sh
source "${__hbl__path}/hbl/util.sh"    || exit

function __hbl__dump_object_() {
  local -n this="$1"
  printf "=== %s ===\n" "$1"
  for key in "${!this[@]}"; do
    printf "%-20s %s\n" "${key}:" "${this[$key]}"
  done
}

function __hbl__dump_entry_() {
  printf "*** %s ***\n" "${FUNCNAME[1]}"
  printf "args: %s\n" "${@}"
  printf "**********\n"
}

function __hbl__dump_stack_() {
  printf "\n* * * * * S T A C K * * * * *\n"
  for item in "${__hbl__stack[@]}"; do
    printf "%s\n" "$item"
  done
  printf "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^\n\n"
}

function __hbl__dump_array_() {
  local item
  local -n this="$1"

  printf "\n* * * * * %s * * * * *\n" "$1"
  for item in "${this[@]}"; do
    printf "%s\n" "$item"
  done

  printf "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^\n\n"
}

#################################################################################
## Class
#################################################################################
declare -Agr __hbl__Class__prototype__methods=(
  [inspect]=__hbl__Class__inspect
  [extend]=__hbl__Class__extend
  [static_method]=__hbl__Class__add_static_method
  [static_reference]=__hbl__Class__add_static_reference
  [prototype_method]=__hbl__Class__add_prototype_method
  [prototype_attribute]=__hbl__Class__add_prototype_attribute
  [prototype_reference]=__hbl__Class__add_prototype_reference
  [new]=__hbl__Class__new
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
  [read_attribute]=__hbl__Object__read_attribute
  [write_attribute]=__hbl__Object__write_attribute
  [has_method]=__hbl__Object__has_method
  [add_method]=__hbl__Object__add_method
  [add_reference]=__hbl__Object__add_reference
  [add_getter]=__hbl__Object__add_getter
  [add_setter]=__hbl__Object__add_setter
  [assign_reference]=__hbl__Object__assign_reference
  [_get_id_]=__hbl__Object__get_id_
  [_get_class_]=__hbl__Object__get_class_
)

declare -Agr __hbl__Object__prototype=(
  [__methods__]=__hbl__Object__prototype__methods
)

declare -Agr __hbl__Object__static_methods=(
  [generate_id]=__hbl__Object__static__generate_id
)

declare -A __hbl__Object__classdef=(
  [prototype]=__hbl__Object__prototype
  [static_methods]=__hbl__Object__static_methods
)

__hbl__Class__static__define Object __hbl__Object__classdef || exit

unset __hbl__Object__classdef

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
  [size]=$__hbl__attr__getter
)

declare -Agr __hbl__Array__prototype=(
  [__methods__]=__hbl__Array__prototype__methods
  [__attributes__]=__hbl__Array__prototype__attributes
)

declare -Agr __hbl__Array__static_methods=(
  [is_array]=__hbl__Array__static__is_array
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

$Object.extend Array __hbl__Array__classdef || exit
# __hbl__Class__extend Object Array __hbl__Array__classdef || exit

unset __hbl__Array__classdef

################################################################################
# Util
################################################################################
declare -Agr __hbl__Util__static_methods=(
  [is_defined]=__hbl__Util__static__is_defined
  [is_function]=__hbl__Util__static__is_function
  [is_associative_array]=__hbl__Util__static__is_associative_array
  [dump_associative_array]=__hbl__Util__static__dump_associative_array
  [dump_object]=__hbl__Util__static__dump_object
)

declare -A __hbl__Util__classdef=(
  [static_methods]=__hbl__Util__static_methods
)

__hbl__Class__static__define Util __hbl__Util__classdef || exit

unset __hbl__Util__classdef

################################################################################
# Error
################################################################################
declare -Agr __hbl__Error__static_methods=(
  [argument]=__hbl__Error__static__argument_error
  [undefined_method]=__hbl__Error__static__undefined_method_error
  [illegal_instruction]=__hbl__Error__static__illegal_instruction_error
)

declare -A __hbl__Error__classdef=(
  [static_methods]=__hbl__Error__static_methods
)

__hbl__Class__static__define Error __hbl__Error__classdef || exit

unset __hbl__Error__classdef

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
  [name]=$__hbl__attr__both
  [entrypoint]=$__hbl__attr__both
  [description]=$__hbl__attr__both
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

$Object.extend Command __hbl__Command__classdef || exit
# __hbl__Class__extend Object Command __hbl__Command__classdef || exit

unset __hbl__Command__classdef

################################################################################
# Command__Option
################################################################################
declare -Agr __hbl__Command__Option__prototype__methods=(
  [__init]=__hbl__Command__Option__init
)

declare -Agr __hbl__Command__Option__prototype__attributes=(
  [name]=$__hbl__attr__both
  [type]=$__hbl__attr__both
  [short_flag]=$__hbl__attr__both
  [long_flag]=$__hbl__attr__both
  [description]=$__hbl__attr__both
)

declare -Agr __hbl__Command__Option__prototype__references=(
  [command]=Command
)

declare -Agr __hbl__Command__Option__prototype=(
  [__methods__]=__hbl__Command__Option__prototype__methods
  [__attributes__]=__hbl__Command__Option__prototype__attributes
  [__references__]=__hbl__Command__Option__prototype__references
)

declare -A __hbl__Command__Option__classdef=(
  [prototype]=__hbl__Command__Option__prototype
)

$Object.extend Command__Option __hbl__Command__Option__classdef || exit
# __hbl__Class__extend Object Command__Option __hbl__Command__Option__classdef || exit

unset __hbl__Command__Option__classdef

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
  [size]=$__hbl__attr__getter
)

declare -Agr __hbl__Dict__prototype=(
  [__methods__]=__hbl__Dict__prototype__methods
  [__attributes__]=__hbl__Dict__prototype__attributes
)

declare -A __hbl__Dict__classdef=(
  [prototype]=__hbl__Dict__prototype
)

$Object.extend Dict __hbl__Dict__classdef || exit
# __hbl__Class__extend Object Dict __hbl__Dict__classdef || exit

unset __hbl__Dict__classdef

declare -g __hbl__imported
__hbl__imported=1

# vim: ts=2:sw=2:expandtab
