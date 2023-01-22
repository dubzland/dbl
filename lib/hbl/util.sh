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
# @exitcode $HBL_SUCCESS If successful.
# @exitcode $HBL_ERROR If the argument is not defined
#
function __hbl__Util__static__is_defined() {
	[[ $# -eq 1 && -n "$1" ]] || return $HBL_ERR_ARGUMENT

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
# @exitcode $HBL_SUCCESS If successful.
# @exitcode $HBL_ERROR If the argument is not a function.
#
function __hbl__Util__static__is_function() {
	[[ $# -eq 1 && -n "$1" ]] || return $HBL_ERR_ARGUMENT

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
# @exitcode $HBL_SUCCESS If successful.
# @exitcode $HBL_ERROR If the argument is not an associative array.
#
function __hbl__Util__static__is_associative_array() {
	[[ $# -eq 1 && -n "$1" ]] || return $HBL_ERR_ARGUMENT

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
# @exitcode $HBL_SUCCESS If successful.
# @exitcode $HBL_ERROR If the argument is not an associative array.
#
# @stdout
#    ================ myarr =================
#    color:          red
#    size:           large
#    ^^^^^^^^^^^^^^^^ myarr ^^^^^^^^^^^^^^^^^
#
function __hbl__Util__static__dump_associative_array() {
	[[ $# -eq 1 && -n "$1" ]] || return $HBL_ERR_ARGUMENT

	local name head tail
	local -a keys
	local -i nlen plen hlen tlen
	name="$1" nlen="${#name}" plen=$((40-nlen-2)) hlen=$((plen/2)) tlen=$((plen-hlen))

	__hbl__Util__static__is_defined "$name" || return $HBL_ERR_ARGUMENT

	local -n __ref="$name"

	keys=("${!__ref[@]}")
	$Array.sort keys || return

	printf -v head "%${hlen}s"; printf -v tail "%${tlen}s"

	printf "%s %s %s\n" "${head// /\=}" "$name" "${tail// /\=}"
	for key in "${keys[@]}"; do
		printf "%-15s %s\n" "${key}:" "${__ref[$key]}"
	done
	printf "%s %s %s\n" "${head// /\^}" "$name" "${tail// /\^}"

	return $HBL_SUCCESS
}

################################################################################
# Util
################################################################################
declare -Ag __hbl__Util__methods
__hbl__Util__methods=(
	[is_defined]=__hbl__Util__static__is_defined
	[is_function]=__hbl__Util__static__is_function
	[is_associative_array]=__hbl__Util__static__is_associative_array
	[dump_associative_array]=__hbl__Util__static__dump_associative_array
)
readonly __hbl__Util__methods

declare -Ag Util
Util=(
	[0]='Class__static__dispatch_ Util '
	[__name]=Util
	[__base]=Class
	[__methods]=__hbl__Util__methods
)
readonly Util

__hbl__classes+=('Util')
