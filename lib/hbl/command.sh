#!/usr/bin/env bash

function __hbl__Command__init() {
	dump_entry_ "$@"
	[[ $# -eq 3 && -n "$2" && -n "$3" ]]  || return $HBL_ERR_ARGUMENT

	local -n this="$1"
	local examples options subcommands

	$this.super
	this[_name]="$2"
	this[_entrypoint]="$3"
	this[_description]=""

	$Array.new         examples
	$Dict.new          options
	$Array.new         subcommands

# 	$this._set_reference examples    "$examples"
# 	$this._set_reference options     "$options"
# 	$this._set_reference subcommands "$subcommands"

	return $HBL_SUCCESS
}

function __hbl__Command__add_example() {
	local -n this="$1"

	$this.examples.push "$2"

	return $HBL_SUCCESS
}

function __hbl__Command__add_option() {
	local -n this="$1"
	local opt opt_name options
	opt="$2"

	${!opt}._set_reference command "$this"
	${!opt}.get_name opt_name

	$this.options.set "$opt_name" "$opt"

	return $HBL_SUCCESS
}

function __hbl__Command__add_subcommand() {
	local -n this="$1"
	local sub subcommands

	$this.subcommands.push "$2"

	return $HBL_SUCCESS
}
