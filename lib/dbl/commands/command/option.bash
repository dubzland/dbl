#!/usr/bin/env bash

function __dbl__Command__Option__init() {
  [[ $# -eq 1 && -n "$1" ]] || $Error.argument || return

  __dbl__Object__init || return

  this[name]="$1"
  this[type]=""
  this[short_flag]=""
  this[long_flag]=""
  this[description]=""

  return 0
}

# vim: ts=2:sw=2:expandtab
