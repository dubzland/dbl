#!/usr/bin/env bash

###############################################
#    E R R O R   C O D E S
###############################################
# shellcheck disable=2034
declare -igr __dbl__rc__success=0
declare -igr __dbl__rc__error=1
declare -igr __dbl__rc__argument_error=102
declare -igr __dbl__rc__undefined_method=103
declare -igr __dbl__rc__illegal_instruction=104

# ATTRIBUTE ACCESS
declare -igr __dbl__attr__none=0
declare -igr __dbl__attr__getter=1
declare -igr __dbl__attr__setter=2
declare -igr __dbl__attr__both=3

declare -g __dbl__object__id=0

declare -Ag __dbl__dispatcher=()

declare -ag __dbl__objects=()

declare -ag __dbl__stack=()

# shellcheck source=lib/dbl/core/class.bash
source "${BASH_SOURCE%/*}/core/class.bash"   &&
# shellcheck source=lib/dbl/core/object.bash
source "${BASH_SOURCE%/*}/core/object.bash"  &&
# shellcheck source=lib/dbl/core/array.bash
source "${BASH_SOURCE%/*}/core/array.bash"   &&
# shellcheck source=lib/dbl/core/dict.bash
source "${BASH_SOURCE%/*}/core/dict.bash"    &&
# shellcheck source=lib/dbl/core/error.bash
source "${BASH_SOURCE%/*}/core/error.bash"   &&
# # shellcheck source=lib/dbl/core/util.bash
source "${BASH_SOURCE%/*}/core/util.bash"    || exit

#################################################################################
## Class
#################################################################################
declare -Agr __dbl__Class__prototype__methods=(
  [inspect]=__dbl__Class__inspect
  [extend]=__dbl__Class__extend
  [static_method]=__dbl__Class__add_static_method
  [static_reference]=__dbl__Class__add_static_reference
  [prototype_method]=__dbl__Class__add_prototype_method
  [prototype_attribute]=__dbl__Class__add_prototype_attribute
  [prototype_reference]=__dbl__Class__add_prototype_reference
  [new]=__dbl__Class__new
)

declare -Agr __dbl__Class__prototype=(
  [__methods__]=__dbl__Class__prototype__methods
)

declare -Agr __dbl__Class__static_methods=(
  [define]=__dbl__Class__static__define
)

declare -A __dbl__Class__classdef=(
  [prototype]=__dbl__Class__prototype
  [static_methods]=__dbl__Class__static_methods
)

__dbl__Class__static__define Class __dbl__Class__classdef || exit

unset __dbl__Class__classdef

#################################################################################
## Object
#################################################################################
declare -Agr __dbl__Object__prototype__methods=(
  [__init]=__dbl__Object__init
  [inspect]=__dbl__Object__inspect
  [read_attribute]=__dbl__Object__read_attribute
  [write_attribute]=__dbl__Object__write_attribute
  [has_method]=__dbl__Object__has_method
  [add_method]=__dbl__Object__add_method
  [add_reference]=__dbl__Object__add_reference
  [add_getter]=__dbl__Object__add_getter
  [add_setter]=__dbl__Object__add_setter
  [assign_reference]=__dbl__Object__assign_reference
  [_get_id_]=__dbl__Object__get_id_
  [_get_class_]=__dbl__Object__get_class_
)

declare -Agr __dbl__Object__prototype=(
  [__methods__]=__dbl__Object__prototype__methods
)

declare -Agr __dbl__Object__static_methods=(
  [generate_id]=__dbl__Object__static__generate_id
)

declare -A __dbl__Object__classdef=(
  [prototype]=__dbl__Object__prototype
  [static_methods]=__dbl__Object__static_methods
)

__dbl__Class__static__define Object __dbl__Object__classdef || exit

unset __dbl__Object__classdef

################################################################################
# Array
################################################################################
declare -Agr __dbl__Array__prototype__methods=(
  [__init]=__dbl__Array__init
  [at]=__dbl__Array__at
  [shift]=__dbl__Array__shift
  [unshift]=__dbl__Array__unshift
  [push]=__dbl__Array__push
  [pop]=__dbl__Array__pop
  [sort]=__dbl__Array__sort
  [contains]=__dbl__Array__contains
  [to_array]=__dbl__Array__to_array
)

declare -Agr __dbl__Array__prototype__attributes=(
  [size]=$__dbl__attr__getter
)

declare -Agr __dbl__Array__prototype=(
  [__methods__]=__dbl__Array__prototype__methods
  [__attributes__]=__dbl__Array__prototype__attributes
)

declare -Agr __dbl__Array__static_methods=(
  [is_array]=__dbl__Array__static__is_array
  [at]=__dbl__Array__static__at
  [shift]=__dbl__Array__static__shift
  [unshift]=__dbl__Array__static__unshift
  [push]=__dbl__Array__static__push
  [pop]=__dbl__Array__static__pop
  [sort]=__dbl__Array__static__sort
  [contains]=__dbl__Array__static__contains
  [to_array]=__dbl__Array__static__to_array
)

declare -A __dbl__Array__classdef=(
  [prototype]=__dbl__Array__prototype
  [static_methods]=__dbl__Array__static_methods
)

$Object.extend Array __dbl__Array__classdef || exit

unset __dbl__Array__classdef

################################################################################
# Dict
################################################################################

declare -Agr __dbl__Dict__prototype__methods=(
  [__init]=__dbl__Dict__init
  [set]=__dbl__Dict__set
  [get]=__dbl__Dict__get
  [has_key]=__dbl__Dict__has_key
  [to_associative_array]=__dbl__Dict__to_associative_array
)

declare -Agr __dbl__Dict__prototype__attributes=(
  [size]=$__dbl__attr__getter
)

declare -Agr __dbl__Dict__prototype=(
  [__methods__]=__dbl__Dict__prototype__methods
  [__attributes__]=__dbl__Dict__prototype__attributes
)

declare -Agr __dbl__Dict__static_methods=(
  [get]=__dbl__Dict__static__get
  [set]=__dbl__Dict__static__set
  [has_key]=__dbl__Dict__static__has_key
)

declare -A __dbl__Dict__classdef=(
  [prototype]=__dbl__Dict__prototype
  [static_methods]=__dbl__Dict__static_methods
)

$Object.extend Dict __dbl__Dict__classdef || exit
# __dbl__Class__extend Object Dict __dbl__Dict__classdef || exit

unset __dbl__Dict__classdef

################################################################################
# Error
################################################################################
declare -Agr __dbl__Error__static_methods=(
  [argument]=__dbl__Error__static__argument_error
  [undefined_method]=__dbl__Error__static__undefined_method_error
  [illegal_instruction]=__dbl__Error__static__illegal_instruction_error
)

declare -A __dbl__Error__classdef=(
  [static_methods]=__dbl__Error__static_methods
)

__dbl__Class__static__define Error __dbl__Error__classdef || exit

unset __dbl__Error__classdef

################################################################################
# Util
################################################################################
declare -Agr __dbl__Util__static_methods=(
  [is_defined]=__dbl__Util__static__is_defined
  [is_function]=__dbl__Util__static__is_function
  [is_associative_array]=__dbl__Util__static__is_associative_array
  [dump_associative_array]=__dbl__Util__static__dump_associative_array
  [dump_object]=__dbl__Util__static__dump_object
)

declare -A __dbl__Util__classdef=(
  [static_methods]=__dbl__Util__static_methods
)

__dbl__Class__static__define Util __dbl__Util__classdef || exit

unset __dbl__Util__classdef

# vim: ts=2:sw=2:expandtab
