#!/usr/bin/env bash

###############################################################################
# Teacher
###############################################################################
function Teacher__init() {
  local -n this="$1"; shift
  local students

  $this.super "$1" "$2"
  $Dict.new students

  $this.assign_reference students "$students"
}

function Teacher__add_student() {
  local -n this="$1"; shift
  local id name student
  id="$1" name="$2"

  $Student.new student "$this" "$id" "$name"
  $this.students.set "$id" "$student"
}

function Teacher__static__from_records() {
  local line teacher id oldIFS
  local -a record

  while read -r line; do
    oldIFS="$IFS"
    IFS=, record=($line)
    IFS="${oldIFS}"

    $Teacher.new teacher "${record[0]}" "${record[1]}" || return

    $teacher.get_id id || return

    $Teacher.teachers.set "${id}" "${teacher}" || return
  done

  return 0
}

$Person.extend Teacher
  $Teacher.reference students    Student

  $Teacher.method    __init      Teacher__init
  $Teacher.method    add_student Teacher__add_student

  $Teacher.static_reference teachers     Dict

  $Teacher.static_method    from_records Teacher__static__from_records

declare teachers
$Dict.new teachers
$Teacher.assign_reference teachers "${teachers}"
unset teachers
