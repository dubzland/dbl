#!/usr/bin/env bash

# shellcheck disable=2015
[[ -v __dbl__imported && $__dbl__imported -eq 1 ]] && return || true

declare -ir __dbl__force_bash4=${FORCE_BASH4:-0}

function __dbl__dump_object_() {
  local -n this="$1"
  printf "=== %s ===\n" "$1"
  for key in "${!this[@]}"; do
    printf "%-20s %s\n" "${key}:" "${this[$key]}"
  done
}

function __dbl__dump_entry_() {
  printf "*** %s ***\n" "${FUNCNAME[1]}"
  printf "args: %s\n" "${@}"
  printf "**********\n"
}

function __dbl__dump_stack_() {
  printf "\n* * * * * S T A C K * * * * *\n"
  for item in "${__dbl__stack[@]}"; do
    printf "%s\n" "$item"
  done
  printf "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^\n\n"
}

function __dbl__dump_array_() {
  local item
  local -n this="$1"

  printf "\n* * * * * %s * * * * *\n" "$1"
  for item in "${this[@]}"; do
    printf "%s\n" "$item"
  done

  printf "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^\n\n"
}

# shellcheck source=lib/dbl/core.bash
source "${BASH_SOURCE%/*}/dbl/core.bash"     &&
# shellcheck source=lib/dbl/commands.bash
source "${BASH_SOURCE%/*}/dbl/commands.bash" || exit

declare -g __dbl__imported
__dbl__imported=1

# vim: ts=2:sw=2:expandtab
