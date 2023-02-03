##!/usr/bin/env bash

function __hbl__Dict__init() {
  [[ $# -eq 0 ]] || $Error.argument || return

  $this.super || return

  this[_raw]="${!this}__raw_dict"
  this[size]=0
  declare -Ag "${this[_raw]}"
  local -n _raw="${this[_raw]}"
  _raw=()
}

function __hbl__Dict__set() {
  [[ $# -eq 2 && -n "$1" ]] || $Error.argument || return

  local -n _raw="${this[_raw]}"
  _raw[$1]="$2"
  this[size]=${#_raw[@]}

  return 0
}

function __hbl__Dict__get() {
  [[ $# -eq 2 && -n "$1" && -n "$2" ]] || $Error.argument || return

  local -n _raw="${this[_raw]}"
  local -n val_var__ref="$2"
  val_var__ref="${_raw[$1]}"

  return 0
}

function __hbl__Dict__has_key() {
  [[ $# -eq 1 && -n "$1" ]] || $Error.argument || return

  local -n _raw="${this[_raw]}"

  [[ -v _raw[$1] ]]
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
