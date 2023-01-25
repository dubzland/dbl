#!/usr/bin/env bash

function dump_object_() {
	local -n obj__ref="$1"
	printf "=== %s ===\n" "$1"
	for key in "${!obj__ref[@]}"; do
		printf "%-20s %s\n" "${key}:" "${obj__ref[$key]}"
	done
}

function dump_entry_() {
	printf "*** %s ***\n" "${FUNCNAME[1]}"
	printf "args: %s\n" "${@}"
	printf "**********\n"
}

__hbl__Object__get_prototype_method_() {
	[[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] || return $HBL_ERR_ARGUMENT
	local mcls meth
	mcls="$1" meth="${2#\.}"
	local -n mfunc__ref="$3"

	while [[ -n "$mcls" ]]; do
		local -n mcls__ref="$mcls"
		if [[ -v mcls__ref[__prototype__] ]]; then
			local -n cproto__ref="${mcls__ref[__prototype__]}"
			if [[ -v cproto__ref[__methods__] ]]; then
				local -n pmethods__ref="${cproto__ref[__methods__]}"
				if [[ -v pmethods__ref[$meth] ]]; then
					mfunc__ref="${pmethods__ref[$meth]}"
					return $HBL_SUCCESS
				fi
			fi
		fi
		if [[ -n mcls__ref[__superclass__] ]]; then
			mcls="${mcls__ref[__superclass__]}"
			continue
		fi
		mcls=""
	done
}

__hbl__Object__get_method_() {
	[[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] || return $HBL_ERR_ARGUMENT
	local dobj dmeth cls
	dobj="$1" dmeth="${2#\.}" cls=""
	local -n dfunc__ref="$3"

	local -n dobj__ref="$dobj"
	if [[ -v dobj__ref[__methods__] ]]; then
		local -n dmethods__ref="${dobj__ref[__methods__]}"
		if [[ -v dmethods__ref[$dmeth] ]]; then
			dfunc__ref="${dmethods__ref[$dmeth]}"
			return $HBL_SUCCESS
		fi
	fi

	__hbl__Object__get_prototype_method_ "${dobj__ref[__class__]}" "$dmeth" dfunc__ref || return

	return $HBL_SUCCESS
}

function __hbl__Object__dispatch_() {
	[[ $# -ge 2 && -n "$1" && -n "$2" ]] || return $HBL_ERR_ARGUMENT
	[[ "$2" =~ ^\. ]] || return $HBL_ERR_ARGUMENT
	local dobj dsel dfunc dsuper
	dobj="$1" dsel="$2" dfunc=''
	shift 2

	__hbl__Object__get_method_ "$dobj" "$dsel" dfunc || return
	if [[ -n "$dfunc" ]]; then
		# call the function
		${dfunc} "$dobj" "$@"
		return
	fi

	return $HBL_UNDEFINED_METHOD
}

function __hbl__Object__inspect() {
	local -n this="$1"
	printf "<%s" "$1"
	for attr in "${!this[@]}"; do
		[[ "$attr" =~ ^__ || "$attr" = "0" ]] && continue
		printf " %s='%s'" "$attr" "${this[$attr]}"
	done
	printf ">\n"
}

function __hbl__Object__get_methods() {
	[[ $# -eq 2 && -n "$1" && -n "$2" ]] || return $HBL_ERR_ARGUMENT
	local mobj mcls meth emeth
	mobj="$1" mcls="$1" meth=""
	local -n meths__ref="$2"

	local -n dobj__ref="$dobj"
	if [[ -v dobj__ref[__methods__] ]]; then
		local -n dmethods__ref="${dobj__ref[__methods__]}"
		for meth in "${!dmethods__ref[@]}"; do
			meths__ref+=("$meth")
		done
	fi

	# Walk the superclass tree looking for instance methods
	mcls="${dobj__ref[__class__]}"
	while [[ -n "$mcls" ]]; do
		local -n mcls__ref="$mcls"
		if [[ -v mcls__ref[__prototype__] ]]; then
			local -n cproto__ref="${mcls__ref[__prototype__]}"
			if [[ -v cproto__ref[__methods__] ]]; then
				local -n pmethods__ref="${cproto__ref[__methods__]}"
				for meth in "${!pmethods__ref[@]}"; do
					if ! __hbl__Array__static__contains "${!meths__ref}" "$meth"; then
						meths__ref+=("$meth")
					fi
				done
			fi
		fi
		if [[ -n mcls__ref[__superclass__] ]]; then
			mcls="${mcls__ref[__superclass__]}"
			continue
		fi
		mcls=""
	done

	return $HBL_SUCCESS
}

function __hbl__Object__add_method() {
	local -n obj__ref="$1"
	local -n omethods__ref="${obj__ref[__methods__]}"
	omethods__ref[$2]="$3"
	return $HBL_SUCCESS
}

function __hbl__Object__init() {
	[[ $# -eq 1 && -n "$1" ]] || return $HBL_ERR_ARGUMENT

	local obj_name="$1"

	local -n obj__ref="$obj_name"

	obj__ref[0]="__hbl__Object__dispatch_ ${obj_name} "
	obj__ref[__id__]=${__hbl__object__id}
	obj__ref[__methods__]="${obj_name}__methods"

	declare -Ag "${obj__ref[__methods__]}"
	local -n obj_methods__ref="${obj__ref[__methods__]}"
	obj_methods__ref=()
	__hbl__object__id=$((__hbl__object__id+1))
}

function __hbl__Object__new() {
	[[ $# -eq 2 && -n "$1" && -n "$2" ]] || return $HBL_ERR_ARGUMENT

	# Generate a random suffix
	while true; do
		obj_id="${1}_$RANDOM"
		$Util.is_defined "$obj_id" || break
	done

	local -n id__ref="$2"
	id__ref="__hbl__${obj_id}"

	declare -Ag "$id__ref"
	__hbl__Object__init "$id__ref"
}
