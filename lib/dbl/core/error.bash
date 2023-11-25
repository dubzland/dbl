#!/usr/bin/env bash

function __dbl__Error__static__argument_error() {
  return $__dbl__rc__argument_error
}

function __dbl__Error__static__undefined_method_error() {
  return $__dbl__rc__undefined_method
}

function __dbl__Error__static__illegal_instruction_error() {
  return $__dbl__rc__illegal_instruction
}

# function Error__static__invocation() {
#   [[ $# -ge 1 ]] || exit 99

#   local _eargs
#   _eargs=''

#   [[ $# -gt 1 ]] && printf -v _eargs "'%s'," "${@:2}"

#   $Error._display 2 HBL_ERR_INVOCATION \
#     "invalid arguments to '$1' -- [${_eargs%,}]"

#   return $HBL_ERR_INVOCATION
# }

# function Error__static__argument() {
#   [[ $# -eq 3 && -n "$1" && -n "$2" ]] || exit 99

#   $Error._display 2 HBL_ERR_ARGUMENT \
#     "invalid argument to '$1' for '$2' -- '$3'"

#   return $HBL_ERR_ARGUMENT
# }

# function Error__static__undefined() {
#   [[ $# -eq 1 && -n "$1" ]] || exit 99

#   $Error._display 2 HBL_ERR_UNDEFINED \
#     "variable is undefined -- '$1'"

#   return $HBL_ERR_UNDEFINED
# }

# function Error__static__already_defined() {
#   [[ $# -eq 1 && -n "$1" ]] || exit 99

#   $Error._display 2 HBL_ERR_ALREADY_DEFINED \
#     "variable is already defined -- '$1'"

#   return $HBL_ERR_ALREADY_DEFINED
# }

#function Error__static__undefined_method() {
# [[ $# -eq 2 && -n "$1" && -n "$2" ]] || exit 99

# $Error._display 2 HBL_ERR_UNDEFINED_METHOD \
#   "$1 does not respond to method -- '$2'"

# return $HBL_ERR_UNDEFINED_METHOD
#}

## function Error__static__illegal_instruction() {
##  [[ $# -eq 2 && -n "$1" && -n "$2" ]] || exit 99

##  $Error._display 2 HBL_ERR_ILLEGAL_INSTRUCTION \
##    "illegal instruction ($1) -- '$2'"

##  return $HBL_ERR_ILLEGAL_INSTRUCTION
## }

#function Error__static__display_() {
# [[ $# -eq 3 ]] || exit 99
# local -i offset
# local code_string message
# offset=$1 code_string="$2" message="$3"

# if [[ $TRACE -gt 0 ]]; then

#   printf "Backtrace (most recent call last):\n" >&2

#   for ((i = ${#FUNCNAME[@]}-1; i > offset+1; i--)); do
#     printf "  [%s] %s:%s:in '%s'\n" \
#       $((i-offset-1)) \
#       "${BASH_SOURCE[i]/$HBL_LIB/<dbl>}" \
#       "${BASH_LINENO[i-1]}" \
#       "${FUNCNAME[i]}" >&2
#   done

#   printf "%s:%s:in '%s': %s (%s)\n" \
#     "${BASH_SOURCE[$offset+1]/$HBL_LIB/<dbl>}" \
#     "${BASH_LINENO[$offset]}" \
#     "${FUNCNAME[$offset+1]}" \
#     "${message}" \
#     "${code_string}" >&2
# else
#   printf "%s: %s\n" "${FUNCNAME[$offset+1]}" "${message}" >&2
# fi
#}

#################################################################################
## Error
#################################################################################
#declare -Ag Error__methods
#Error__methods=(
# [invocation]=Error__static__invocation
# [argument]=Error__static__argument
# [undefined]=Error__static__undefined
# [already_defined]=Error__static__already_defined
# [undefined_method]=Error__static__undefined_method
# [illegal_instruction]=Error__static__illegal_instruction
# [_display]=Error__static__display_
#)
#readonly Error__methods

#declare -Ag Error
#Error=(
# [0]='__dbl__Class__static__dispatch_ Error '
# [__name]=Error
# [__base]=Object
# [__methods]=Error__methods
#)
#readonly Error

#__dbl__classes+=('Error')

# vim: noai:ts=2:sw=2:et
