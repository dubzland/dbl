#!/usr/bin/env bash

function __hbl__Class__static__define() {
	local cls name
	cls="$1" name="$2"

	declare -Ag "$name"

	__hbl__Object__init "$name" || return

	local -n cls__ref="${name}"
	cls__ref[__class__]=Class
	cls__ref[__superclass__]=''
	if [[ "$cls" != Class ]]; then
		cls__ref[__superclass__]="$cls"
	fi

	if [[ $# -gt 2 ]]; then
		cls__ref[__prototype__]="$3"
	fi
}

__hbl__Class__get_method_() {
	dump_entry_ "$@"
	[[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] || return $HBL_ERR_ARGUMENT
	local mcls meth
	mcls="$1" meth="${2#\.}"
	local -n mfunc__ref="$3"

	while [[ -n "$mcls" ]]; do
		local -n mcls__ref="$mcls"
		if [[ -v mcls__ref[__methods__] ]]; then
			local -n cmethods__ref="${mcls__ref[__methods__]}"
			if [[ -v cmethods__ref[$meth] ]]; then
				mfunc__ref="${cmethods__ref[$meth]}"
				return $HBL_SUCCESS
			fi
		fi
		if [[ -v mcls__ref[__class__] && "${mcls__ref[__class__]}" != "$mcls" ]]; then
			mcls="${mcls__ref[__class__]}"
			continue
		fi
		mcls=""
	done

	return $HBL_ERROR
}

__hbl__Class__dispatch_() {
	[[ $# -ge 2 && -n "$1" && -n "$2" ]] || return $HBL_ERR_ARGUMENT
	[[ "$2" =~ ^\. ]] || return $HBL_ERR_ARGUMENT
	local dobj dsel dfunc
	dobj="$1" dsel="$2" dfunc=''
	shift 2

	__hbl__Object__get_method_ "$dobj" "$dsel" dfunc || return
	if [[ -n "$dfunc" ]]; then
		# call the function
		${dfunc} "$dobj" "$@"
		return
	fi

	__hbl__Class__get_method_ "$dobj" "$dsel" dfunc || return

	if [[ -n "$dfunc" ]]; then
		# call the function
		${dfunc} "$@"
	else
		return $HBL_ERROR
	fi
}

function __hbl__Class__new() {
	local self obj
	self="$1" obj=""

	# Build the object
	__hbl__Object__new "$self" obj

	local -n obj__ref="$obj"
	obj__ref[__class__]="$self"

	local -n id__ref="$2"
	id__ref="$obj"
	return $HBL_SUCCESS
}

function __hbl__Class__extend() {
	local base cls proto
	base="$1" cls="$2" proto="$3"

	__hbl__Class__static__define "$@"

	local -n cls__ref="$cls"

	cls__ref[__superclass__]="$base"

	return $HBL_SUCCESS
}

function __hbl__Class__inspect() {
	local -n this="$1"

	printf "<%s:%s>\n" "$1" "${this[__id__]}"
}
