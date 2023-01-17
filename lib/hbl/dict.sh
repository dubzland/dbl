##!/usr/bin/env bash

function hbl__dict__init_() {
	local this="$1"

	$this:super
}

function hbl__dict__set() {
	[[ $# -eq 3 ]] || hbl__error__invocation_ 1 "${@:2}" || return
	local this="$1"
	local dict key value
	key="$2" val="$3"

	$this._raw dict
	local -n dict__ref="$dict"
	dict__ref[$key]="$val"

	return $HBL_SUCCESS
}

function hbl__dict__get() {
	[[ $# -eq 3 ]] || hbl__error__invocation_ 1 "${@:2}" || return
	[[ -n "$2" ]] || hbl__error__argument_ 1 key "$2" || return

	local this="$1"
	local dict key val_var
	key="$2" val_var="$3"

	$this._raw dict
	local -n dict__ref="$dict"
	local -n val_var__ref="$val_var"
	val_var__ref="${dict__ref[$key]}"

	return $HBL_SUCCESS
}

function hbl__dict__has_key() {
	[[ $# -eq 2 ]] || hbl__error__invocation_ 1 "${@:2}" || return
	[[ -n "$2" ]] || hbl__error__argument_ 1 key "$2" || return

	local this="$1"
	local dict key val_var
	key="$2"

	$this._raw dict
	local -n dict__ref="$dict"

	[[ -v dict__ref[$key] ]]
}

$Class:define Dict    hbl__dict__init_

$Dict:method  set     hbl__dict__set
$Dict:method  get     hbl__dict__get
$Dict:method  has_key hbl__dict__has_key

$Dict:attr    _raw    $HBL_ASSOCIATIVE_ARRAY
