#!/usr/bin/env bash

HBL_SUCCESS=0
HBL_ERROR=1
HBL_UNDEFINED=2
HBL_INVALID_ARGS=101
readonly HBL_SUCCESS
readonly HBL_ERROR
readonly HBL_UNDEFINED
readonly HBL_INVALID_ARGS

function hbl::error::invalid_args() {
	[[ $# -lt 1 ]] && exit 99

	local function_name args
	function_name=$1 args="${@:2}"

	echo "Invalid arguments to ${function_name} -- ${args}" >&2
	return $HBL_INVALID_ARGS
}
