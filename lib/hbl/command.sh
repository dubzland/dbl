#!/usr/bin/env bash

function hbl__command__init_() {
	[[ $# -eq 3 ]] || hbl__error__invocation_ 1 "${@:2}" || exit
	[[ -n "$2" ]]  || hbl__error__argument_ 1 command_name "$2" || exit
	[[ -n "$3" ]]  || hbl__error__argument_ 1 command_entrypoint "$3" || exit

	local this="$1"
	local examples options subcommands

	$this:super
	$this.name=        "$2"
	$this.entrypoint=  "$3"
	$this.description=  ""

	$Array:new         examples
	$Dict:new          options
	$Array:new         subcommands

	$this.examples=    "$examples"
	$this.options=     "$options"
	$this.subcommands= "$subcommands"

	return $HBL_SUCCESS
}

function hbl__command__add_example() {
	local this="$1"
	# local examples

	$this.examples:append "$2"

# 	$examples:append "$2"

	return $HBL_SUCCESS
}

function hbl__command__add_option() {
	local this opt opt_name options
	this="$1" opt="$2"

	$opt.command= "$this"
	$opt.name opt_name

	$this.options:set "$opt_name" "$opt"

	return $HBL_SUCCESS
}

function hbl__command__add_subcommand() {
	local this sub subcommands
	this="$1" sub="$2"

	$this.subcommands:append "$sub"

	return $HBL_SUCCESS
}

################################################################################
# Command
################################################################################
declare -Ag __hbl__Command__vtbl
__hbl__Command__vtbl=(
	[__next]=__hbl__Class__vtbl
)
readonly __hbl__Command__vtbl

declare -Ag __hbl__Command__pvtbl
__hbl__Command__pvtbl=(
	[__ctor]=hbl__command__init_
	[add_example]=hbl__command__add_example
	[add_option]=hbl__command__add_option
	[add_subcommand]=hbl__command__add_subcommand
	[__next]=__hbl__Class__pvtbl
)
readonly __hbl__Command__pvtbl

declare -Ag __hbl__Command__pattrs
__hbl__Command__pattrs=(
	[name]=$HBL_STRING
	[entrypoint]=$HBL_STRING
	[description]=$HBL_STRING
)
readonly __hbl__Command__pattrs

declare -Ag __hbl__Command__prefs
__hbl__Command__prefs=(
	[parent]='Command'
	[examples]='Array'
	[options]='Dict'
	[subcommands]='Array'
)
readonly __hbl__Command__prefs

declare -Ag __hbl__Command
__hbl__Command=(
	[__name]="Command"
	[__ancestor]="Class"
	[__vtbl]=__hbl__Command__vtbl
	[__pvtbl]=__hbl__Command__pvtbl
	[__pattrs]=__hbl__Command__pattrs
	[__prefs]=__hbl__Command__prefs
)

declare -g Command
Command="hbl__object__dispatch_ __hbl__Command__vtbl __hbl__Command__vtbl __hbl__Command '' "
readonly Command

__hbl__classes+=('Command')
