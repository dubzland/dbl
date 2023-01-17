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
	$this.parent=      ''
	$this.description= ''

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
	local examples

	$this.examples examples

	$examples:append "$2"

	return $HBL_SUCCESS
}

function hbl__command__add_option() {
	local this opt opt_name options
	this="$1" opt="$2"

	$this.options options
	$opt.name opt_name

	$options:set "$opt_name" "$opt"

	return $HBL_SUCCESS
}

function hbl__command__add_subcommand() {
	local this sub subcommands
	this="$1" sub="$2"

	$this.subcommands subcommands

	$subcommands:append "$sub"

	return $HBL_SUCCESS
}

$Class:define   Command        hbl__command__init_

$Command:attr   parent         Command
$Command:attr   name           $HBL_STRING
$Command:attr   entrypoint     $HBL_STRING
$Command:attr   description    $HBL_STRING
$Command:attr   examples       Array
$Command:attr   options        Dict
$Command:attr   subcommands    Array

$Command:method add_example    hbl__command__add_example
$Command:method add_option     hbl__command__add_option
$Command:method add_subcommand hbl__command__add_subcommand
