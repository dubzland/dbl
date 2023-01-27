#!/usr/bin/env bash

###############################################################################
# Person
###############################################################################
function Person__init() {
  local -n this="$1"; shift

  this[id]="$1"
  this[name]="$2"
}

function Person__say_hello() {
  local -n this="$1"; shift

  printf "Hello from %s!\n" "${this[name]}"
}

$Object.extend Person
  $Person.attribute id  $((__hbl__attr__getter | __hbl__attr__setter))
  $Person.attribute name $((__hbl__attr__getter | __hbl__attr__setter))

  $Person.method __init    Person__init
  $Person.method say_hello Person__say_hello


