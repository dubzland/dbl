#!/usr/bin/env bash

function __hbl__Command__init() {
  [[ $# -eq 1 && -n "$1" ]]  || $Error.argument || return

  local examples options subcommands

  __hbl__Object__init || return
  # $this.super || return

  this[name]="$1"
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

function __hbl__Command__usage() {
  local command_name example_count i
  local -a command_examples
  command_name="" command_examples=()

  $this.get_name command_name

  printf "Usage:\n"

  $this.examples.get_size example_count
  if [[ $example_count -gt 0 ]]; then
    for ((i=0; i < $example_count; i++)); do
      local example
      $this.examples.at $i example
      command_examples+=("$command_name $example")
    done
  fi

  if [[ ${#command_examples[@]} -gt 0 ]]; then
    for ex in "${command_examples[@]}"; do
      printf "%s%s\n" "  " "$ex"
    done
  else
    printf "%s%s <options>\n" "  " "$command_name"
  fi
  printf "\n"

  if [[ ${#this[description]} -gt 0 ]]; then
    printf "Description:\n"
    printf "%s%s\n" "  " "${this[description]}"
  fi

  printf "\n"

  return 0
}

# vim: noai:ts=2:sw=2:et
