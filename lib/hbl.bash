#!/usr/bin/env bash

# shellcheck disable=2015
[[ -v __hbl__imported && $__hbl__imported -eq 1 ]] && return || true

declare -ir __hbl__force_bash4=${FORCE_BASH4:-0}

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

# shellcheck source=lib/hbl/core.bash
source "${BASH_SOURCE%/*}/hbl/core.bash"     &&
# shellcheck source=lib/hbl/commands.bash
source "${BASH_SOURCE%/*}/hbl/commands.bash" || exit

declare -g __hbl__imported
__hbl__imported=1

# vim: ts=2:sw=2:expandtab
