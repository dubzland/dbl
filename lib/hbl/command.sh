#!/usr/bin/env bash

# declare -Ag __hbl_params
# __hbl_params=()

# declare -ag __hbl_commands
# __hbl_commands=()

function hbl__command__init_() {
	# printf "*** hbl__command__init_() ***\n" >&3
	# printf "args: %s\n" "$@" >&3
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

# function hbl__command__ensure_command_() {
# 	[[ $# -ge 1 ]] || hbl__error__invocation "$@" || return
# 	[[ -n "$1" ]] || hbl__error__argument method "$1" || return
# 	[[ -n "$2" ]] || hbl__error__argument_ 2 'command id' "$2" || return

# 	hbl__util__is_defined "$2" \
# 		|| hbl__error__undefined_ 2 "$2" || return
# 	hbl__util__is_dict "$2" \
# 		|| hbl__error__invalid_command_ 2 "$2" || return

# 	hbl__command__${1}_ "${@:2}"
# }

# function hbl__command__validate_add_example_() {
# 	[[ $# -eq 2 ]] || hbl__error__invocation_ 2 "$@" || return
# 	[[ -n "$1" ]] || hbl__error__argument_ 2 'command id' "$1" || return
# 	[[ -n "$2" ]] || hbl__error__argument_ 2 example "$2" || return

# 	return $HBL_SUCCESS
# }

# function hbl__command__validate_add_option_() {
# 	[[ $# -eq 3 ]] || hbl__error__invocation_ 2 "$@" || return
# 	[[ -n "$1" ]] || hbl__error__argument_ 2 'command id' "$1" || return
# 	[[ -n "$2" ]] || hbl__error__argument_ 2 'option name' "$2" || return
# 	[[ -n "$3" ]] || hbl__error__argument_ 2 'option id var' "$3" || return

# 	return $HBL_SUCCESS
# }

# function hbl__command__validate_add_subcommand_() {
# 	[[ $# -eq 4 ]] || hbl__error__invocation_ 2 "$@" || exit
# 	[[ -n "$1" ]] || hbl__error__argument_ 2 parent_id "$1" || exit
# 	[[ -n "$2" ]] || hbl__error__argument_ 2 subcommand_name "$2" || exit
# 	[[ -n "$3" ]] || hbl__error__argument_ 2 subcommand_entrypoint "$3" || exit
# 	[[ -n "$4" ]] || hbl__error__argument_ 2 subcommand_id_var "$3" || exit

# 	return $HBL_SUCCESS
# }

# function hbl__command__validate_get_description_() {
# 	[[ $# -eq 2 ]] || hbl__error__invocation_ 2 "$@" || exit
# 	[[ -n "$1" ]]  || hbl__error__argument_ 2 command_id "$1" || exit
# 	[[ -n "$2" ]]  || hbl__error__argument_ 2 description_var "$2" || exit
# }

# function hbl__command__validate_set_description_() {
# 	[[ $# -eq 2 ]] || hbl__error__invocation_ 2 "$@" || exit
# 	[[ -n "$1" ]]  || hbl__error__argument_ 2 command_id "$1" || exit
# }

# function hbl__command__add_example_() {
# 	hbl__command__validate_add_example_ "$@" || return

# 	hbl__array__append_ "${1}__examples" "$2"
# }

# function hbl__command__add_option_() {
# 	hbl__command__validate_add_option_ "$@" || return

# 	local -n option_id__ref="$3"
# 	option_id__ref=""

# 	hbl__command__option__create "$1" "$2" "${!option_id__ref}" || return

# 	hbl__dict__set "${1}__options" "$2" "$option_id__ref" || return

# 	return $HBL_SUCCESS
# }

# function hbl__command__add_subcommand_() {
# 	hbl__command__validate_add_subcommand_ "$@" || return

# 	local -n subcommand_id__ref="$4"
# 	subcommand_id__ref=""

# 	hbl__command__create "$2" "$3" "${!subcommand_id__ref}" || return
# 	hbl__dict__set_ "$subcommand_id__ref" _parent "$1"
# 	hbl__array__append "${1}__subcommands" "$subcommand_id__ref" || return

# 	return $HBL_SUCCESS
# }

# function hbl__command__get_description_() {
# 	hbl__command__validate_get_description_ "$@" || return

# 	hbl__dict__get_ "$1" _description "$2"
# }

# function hbl__command__set_description_() {
# 	hbl__command__validate_set_description_ "$@" || return

# 	hbl__dict__set_ "$1" _description "$2" || return

# 	return 0
# }

# function hbl__command__create() {
# 	[[ $# -eq 3 ]] || hbl__error__invocation "$@" || exit
# 	[[ -n "$1" ]]  || hbl__error__argument command_name "$1" || exit
# 	[[ -n "$2" ]]  || hbl__error__argument command_entrypoint "$2" || exit
# 	[[ -n "$3" ]]  || hbl__error__argument command_id_var "$3" || exit

# 	local command_index
# 	local -n command_id__ref="$3"

# 	command_index="${#__hbl_commands[@]}"
# 	command_id__ref="__hbl_command_${command_index}"

# 	hbl__dict__create "$command_id__ref"

# 	local -n command__ref="$command_id__ref"
# 	${command__ref[set]} _id         "$command_id__ref"
# 	${command__ref[set]} _parent     ''
# 	${command__ref[set]} _name       "$1"
# 	${command__ref[set]} _entrypoint "$2"
# 	${command__ref[set]} add_example "hbl__command__add_example_ ${command_id__ref}"
# 	${command__ref[set]} add_option  "hbl__command__add_option_ ${command_id__ref}"
# 	${command__ref[set]} add_subcommand "hbl__command__add_subcommand_ ${command_id__ref}"
# 	${command__ref[set]} get_description "hbl__command__get_description_ ${command_id__ref}"
# 	${command__ref[set]} set_description "hbl__command__set_description_ ${command_id__ref}"

# 	declare -ag "${command_id__ref}__examples"
# 	declare -Ag "${command_id__ref}__options"
# 	declare -ag "${command_id__ref}__subcommands"

# 	hbl__array__append __hbl_commands "$command_id__ref"

# 	return 0
# }

# function hbl__command__add_example() {
# 	hbl__command__validate_add_example_ "$@" || return
# 	hbl__command__ensure_command_ add_example "$@"
# }

# function hbl__command__add_option() {
# 	hbl__command__validate_add_option_ "$@" || return

# 	hbl__command__ensure_command_ add_option "$@"
# }

# function hbl__command__add_subcommand() {
# 	hbl__command__validate_add_subcommand_ "$@" || return

# 	hbl__command__ensure_command_ add_subcommand "$@"
# }

# function hbl__command__get_description() {
# 	hbl__command__validate_get_description_ "$@" || return

# 	hbl__command__ensure_command_ get_description "$@"
# }

# function hbl__command__set_description() {
# 	hbl__command__validate_set_description_ "$@" || return

# 	hbl__command__ensure_command_ set_description "$@"
# }
