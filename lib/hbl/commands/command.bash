#!/usr/bin/env bash

function __hbl__Command__init() {
  [[ $# -eq 2 && -n "$1" && -n "$2" ]]  || $Error.argument || return

  local examples options subcommands

  $this.super || return

  this[name]="$1"
  this[entrypoint]="$2"
  this[description]=""

  __hbl__Class__new_ Array examples    || return
  __hbl__Class__new_ Dict options      || return
  __hbl__Class__new_ Array subcommands || return

  __hbl__Object__assign_reference_ \
    "${!this}" examples "$examples" || return
  __hbl__Object__assign_reference_ \
    "${!this}" options "$options" || return
  __hbl__Object__assign_reference_ \
    "${!this}" subcommands "$subcommands" || return

  return 0
}

function __hbl__Command__add_example() {
  [[ $# -eq 1 && -n "$1" ]]  || $Error.argument || return

  $this.examples.push "$1"

  return 0
}

function __hbl__Command__add_option() {
  local opt opt_name options
  opt="$1"

  $opt.assign_reference command "$this" || return
  $opt.get_name opt_name                || return

  $this.options.set "$opt_name" "$opt" || return
}

function __hbl__Command__add_subcommand() {
  local sub subcommands

  $this.subcommands.push "$1"
}

# vim: noai:ts=2:sw=2:et
