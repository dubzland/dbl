#!/usr/bin/env bash

function __hbl__Class__static__define() {
  local name new_cls new_cls_id
  name="$1" new_cls="" new_cls_id=""

  __hbl__Object__new "$name" || return

  local -n cls__ref="$name"
  cls__ref[__class__]=Class
  cls__ref[__superclass__]=Object

  if [[ $# -gt 1 ]]; then
    local -n classdef__ref="$2"
    if [[ -v classdef__ref[prototype] ]]; then
      cls__ref[__prototype__]="${classdef__ref[prototype]}"
    fi

    if [[ -v classdef__ref[static_methods] ]]; then
      cls__ref[__static_methods__]="${classdef__ref[static_methods]}"
    fi

    if [[ -v classdef__ref[static_references] ]]; then
      cls__ref[__static_references__]="${classdef__ref[static_references]}"
    fi

    if [[ -v classdef__ref[references] ]]; then
      cls__ref[__references__]="${classdef__ref[references]}"
    fi
  fi

  return 0
}

function __hbl__Class__extend() {
  __hbl__Class__static__define "$@"

  if [[ "${!this}" != Class ]]; then
    local -n cls__ref="$1"
    cls__ref[__superclass__]="${!this}"
  fi

  return 0
}

function __hbl__Class__add_static_method() {
  [[ $# -eq 2 && -n "$1" && -n "$2" ]] || $Error.argument || return
  __hbl__Util__static__is_function "$2" || $Error.argument || return

  # local -n cls__ref="$1"

  if [[ ! -v this[__static_methods__] ]]; then
    this[__static_methods__]="${this[__id__]}__static_methods"
    declare -Ag "${this[__static_methods__]}"
  fi

  local -n smethods__ref="${this[__static_methods__]}"
  smethods__ref[$1]="$2"

  return 0
}

function __hbl__Class__add_static_reference() {
  __hbl__Object__add_reference "${this[__id__]}" "$1" "$2"

  return 0
}

function __hbl__Class__add_prototype_method() {
  [[ $# -eq 2 && -n "$1" && -n "$2" ]] || $Error.argument || return
  __hbl__Util__static__is_function "$2" || $Error.argument || return

  if [[ ! -v this[__prototype__] ]]; then
    this[__prototype__]="${this[__id__]}__prototype"
    declare -Ag "${this[__prototype__]}"
  fi

  local -n cproto__ref="${this[__prototype__]}"

  if [[ ! -v cproto__ref[__methods__] ]]; then
    cproto__ref[__methods__]="${!cproto__ref}__methods"
    declare -Ag "${cproto__ref[__methods__]}"
  fi

  local -n pmethods__ref="${cproto__ref[__methods__]}"
  pmethods__ref[$1]="$2"

  return 0
}

function __hbl__Class__add_prototype_attribute() {
  [[ $# -ge 1 && -n "$1" ]] || $Error.argument || return

  local access

  if [[ ! -v this[__prototype__] ]]; then
    this[__prototype__]="${this[__id__]}__prototype"
    declare -Ag "${this[__prototype__]}"
  fi

  local -n cproto__ref="${this[__prototype__]}"

  if [[ ! -v cproto__ref[__attributes__] ]]; then
    cproto__ref[__attributes__]="${!cproto__ref}__attributes"
    declare -Ag "${cproto__ref[__attributes__]}"
  fi

  local -n pattributes__ref="${cproto__ref[__attributes__]}"

  if [[ $# -gt 1 ]]; then
    access=$2
  else
    access=$__hbl__attr__both
  fi
  pattributes__ref["$1"]=$access

  return 0
}

function __hbl__Class__add_prototype_reference() {
  [[ $# -eq 2 && -n "$1" && -n "$2" ]] || $Error.argument || return

  if [[ ! -v this[__prototype__] ]]; then
    this[__prototype__]="${this[__id__]}__prototype"
    declare -Ag "${this[__prototype__]}"
  fi

  local -n cproto__ref="${this[__prototype__]}"

  if [[ ! -v cproto__ref[__references__] ]]; then
    cproto__ref[__references__]="${!cproto__ref}__references"
    declare -Ag "${cproto__ref[__references__]}"
  fi

  local -n preferences__ref="${cproto__ref[__references__]}"
  preferences__ref["$1"]="$2"

  return 0
}

function __hbl__Class__new_() {
  local obj key cls init icls
  init="" icls=""
  local -n self="$1"
  local -n id__ref="$2"
  shift 2

  # Build the object
  __hbl__Object__static__generate_id "${self[__id__]}" obj
  __hbl__Object__new "$obj" || return


  local -n obj__ref="$obj"
  obj__ref[__class__]="${self[__id__]}"

  cls="${obj__ref[__class__]}"

  while [[ -n "$cls" ]]; do
    local -n cls__ref="$cls"

    if [[ -v cls__ref[__prototype__] ]]; then
      local -n cproto__ref="${cls__ref[__prototype__]}"

      if [[ -v cproto__ref[__methods__] ]]; then
        local -n cmethods__ref="${cproto__ref[__methods__]}"

        for key in "${!cmethods__ref[@]}"; do
          if ! __hbl__Object__has_method_ "${!obj__ref}" "$key"; then
            __hbl__Object__add_method_ "${!obj__ref}" "$key" "${cmethods__ref[$key]}" || return
          fi

          if [[ "$key" = '__init' && -z "$init" ]]; then
            init="${cmethods__ref[$key]}"
            icls="$cls"
          fi
        done
      fi

      if [[ -v cproto__ref[__attributes__] ]]; then
        local -n cattrs__ref="${cproto__ref[__attributes__]}"

        for key in "${!cattrs__ref[@]}"; do
          local attr_flag="${cattrs__ref[$key]}"
          if [[ $((attr_flag & __hbl__attr__getter)) -gt 0 ]]; then
            __hbl__Object__add_getter_ "${!obj__ref}" "$key" || return
          fi

          if [[ $((attr_flag & __hbl__attr__setter)) -gt 0 ]]; then
            __hbl__Object__add_setter_ "${!obj__ref}" "$key" || return
          fi

          obj__ref[$key]=''
        done
      fi

      if [[ -v cproto__ref[__references__] ]]; then
        local -n creferences__ref="${cproto__ref[__references__]}"
        for key in "${!creferences__ref[@]}"; do
          local ref_class="${creferences__ref[$key]}"
          __hbl__Object__add_reference_ "${!obj__ref}" "$key" || return
        done
      fi
    fi

    if [[ -v cls__ref[__superclass__] && "${cls__ref[__superclass__]}" != "$cls" ]]; then
      cls="${cls__ref[__superclass__]}"
      continue
    fi
    cls=""
  done

  # Return the dispatcher
  id__ref="${obj__ref[0]}"

  if [[ -n "$init" ]]; then
    local -A frame
    frame=(
      [object]="${obj[__id__]}"
      [method]='__init'
      [class]="${icls}"
      [function]="${init}"
    )

    __hbl__Object__push_frame_ frame "$@"
  else
    return 0
  fi
}

function __hbl__Class__new() {
  [[ $# -ge 1 && -n "$1" ]] || $Error.argument || return

  __hbl__Class__new_ "${!this}" "$@"
}

function __hbl__Class__inspect() {
  [[ $# -eq 0 ]] || $Error.argument || return

  printf "<Class:%s>\n" "${this[__id__]}"
}

# vim: ts=2:sw=2:expandtab
