#!/usr/bin/env bash

function Command__init() {
	[[ $# -eq 3 ]] || $Error.invocation $FUNCNAME "$@" || exit
	[[ -n "$2" ]]  || $Error.argument $FUNCNAME command_name "$2" || exit
	[[ -n "$3" ]]  || $Error.argument $FUNCNAME command_entrypoint "$3" || exit

	local -n this="$1"
	local examples options subcommands

	$this.super
	this[name]="$2"
	this[entrypoint]="$3"
	this[description]=""

	$Array.new         examples
	$Dict.new          options
	$Array.new         subcommands

	$this._set_reference examples    "$examples"
	$this._set_reference options     "$options"
	$this._set_reference subcommands "$subcommands"

	return $HBL_SUCCESS
}

function Command__add_example() {
	local -n this="$1"

	$this.examples.append "$2"

	return $HBL_SUCCESS
}

function Command__add_option() {
	local -n this="$1"
	local opt opt_name options
	opt="$2"

	${!opt}._set_reference command "$this"
	${!opt}.get_name opt_name

	$this.options.set "$opt_name" "$opt"

	return $HBL_SUCCESS
}

function Command__add_subcommand() {
	local -n this="$1"
	local sub subcommands

	$this.subcommands.append "$2"

	return $HBL_SUCCESS
}

################################################################################
# Command
################################################################################
declare -Ag Command__prototype
Command__prototype=(
	[__init]="$HBL_SELECTOR_METHOD Command__init"
	[add_example]="$HBL_SELECTOR_METHOD Command__add_example"
	[add_option]="$HBL_SELECTOR_METHOD Command__add_option"
	[add_subcommand]="$HBL_SELECTOR_METHOD Command__add_subcommand"
	[examples]="$HBL_SELECTOR_REFERENCE Array"
	[options]="$HBL_SELECTOR_REFERENCE Dict"
	[subcommands]="$HBL_SELECTOR_REFERENCE Array"
)
readonly Command__prototype

declare -Ag Command
Command=(
	[0]='Class__static__dispatch_ Command '
	[__name]=Command
	[__base]=Class
	[__prototype]=Command__prototype
)

__hbl__classes+=('Command')
