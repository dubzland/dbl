#!/usr/bin/env bash
#
# @name Util
# @brief A library of general purpose utility functions

###############################################################################
# @description Determine whether or not a variable has been declared.
#
# @example
#    $Util.is_defined myvar
#
# @arg $1 string A variable name to check
#
# @exitcode 0 If successful.
# @exitcode 1 If the argument is not defined
#
function __hbl__Util__static__is_defined() {
	[[ $# -eq 1 && -n "$1" ]] || $Error.argument || return

	declare -p "$1" >/dev/null 2>&1
}

###############################################################################
# @description Determine whether or not a variable is a function.
#
# @example
#    $Util.is_function myfunc
#
# @arg $1 string A variable name to check
#
# @exitcode 0 If successful.
# @exitcode 1 If the argument is not a function.
#
function __hbl__Util__static__is_function() {
	[[ $# -eq 1 && -n "$1" ]] || $Error.argument || return

	declare -f -F "$1" >/dev/null 2>&1
}

###############################################################################
# @description Determine whether or not a variable is an associative array.
#
# @example
#    $Util.is_associative_array myvar
#
# @arg $1 string A variable name to check
#
# @exitcode 0 If successful.
# @exitcode 1 If the argument is not an associative array.
#
function __hbl__Util__static__is_associative_array() {
	[[ $# -eq 1 && -n "$1" ]] || $Error.argument || return

	if [[ ${BASH_VERSINFO[0]} -ge 5 && $FORCE_BASH4 -ne 1 ]]; then
		local -n __ref=$1; [[ ${__ref@a} = *A* ]]
	else
		declare -p "$1" 2>/dev/null | grep 'declare -A' >/dev/null
	fi
}


###############################################################################
# @description Print the contents of a bash associative array
#
# @example
#    declare -A myarr=([size]=large [color]=red)
#    $Util.dump_associative_array myarr
#
# @arg $1 string Name of a bash associative array
#
# @exitcode 0 If successful.
# @exitcode 1 If the argument is not an associative array.
#
# @stdout
#    ================ myarr =================
#    color:          red
#    size:           large
#    ^^^^^^^^^^^^^^^^ myarr ^^^^^^^^^^^^^^^^^
#
function __hbl__Util__static__dump_associative_array() {
	[[ $# -eq 1 && -n "$1" ]] || $Error.argument || return

	local name head tail
	local -a keys
	local -i nlen plen hlen tlen
	name="$1" nlen="${#name}" plen=$((40-nlen-2)) hlen=$((plen/2)) tlen=$((plen-hlen))

	__hbl__Util__static__is_defined "$name" || $Error.argument || return

	local -n __ref="$name"

	keys=("${!__ref[@]}")
	$Array.sort keys || return

	printf -v head "%${hlen}s"; printf -v tail "%${tlen}s"

	printf "%s %s %s\n" "${head// /\=}" "$name" "${tail// /\=}"
	for key in "${keys[@]}"; do
		printf "%-15s %s\n" "${key}:" "${__ref[$key]}"
	done
	printf "%s %s %s\n" "${head// /\^}" "$name" "${tail// /\^}"

	return 0
}
