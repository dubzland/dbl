#!/usr/bin/env bash

# @name Profiler
# @brief A library for profiling bash code

function __dbl__Profiler__init() {
  local -n this="$1"

  this[_sort_by]='average'

  return $HBL_SUCCESS
}

function __dbl__Profiler__sort_by() {
  [[ $# -ge 2 && -n "$1" && -n "$2" ]] || return $HBL_ERR_ARGUMENT
  local -n this="$1"
  case "$2" in
    average) this[_sort_by]='average' ;;
    total) this[_sort_by]='total' ;;
    call_count) this[_sort_by]='call_count' ;;
    ?) printf "Invalid sort field: %s\n" >&2 && return 1
  esac

  return $HBL_SUCCESS
}

function __dbl__Profiler__execute() {
  return $HBL_SUCCESS
}

function __dbl__Profiler__report() {
  return $HBL_SUCCESS
}

################################################################################
# Array
################################################################################
declare -Ag __dbl__Profiler__prototype
__dbl__Profiler__prototype=(
  [__init]="$HBL_SELECTOR_METHOD __dbl__Profiler__init"
  [sort_by]="$HBL_SELECTOR_METHOD __dbl__Profiler__sort_by"
  [start]="$HBL_SELECTOR_METHOD __dbl__Profiler__execute"
  [report]="$HBL_SELECTOR_METHOD __dbl__Profiler__report"
)
readonly __dbl__Profiler__prototype

declare -Ag Profiler
Profiler=(
  [0]='__dbl__Class__static__dispatch_ Profiler '
  [__name]=Profiler
  [__base]=Class
  [__prototype]=__dbl__Profiler__prototype
)
readonly Profiler

__dbl__classes+=('Profiler')

# vim: noai:ts=2:sw=2:et
