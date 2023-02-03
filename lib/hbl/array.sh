#!/usr/bin/env bash
# @name Array
# @brief A library for interacting with Bash arrays.

###############################################################################
# @description Determine whether or not a variable is a bash array.
#
# @example
#    $Array.is_array myvar
#
# @arg $1 string A variable name to check
#
# @exitcode 0 If successful.
# @exitcode 1 If the argument is not an array
#
function __hbl__Array__static__is_array() {
  [[ $# -eq 1 && -n "$1" ]] || $Error.argument || return
  __hbl__Util__static__is_defined "$1" || $Error.argument || return

  if [[ ${BASH_VERSINFO[0]} -ge 5 && $__hbl__force_bash4 -ne 1 && -z ${-//[^u]/} ]]; then
    local -n __ref="$1"
    [[ "${__ref@a}" = *a* ]]
  else
    [[ "$(declare -p "$1" 2>/dev/null)" == "declare -a"* ]]
  fi
}

###############################################################################
# @description Extract array element at the specified position
#
# @example
#    $Array.at myarr 1 myvar
#
# @arg $1 string A bash array name
# @arg $2 number Index of the array element to be retrieved
# @arg $3 string Name of the var to hold the extracted value
#
# @exitcode 0 If successful.
# @exitcode 1 If the array item does not exist
#
function __hbl__Array__static__at() {
  [[ $# -eq 3 && -n $1 && -n $2 && -n $3 ]] || $Error.argument || return
  __hbl__Array__static__is_array "$1" || $Error.argument || return

  local -n arr__ref="$1"
  local arr_size=${#arr__ref[@]}

  [[ $2 -lt $arr_size && $2 -gt $((0-arr_size)) ]] ||
    $Error.argument || return

  local -n ret__ref=$3
  ret__ref=${arr__ref[$2]}

  return 0
}

###############################################################################
# @description Remove (and optionally return) the first element of a bash array.
#
# @example
#    $Array.shift myarr
#
# @arg $1 string A bash array name
# @arg $2 string Name of a variable to hold the removed value (Optional)
#
# @exitcode 0 If successful.
# @exitcode 1 If the array is empty
#
function __hbl__Array__static__shift() {
  [[ $# -ge 1 && -n "$1" ]] || $Error.argument || return
  __hbl__Array__static__is_array "$1" || $Error.argument || return

  local -n __ref=$1

  [[ ${#__ref[@]} -gt 0 ]] ||
    $Error.illegal_instruction || return

  if [[ $# -gt 1 ]]; then
    local -n ret__ref="$2"
    ret__ref="${__ref[0]}"
  fi
  __ref=("${__ref[@]:1}")

  return 0
}

###############################################################################
# @description Prepend a value to the beginning of a bash array.
#
# @example
#    $Array.unshift myarr 'value'
#
# @arg $1 string A bash array name
# @arg $2 string Value to be prepended (more values may be specified)
#
# @exitcode 0 If successful.
# @exitcode 1 If the array is empty
#
function __hbl__Array__static__unshift() {
  [[ $# -ge 2 && -n "$1" ]] || $Error.argument || return
  __hbl__Array__static__is_array "$1" || $Error.argument || return

  local -n __ref=$1; shift
  __ref=("$@" "${__ref[@]}")

  return 0
}

###############################################################################
# @description Append a value to the end of a bash array.
#
# @example
#    $Array.push myarr 'value'
#
# @arg $1 string A bash array name
# @arg $2 string Value to be appended (more values may be specified)
#
# @exitcode 0 If successful.
#
function __hbl__Array__static__push() {
  [[ $# -ge 2 && -n "$1" ]] || $Error.argument || return
  __hbl__Array__static__is_array "$1" || $Error.argument || return

  local -n __ref="$1"; shift
  __ref+=("$@")

  return 0
}

###############################################################################
# @description Removes (and optionally returns) the last value from a bash array.
#
# @example
#    $Array.pop myarr
#
# @arg $1 string A bash array name
# @arg $2 string Variable name to hold the popped value (Optional)
#
# @exitcode 0 If successful.
# @exitcode 1 Empty array was passed
#
function __hbl__Array__static__pop() {
  [[ $# -ge 1 && -n "$1" ]] || $Error.argument || return
  __hbl__Array__static__is_array "$1" || $Error.argument || return

  local -n __ref="$1"; shift

  [[ ${#__ref[@]} -gt 0 ]] || $Error.argument || return

  if [[ $# -eq 1 ]]; then
    local -n var__ref="$1"
    var__ref="${__ref[-1]}"
  fi

  unset __ref[-1];

  return 0
}

###############################################################################
# @description Sorts the bash array in-place (using  bubble-sort algorithm).
#
# @example
#    $Array.pop myarr
#
# @arg $1 string A bash array name
#
# @exitcode 0 If successful.
#
function __hbl__Array__static__sort() {
  [[ $# -eq 1 && -n "$1" ]] || $Error.argument || return
  __hbl__Array__static__is_array "$1" || $Error.argument || return

  local -n __ref="$1"

  if [[ ${#__ref[@]} -gt 0 ]]; then

    local swapped tmp
    swapped=0 tmp=""

    local -a sortable

    sortable=("${__ref[@]}")

    for ((i = 0; i < ${#sortable[@]}; i++)); do
      for(( j = 0; j < ${#sortable[@]}-i-1; j++)); do
        if [[ "${sortable[j]}" > "${sortable[$((j+1))]}" ]]; then
          tmp=${sortable[j]}
          sortable[$j]=${sortable[$((j+1))]}
          sortable[$((j+1))]=$tmp
          swapped=1
        fi
      done
      [[ $swapped -eq 0 ]] && break
    done
    __ref=("${sortable[@]}")
  fi

  return 0
}

###############################################################################
# @description Checks for the existence of a value in a bash array.
#
# @example
#    $Array.contains myarr 'needle'
#
# @arg $1 string A bash array name
# @arg $2 string Value to search for
#
# @exitcode 0 If the value is present
# @exitcode 1 If the value is not present
#
function __hbl__Array__static__contains() {
  [[ $# -eq 2 && -n "$1" ]] || $Error.argument || return
  __hbl__Array__static__is_array "$1" || $Error.argument || return

  local val=""
  local -n __ref="$1"; shift
  [[ ${#__ref[@]} -gt 0 ]] || return 1

  for val in "${__ref[@]}"; do
    [[ "$val" = "$1" ]] && return 0
  done

  return 1
}

function __hbl__Array__init() {
  $this.super || return

  this[_raw]="${this[__id__]}__raw_array"
  declare -ag "${this[_raw]}"
  local -n _raw="${this[_raw]}"
  _raw=("$@")
  this[size]=${#_raw[@]}
}

function __hbl__Array__at() {
  [[ $# -eq 2 && -n "$1" && -n "$2" ]] || $Error.argument || return

  __hbl__Array__static__at "${this[_raw]}" "$@"
}

function __hbl__Array__shift() {
  local -n _raw="${this[_raw]}"

  __hbl__Array__static__shift "${this[_raw]}" "$@" || return

  this[size]=${#_raw[@]}

  return 0
}

function __hbl__Array__unshift() {
  [[ $# -ge 1 ]] || $Error.argument || return
  local -n _raw="${this[_raw]}"

  __hbl__Array__static__unshift "${this[_raw]}" "$@" || return

  this[size]=${#_raw[@]}

  return 0
}

function __hbl__Array__push() {
  [[ $# -ge 1 ]] || $Error.argument || return

  __hbl__Array__static__push "${this[_raw]}" "$@" || return

  this[size]=${#_raw[@]}

  return 0
}

function __hbl__Array__pop() {
  local -n _raw="${this[_raw]}"

  __hbl__Array__static__pop "${this[_raw]}" "$@" || return

  this[size]=${#_raw[@]}

  return 0
}

function __hbl__Array__sort() {
  [[ $# -eq 0 ]] || $Error.argument || return

  __hbl__Array__static__sort "${this[_raw]}" || return

  return 0
}

function __hbl__Array__contains() {
  [[ $# -ge 1 ]] || $Error.argument || return

  __hbl__Array__static__contains "${this[_raw]}" "$@"
}

function __hbl__Array__to_array() {
  [[ $# -eq 1 && -n "$1" ]] || $Error.argument || return

  local -n _raw="${this[_raw]}"
  local -n tgt__ref="$1"
  tgt__ref=("${_raw[@]}")

  return 0
}

# vim: noai:ts=2:sw=2:et
