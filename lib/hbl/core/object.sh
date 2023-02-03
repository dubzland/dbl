#!/usr/bin/env bash
# @name Object
# @brief Object related functions

function __hbl__Object__static__generate_id() {
  local cls
  cls="$1"
  local -n obj_id__ref="$2"
  obj_id__ref="__hbl__${cls}__${__hbl__object__id}"
  __hbl__object__id=$((__hbl__object__id+1))
}

function __hbl__Object__get_id_() {
  [[ $# -eq 1 && -n "$1" ]] || $Error.argument || return
  local -n val__ref="$1"
  val__ref="${this[__id__]}"
}

function __hbl__Object__get_class_() {
  [[ $# -eq 1 && -n "$1" ]] || $Error.argument || return
  local -n val__ref="$2"
  val__ref="${this[__class__]}"
}

function __hbl__Object__delegate_to_reference_() {
  [[ $# -ge 2 && -n "$1" && -n "$2" ]] || $Error.argument || return

  __hbl__Object__dispatch_ "${this[__ref_$1]}" "$2" "${@:3}"
}

function __hbl__Object__push_frame_() {
  [[ $# -ge 1 && -n "$1" ]] || $Error.argument || return

  local rc=0
  local -n frame__ref="$1" && shift

  if [[ -n "${frame[object]}" ]]; then
    # push a frame to the stack
    local frame_str
    printf -v frame_str "%q %q %q %q" \
      "${frame__ref[object]}" \
      "${frame__ref[method]}" \
      "${frame__ref[class]}" \
      "${frame__ref[function]}"

    __hbl__stack+=("${frame_str}")
    local -n this="${frame__ref[object]}"

    # run the function
    ${frame__ref[function]} "$@" || rc=$?

    # pop the stack
    unset __hbl__stack[-1]
  else
    # static methods don't need anything on the stack
    ${frame__ref[function]} "$@" || rc=$?
  fi

  return $rc
}

function __hbl__Object__dispatch_() {
  [[ $# -ge 2 && -n "$1" && -n "$2" && "$2" =~ ^\. ]] ||
    $Error.argument || return

  ###########################################################################
  #
  # This is where we process all methods called on "objects" within the
  # system.  As an example, imagine we have the following Classes:
  #
  #   class Person
  #     attributes
  #       first_name
  #       last_name
  #     methods
  #       say_hello
  #     static_methods
  #       person_count
  #
  #   class Student
  #     references
  #       grades
  #     methods
  #       say_hello
  #
  # If we have a student john, we can expect the following method calls
  # and their resultant arguments to this function:
  #
  # $john.get_first_name first_name
  #
  #   $1: __hbl__Student_982
  #   $2: .get_first_name
  #   $3 first_name
  #
  # $john.grades.push 100
  #
  #   $1: __hbl__Student_982
  #   $2: .grades.push
  #   $3: 100
  #
  # $john.say_hello
  #
  #   $1: __hbl__Student_982
  #   $2: .grades.push
  #   $3: 100
  #
  # stored in a variable named `car`.
  #
  #   $car.set_color 'red'
  #
  # Will result in the following arguments:
  #
  #   $1: __hbl__Car__12345
  #   $2: .set_color
  #   $3: red
  #

  local selector lcls lfunc rc
  local -i resolved
  local -a pframe
  local -A frame

  frame[object]="$1" frame[method]="" frame[class]="" frame[function]=""
  selector="${2#\.}" lcls="" lfunc="" pframe=() resolved=0 rc=0
  shift 2
  # `selector` is whatever was specified as the "action" (ex. `.inspect`)
  # with the leading '.' removed.
  #
  # We need to split it into the method to be called and any trailing methods
  # that are part of a chain (for 
  frame[method]="${selector%%.*}"
  if [[ -n "${selector#${frame[method]}}" ]]; then
    set -- "${selector#${frame[method]}}" "$@"
  fi

  local -n __obj__ref="${frame[object]}"
  lcls="${__obj__ref[__class__]}"
  frame[class]="${lcls}"

  if [[ "${frame[method]}" = super ]]; then
    [[ ${#__hbl__stack[@]} -gt 0 ]] || {
      printf "no previous function call to execute super.\n";
      $Error.illegal_instruction || return
    }

    pframe=(${__hbl__stack[-1]})

    [[ "${frame[object]}" = "${pframe[0]}" ]] || return
    [[ "${FUNCNAME[1]}" = "${pframe[3]}" ]] || return


    # We're still in the last function we called.
    # Grab a reference to the last class we dispatched to and move
    # to its superclass.
    local -n scls__ref="${pframe[2]}"
    frame[class]="${scls__ref[__superclass__]}"
    frame[method]="${pframe[1]}"
  else
    if [[ "${frame[method]}" = class ]]; then
      # set the object to this object's class
      frame[object]="${frame[class]}"
      local -n ccls__ref="${frame[object]}"
      frame[class]="${ccls__ref[__class__]}"
      frame[method]="$1"
      frame[method]="${frame[method]%%.*}"
      set -- "${1#${frame[method]}}" "${@:2}"
      frame[method]="${frame[method]#\.}"
    fi

    local -n dobj__ref="${frame[object]}"
    if [[ -v dobj__ref[__methods__] ]]; then
      local -n dmethods__ref="${dobj__ref[__methods__]}"
      if [[ -v dmethods__ref[${frame[method]}] ]]; then
        frame[function]="${dmethods__ref[${frame[method]}]}"
        resolved=1
      fi
    fi
  fi

  if [[ $resolved -ne 1 ]]; then
    lcls="${frame[class]}"
    while [[ -n "$lcls" ]]; do
      local -n pcls__ref="$lcls"
      if [[ -v pcls__ref[__prototype__] ]]; then
        local -n cproto__ref="${pcls__ref[__prototype__]}"
        if [[ -v cproto__ref[__methods__] ]]; then
          local -n pmethods__ref="${cproto__ref[__methods__]}"
          if [[ -v pmethods__ref[${frame[method]}] ]]; then
            frame[class]="${lcls}"
            frame[function]="${pmethods__ref[${frame[method]}]}"
            resolved=1
            break
          fi
        fi
      fi

      if [[ -v pcls__ref[__superclass__] &&
        "${pcls__ref[__superclass__]}" != "$lcls" ]]; then
        lcls="${pcls__ref[__superclass__]}"
        continue
      fi
      lcls=""
    done
  fi

  if [[ $resolved -eq 1 ]]; then
    __hbl__Object__push_frame_ frame "$@"
    return
  fi

  lcls="${frame[object]}"
  while [[ -n "$lcls" ]]; do
    local -n mcls__ref="$lcls"
    if [[ -v mcls__ref[__static_methods__] ]]; then
      local -n cmethods__ref="${mcls__ref[__static_methods__]}"
      if [[ -v cmethods__ref[${frame[method]}] ]]; then
        frame[function]="${cmethods__ref[${frame[method]}]}"
        resolved=1
        break
      fi
    fi

    if [[ -v mcls__ref[__superclass__] &&
      "${mcls__ref[__superclass__]}" != "$lcls" ]]; then
      lcls="${mcls__ref[__superclass__]}"
      continue
    fi
    lcls=""
  done

  if [[ $resolved -eq 1 ]]; then
    # call the function
    frame[object]=''
    __hbl__Object__push_frame_ frame "$@"
    return
  fi

  $Error.undefined_method || exit
}

function __hbl__Object__new() {
  [[ $# -eq 1 && -n "$1" ]] || $Error.argument || return

  local id
  id="$1"

  declare -Ag "$id"

  local -n obj__ref="$id"

  obj__ref[0]="__hbl__Object__dispatch_ ${id} "
  obj__ref[__id__]="$id"

  __hbl__objects+=("${!obj__ref}")

  return 0
}

###############################################################################
# @description Display information about an object
#
# @example
#    $obj.inspect
#
# @exitcode 0 If successful.
#
function __hbl__Object__inspect() {
  [[ $# -eq 0 ]] || $Error.argument || return
  local -a attrs
  local attr
  printf "<%s" "${this[__id__]}"
  for attr in "${!this[@]}"; do
    attrs+=("$attr")
  done
  __hbl__Array__static__sort attrs
  for attr in "${attrs[@]}"; do
    [[ "$attr" =~ ^__ || "$attr" = "0" ]] && continue
    printf " %s='%s'" "$attr" "${this[$attr]}"
  done
  printf ">\n"
}

function __hbl__Object__has_method_() {
  local -n self="$1"

  if [[ -v self[__methods__] ]]; then
    local -n methods="${self[__methods__]}"
    [[ -v methods["$2"] ]]; return
  fi

  return 1
}

function __hbl__Object__has_method() {
  [[ $# -eq 1 && -n "$1" ]] || $Error.argument || return

  __hbl__Object__has_method_ "${!this}" "$1"
}

function __hbl__Object__add_method_() {
  local -n self="$1"

  if [[ ! -v self[__methods__] ]]; then
    self[__methods__]="${self[__id__]}__methods"
    declare -Ag "${self[__methods__]}"
  fi

  local -n omethods__ref="${self[__methods__]}"

  omethods__ref[$2]="$3"

  return 0
}
###############################################################################
# @description Add a method directly to an object.
#
# @example
#    $obj.add_method perform MyObject__perform
#
# @arg $1 string An object id (this)
# @arg $2 string Name of the method
# @arg $3 string Function name to be called when the method is invoked
#
# @exitcode 0 If successful.
#
function __hbl__Object__add_method() {
  [[ $# -eq 2 && -n "$1" && -n "$2" ]] || $Error.argument || return
  __hbl__Util__static__is_function "$2" || $Error.argument || return

  __hbl__Object__add_method_ "${!this}" "$1" "$2"

#   if [[ ! -v this[__methods__] ]]; then
#     this[__methods__]="${this[__id__]}__methods"
#     declare -Ag "${this[__methods__]}"
#   fi

#   local -n omethods__ref="${this[__methods__]}"

#   omethods__ref[$1]="$2"

#   return 0
}

function __hbl__Object__add_getter_() {
  local -n self="$1"

  local obj attr getter
  attr="$2" getter=""

  # make getter function
  getter="${self[__id__]}__get_${attr}"
  source /dev/stdin <<-EOF
${getter}() { __hbl__Object__read_attribute "$attr" "\$1"; };
EOF

  __hbl__Object__add_method_ "${!self}"  "get_$attr" "$getter"
}

###############################################################################
# @description Add a getter for an attribute directly on an object.
#
# @example
#    $obj.add_getter attr
#
# @arg $1 string Name of the attribute
#
# @exitcode 0 If successful.
#
function __hbl__Object__add_getter() {
  [[ $# -eq 1 && -n "$1" ]] || $Error.argument || return

  __hbl__Object__add_getter_ "${!this}" "$1"
}

function __hbl__Object__add_setter_() {
  local -n self="$1"

  local obj attr setter
  attr="$2" setter=""

  # make setter function
  setter="${self[__id__]}__set_${attr}"
  source /dev/stdin <<-EOF
${setter}() { __hbl__Object__write_attribute "${attr}" "\$1"; };
EOF

  __hbl__Object__add_method_ "${!self}" "set_${attr}" "${setter}"
}

###############################################################################
# @description Add a setter for an attribute directly on an object.
#
# @example
#    $obj.add_setter attr
#
# @arg $1 string Name of the attribute
#
# @exitcode 0 If successful.
#
function __hbl__Object__add_setter() {
  [[ $# -eq 1 && -n "$1" ]] || $Error.argument || return

  __hbl__Object__add_setter_ "${!this}" "$1"
}

function __hbl__Object__add_reference_() {
  local -n self="$1"

  local ref ref_func
  ref="$2"

  ref_func="${self[__id__]}__ref__${ref}"

  source /dev/stdin <<-EOF
${ref_func}() { __hbl__Object__delegate_to_reference_ "$ref" "\$@"; };
EOF

  __hbl__Object__add_method_ "${!self}" "$ref" "$ref_func"
}

###############################################################################
# @description Add an accessor for another object directly on an object.
#
# @example
#    $obj.add_refrerence child
#
# @arg $1 string Name of the sub-object
#
# @exitcode 0 If successful.
#
function __hbl__Object__add_reference() {
  [[ $# -eq 1 && -n "$1" ]] || $Error.argument || return

  __hbl__Object__add_reference_ "${!this}" "$1"

#   local ref ref_func
#   ref="$1"

#   ref_func="${this[__id__]}__ref__${ref}"

#   source /dev/stdin <<-EOF
# ${ref_func}() { __hbl__Object__delegate_to_reference_ "$ref" "\$@"; };
# EOF

#   __hbl__Object__add_method "$ref" "$ref_func"
}

###############################################################################
# @description Retrieve an object attribute.
#
# @example
#    $obj.read_attribute color myvar
#
# @arg $1 string Name of the attribute
# @arg $2 string Name of the variable to hold the value
#
# @exitcode 0 If successful.
#
function __hbl__Object__read_attribute() {
  [[ $# -eq 2 && -n "$1" && -n "$2" ]] ||
    $Error.argument || return

  local -n ret__ref="$2"

  ret__ref="${this[$1]}"

  return 0
}

###############################################################################
# @description Set an object attribute.
#
# @example
#    $obj.write_attribute color red
#
# @arg $1 string Name of the attribute
# @arg $2 string Value to be stored
#
# @exitcode 0 If successful.
#
function __hbl__Object__write_attribute() {
  [[ $# -eq 2 && -n "$1" ]] || $Error.argument || return

  this[$1]="$2"

  return 0
}

function __hbl__Object__assign_reference_() {
  local -n self="$1"

  local obj_id

  if [[ "$3" =~ ^__hbl__Object__dispatch_ ]]; then
    $3._get_id_ obj_id
    self[__ref_$2]="$obj_id"
  else
    self[__ref_$2]="$3"
  fi

}

###############################################################################
# @description Set an object reference.
#
# @example
#    $obj.assign_reference child thechild
#
# @arg $1 string Name of the reference
# @arg $2 string Id of the referenced object
#
# @exitcode 0 If successful.
#
function __hbl__Object__assign_reference() {
  [[ $# -eq 2 && -n "$1" && -n "$2" ]] || $Error.argument || return

  __hbl__Object__assign_reference_ "${!this}" "$@"

#   local obj_id

#   if [[ "$2" =~ ^__hbl__Object__dispatch_ ]]; then
#     $2._get_id_ obj_id
#     this[__ref_$1]="$obj_id"
#   else
#     this[__ref_$1]="$2"
#   fi

}

function __hbl__Object__init() {
  return 0
}

# vim: ts=2:sw=2:expandtab
