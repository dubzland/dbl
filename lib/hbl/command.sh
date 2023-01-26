#!/usr/bin/env bash

function __hbl__Command__init() {
	[[ $# -eq 3 && -n "$2" && -n "$3" ]]  || return $HBL_ERR_ARGUMENT

	local -n this="$1"
	local examples options subcommands

	$this.super
	this[name]="$2"
	this[entrypoint]="$3"
	this[description]=""

	$Array.new         examples
	$Dict.new          options
	$Array.new         subcommands

	$this.assign_reference examples    "$examples"
	$this.assign_reference options     "$options"
	$this.assign_reference subcommands "$subcommands"

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
