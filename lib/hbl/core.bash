#!/usr/bin/env bash

###############################################
#    E R R O R   C O D E S
###############################################
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

# shellcheck source=lib/hbl/core/class.bash
source "${BASH_SOURCE%/*}/core/class.bash"   &&
# shellcheck source=lib/hbl/core/object.bash
source "${BASH_SOURCE%/*}/core/object.bash"  &&
# shellcheck source=lib/hbl/core/array.bash
source "${BASH_SOURCE%/*}/core/array.bash"   &&
# shellcheck source=lib/hbl/core/dict.bash
source "${BASH_SOURCE%/*}/core/dict.bash"    &&
# shellcheck source=lib/hbl/core/error.bash
source "${BASH_SOURCE%/*}/core/error.bash"   &&
# # shellcheck source=lib/hbl/core/util.bash
source "${BASH_SOURCE%/*}/core/util.bash"    || exit

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

unset __hbl__Array__classdef

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

declare -Agr __hbl__Dict__static_methods=(
  [get]=__hbl__Dict__static__get
  [set]=__hbl__Dict__static__set
  [has_key]=__hbl__Dict__static__has_key
)

declare -A __hbl__Dict__classdef=(
  [prototype]=__hbl__Dict__prototype
  [static_methods]=__hbl__Dict__static_methods
)

$Object.extend Dict __hbl__Dict__classdef || exit
# __hbl__Class__extend Object Dict __hbl__Dict__classdef || exit

unset __hbl__Dict__classdef

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

# vim: ts=2:sw=2:expandtab
