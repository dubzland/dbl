#!/usr/bin/env bash

function __hbl__Dict__static__get_() {
  local -n _raw="$1"
  local -n val_var__ref="$3"
  val_var__ref="${_raw[$2]}"

  return 0
}

function __hbl__Dict__static__get() {
  [[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] || $Error.argument || return
  __hbl__Util__static__is_associative_array "$1" || $Error.argument || return

  __hbl__Dict__static__get_ "$@"
}

function __hbl__Dict__static__set_() {
  local -n _raw="$1"
  _raw[$2]="$3"

  return 0
}

function __hbl__Dict__static__set() {
  [[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] || $Error.argument || return
  __hbl__Util__static__is_associative_array "$1" || $Error.argument || return

  __hbl__Dict__static__set_ "$@"
}

function __hbl__Dict__static__has_key_() {
  local -n _raw="$1"

  [[ -v _raw[$2] ]]
}

function __hbl__Dict__static__has_key() {
  [[ $# -eq 2 && -n "$1" && -n "$2" ]] || $Error.argument || return
  __hbl__Util__static__is_associative_array "$1" || $Error.argument || return

  __hbl__Dict__static__has_key_ "$@"
}

function __hbl__Dict__init() {
  [[ $# -eq 0 ]] || $Error.argument || return

  __hbl__Object__init || return

  this[_raw]="${!this}__raw_dict"
  this[size]=0
  declare -Ag "${this[_raw]}"
  local -n _raw="${this[_raw]}"
  _raw=()
}

function __hbl__Dict__get() {
  [[ $# -eq 2 && -n "$1" && -n "$2" ]] || $Error.argument || return

  __hbl__Dict__static__get_ "${this[_raw]}" "$@"
}

function __hbl__Dict__set() {
  [[ $# -eq 2 && -n "$1" ]] || $Error.argument || return

  __hbl__Dict__static__set_ "${this[_raw]}" "$@" || return

  local -n _raw="${this[_raw]}"

  this[size]=${#_raw[@]}
}

function __hbl__Dict__has_key() {
  [[ $# -eq 1 && -n "$1" ]] || $Error.argument || return

  __hbl__Dict__static__has_key_ "${this[_raw]}" "$@"
}

function __hbl__Dict__to_associative_array() {
  [[ $# -eq 1 && -n "$1" ]] || $Error.argument || return

  local -n src__ref="${this[_raw]}"
  local -n tgt__ref="$1"

  for key in "${!src__ref[@]}"; do
    tgt__ref[$key]="${src__ref[$key]}"
  done

  return 0
}

# vim: noai:ts=2:sw=2:et
