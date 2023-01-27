#!/usr/bin/env bash

###############################################################################
# Teacher
###############################################################################
function Student__init() {
  local -n this="$1"; shift
  local grades

  $this.super "$2" "$3"

  $Array.new grades

  $this.assign_reference teacher "$1"
  $this.assign_reference grades "$grades"
}

function Student__say_hello() {
  local -n this="$1"; shift
  local teacher_name
  $this.super

  $this.teacher.get_name teacher_name
  printf "I am a student.\n"
  printf "My teacher is %s.\n" "${teacher_name}"
}

function Student__static__from_records() {
  local line student teacher id oldIFS
  local -a record

  while read -r line; do
    oldIFS="$IFS"
    IFS=, record=(${line})
    IFS="${oldIFS}"

    if $Teacher.teachers.has_key "${record[2]}"; then
      $Teacher.teachers.get "${record[2]}" teacher || return

      $teacher.add_student "${record[0]}" "${record[1]}" || return
    else
      printf "Teacher %s does not exist.\n" "${record[2]}" >&2
      return 1
    fi
  done
}

$Person.extend Student
  $Student.reference grades Array
  $Student.reference teacher Teacher
  $Student.method __init Student__init
  $Student.method say_hello Student__say_hello
  $Student.static_method from_records Student__static__from_records
