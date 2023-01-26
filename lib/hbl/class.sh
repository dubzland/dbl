#!/usr/bin/env bash

function __hbl__Class__resolve_method_() {
	local mcls
	local -n _disp="__hbl__dispatcher"

	mcls="${_disp[obj]}"
	while [[ -n "$mcls" ]]; do
		local -n mcls__ref="$mcls"
		if [[ -v mcls__ref[__static_methods__] ]]; then
			local -n cmethods__ref="${mcls__ref[__static_methods__]}"
			if [[ -v cmethods__ref[${_disp[head]}] ]]; then
				_disp[func]="${cmethods__ref[${_disp[head]}]}"
				_disp[resolved]=1
				break
			fi
		fi

		if [[ -v mcls__ref[__superclass__] && "${mcls__ref[__superclass__]}" != "$mcls" ]]; then
			mcls="${mcls__ref[__superclass__]}"
			continue
		fi
		mcls=""
	done

	return 0
}

function __hbl__Class__static__define() {
	local name
	name="$1"

	declare -Ag "$name"

	__hbl__Object__new_ "$name" || return

	local -n cls__ref="${name}"
	cls__ref[__class__]=Class
	cls__ref[__superclass__]=Object

	if [[ $# -gt 1 ]]; then
		local -n classdef__ref="$2"
		if [[ -v classdef__ref[prototype] ]]; then
			cls__ref[__prototype__]="${classdef__ref[prototype]}"
		fi

		if [[ -v classdef__ref[static_methods] ]]; then
			cls__ref[__static_methods__]="${classdef__ref[static_methods]}"
		fi

		if [[ -v classdef__ref[references] ]]; then
			cls__ref[__references__]="${classdef__ref[references]}"
		fi
	fi

	return 0
}

function __hbl__Class__add_static_method() {
	local -n cls__ref="$1"

	if [[ ! -v cls__ref[__static_methods__] ]]; then
		cls__ref[__static_methods__]="$1__static_methods"
		declare -Ag "${cls__ref[__static_methods__]}"
	fi

	local -n smethods__ref="${cls__ref[__static_methods__]}"
	smethods__ref[$2]="$3"

	return 0
}

function __hbl__Class__add_prototype_method() {
	local -n cls__ref="$1"

	if [[ ! -v cls__ref[__prototype__] ]]; then
		cls__ref[__prototype__]="$1__prototype"
		declare -Ag "${cls__ref[__prototype__]}"
	fi

	local -n cproto__ref="${cls__ref[__prototype__]}"

	if [[ ! -v cproto__ref[__methods__] ]]; then
		cproto__ref[__methods__]="${!cproto__ref}__methods"
		declare -Ag "${cproto__ref[__methods__]}"
	fi

	local -n pmethods__ref="${cproto__ref[__methods__]}"
	pmethods__ref[$2]="$3"

	return 0
}

function __hbl__Class__add_prototype_attribute() {
	[[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] || $Error.argument

	local -n cls__ref="$1"

	if [[ ! -v cls__ref[__prototype__] ]]; then
		cls__ref[__prototype__]="$1__prototype"
		declare -Ag "${cls__ref[__prototype__]}"
	fi

	local -n cproto__ref="${cls__ref[__prototype__]}"

	if [[ ! -v cproto__ref[__attributes__] ]]; then
		cproto__ref[__attributes__]="${!cproto__ref}__attributes"
		declare -Ag "${cproto__ref[__attributes__]}"
	fi

	local -n pattributes__ref="${cproto__ref[__attributes__]}"
	pattributes__ref["$2"]="$3"

	return 0
}

function __hbl__Class__add_prototype_reference() {
	[[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] || $Error.argument || return

	local -n cls__ref="$1"

	if [[ ! -v cls__ref[__prototype__] ]]; then
		cls__ref[__prototype__]="$1__prototype"
		declare -Ag "${cls__ref[__prototype__]}"
	fi

	local -n cproto__ref="${cls__ref[__prototype__]}"

	if [[ ! -v cproto__ref[__references__] ]]; then
		cproto__ref[__references__]="${!cproto__ref}__references"
		declare -Ag "${cproto__ref[__references__]}"
	fi

	local -n preferences__ref="${cproto__ref[__references__]}"
	preferences__ref["$2"]="$3"

	return 0
}

function __hbl__Class__new() {
	local self obj attr meth cls init icls ref
	self="$1" obj="" init="" icls=""
	local -n id__ref="$2"
	shift 2

	# Build the object
	__hbl__Object__new "$self" obj || return

	local -n obj__ref="$obj"
	obj__ref[__class__]="$self"

	local -n omethods__ref="${obj__ref[__methods__]}"

	cls="$self"

	while [[ -n "$cls" ]]; do
		local -n cls__ref="$cls"

		if [[ -v cls__ref[__prototype__] ]]; then
			local -n cproto__ref="${cls__ref[__prototype__]}"

			if [[ -v cproto__ref[__methods__] ]]; then
				local -n cmethods__ref="${cproto__ref[__methods__]}"

				for meth in "${!cmethods__ref[@]}"; do
					if [[ ! -v omethods__ref[$meth] ]]; then
						omethods__ref[$meth]="${cmethods__ref[$meth]}"
					fi

					if [[ "$meth" = '__init' && -z "$init" ]]; then
						init="${omethods__ref[$meth]}"
						icls="$cls"
					fi
				done
			fi

			if [[ -v cproto__ref[__attributes__] ]]; then
				local -n cattrs__ref="${cproto__ref[__attributes__]}"

				for attr in "${!cattrs__ref[@]}"; do
					local attr_flag="${cattrs__ref[$attr]}"
					if [[ $((attr_flag & __hbl__attr__getter)) -gt 0 ]]; then
						__hbl__Object__add_getter "$obj" "$attr"
					fi

					if [[ $((attr_flag & __hbl__attr__setter)) -gt 0 ]]; then
						__hbl__Object__add_setter "$obj" "$attr"
					fi

					obj__ref[$attr]=''
				done
			fi

			if [[ -v cproto__ref[__references__] ]]; then
				local -n creferences__ref="${cproto__ref[__references__]}"
				for ref in "${!creferences__ref[@]}"; do
					local ref_class="${creferences__ref[$ref]}"
					__hbl__Object__add_reference "$obj" "$ref" "$ref_class" || return
				done
			fi
		fi
		if [[ -n cls__ref[__superclass__] && "${cls__ref[__superclass__]}" != "$cls" ]]; then
			cls="${cls__ref[__superclass__]}"
			continue
		fi
		cls=""
	done

	# Return the dispatcher
	id__ref="${!obj}"

	if [[ -n "$init" ]]; then
		__hbl__Object__dispatch_function_ __init $icls $init "$obj" "$@"
	else
		return 0
	fi
}

function __hbl__Class__extend() {
	local base="$1"; shift

	__hbl__Class__static__define "$@"

	if [[ "$base" != Class ]]; then
		local -n cls__ref="$1"
		cls__ref[__superclass__]="$base"
	fi

	return 0
}

function __hbl__Class__inspect() {
	local -n this="$1"

	printf "<%s:%s>\n" "$1" "${this[__id__]}"
}
