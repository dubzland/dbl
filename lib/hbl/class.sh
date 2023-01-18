#!/usr/bin/env bash

declare -g HBL_STRING=1
declare -g HBL_NUMBER=2
declare -g HBL_ARRAY=3
declare -g HBL_ASSOCIATIVE_ARRAY=4
readonly HBL_STRING
readonly HBL_NUMBER
readonly HBL_ARRAY
readonly HBL_ASSOCIATIVE_ARRAY

declare -Ag __hbl__Class__vtbl
__hbl__Class__vtbl=(
	[define]=hbl__class__define
	[new]=hbl__class__new
	[attr]=hbl__class__attribute
	[ref]=hbl__class__reference
	[method]=hbl__class__instance_method
	[static_method]=hbl__class__static_method
	[__next]=__hbl__Object__vtbl
)
readonly __hbl__Class__vtbl

declare -Ag __hbl__Class__pvtbl
__hbl__Class__pvtbl=(
	[__ctor]=hbl__class__init
	[__next]=__hbl__Object__pvtbl
)
readonly __hbl__Class__pvtbl

declare -Ag __hbl__Class__pattrs
__hbl__Class__pattrs=()
readonly __hbl__Class__pattrs

declare -Ag __hbl__Class__prefs
__hbl__Class__prefs=()
readonly __hbl__Class__prefs

declare -Ag __hbl__Class
__hbl__Class=(
	[__name]="Class"
	[__ancestor]=""
	[__vtbl]=__hbl__Class__vtbl
	[__pvtbl]=__hbl__Class__pvtbl
	[__pattrs]=__hbl__Class__pattrs
	[__prefs]=__hbl__Class__prefs
)

declare -g Class
Class="hbl__object__dispatch_ __hbl__Class__vtbl __hbl__Class__vtbl __hbl__Class '' "
readonly Class

declare -ag __hbl__classes
__hbl__classes=()

function hbl__class__define() {
	# printf "*** hbl__class__define() ***\n" >&3
	# printf "args: %s\n" "$@" >&3
	local pcls pcls_vtbl pcls_pvtbl ncls ncls_name ncls_ctor
	pcls="$1" ncls_name="$2" ncls_ctor="$3"

	# create the class
	ncls="__hbl__Class_$ncls_name"
	declare -Ag $ncls
	local -n ncls__ref=$ncls
	ncls__ref=(
		[__name]=$ncls_name
		[__ancestor]='Object'
		[__vtbl]="${ncls}__vtbl"
		[__pvtbl]="${ncls}__pvtbl"
		[__pattrs]="${ncls}__pattrs"
		[__prefs]="${ncls}__prefs"
	)
	declare -g "$ncls_name"

	# create the class vtable
	$pcls.__vtbl pcls_vtbl
	declare -Ag ${ncls__ref[__vtbl]}
	local -n ncls_vtbl__ref=${ncls__ref[__vtbl]}
	ncls_vtbl__ref=(
		[__next]=$pcls_vtbl
	)

	# create the class prototype vtable
	$pcls.__pvtbl pcls_pvtbl
	declare -Ag ${ncls__ref[__pvtbl]}
	local -n ncls_pvtbl__ref=${ncls__ref[__pvtbl]}
	ncls_pvtbl__ref=(
		[__next]=$pcls_pvtbl
	)
	[[ -n "$ncls_ctor" ]] && ncls_pvtbl__ref[__ctor]=$ncls_ctor

	# create the class prototype_attributes
	declare -Ag ${ncls__ref[__pattrs]}
	local -n ncls_pattrs__ref=${ncls__ref[__pattrs]}
	ncls_pattrs__ref=()

	# create the class prototype reference objects
	declare -Ag ${ncls__ref[__prefs]}
	local -n ncls_prefs__ref=${ncls__ref[__prefs]}
	ncls_prefs__ref=()

	local -n ncls_dispatch__ref=$ncls_name
	ncls_dispatch__ref="hbl__object__dispatch_ ${ncls__ref[__vtbl]} ${ncls__ref[__vtbl]} $ncls '' "

	__hbl__classes+=("$ncls_name")
}

function hbl__class__attribute() {
	local cls cls_pattrs attr attr_type
	cls="$1" attr="$2" attr_type="$3"

	case $attr_type in
		$HBL_STRING|$HBL_NUMBER|$HBL_ARRAY|$HBL_ASSOCIATIVE_ARRAY)
			$cls.__pattrs cls_pattrs
			local -n cls_pattrs__ref=$cls_pattrs
			cls_pattrs__ref[$attr]="$attr_type"
			;;
		*)
			for hbl_cls in "${__hbl__classes[@]}"; do
				if [[ "$attr_type" = "$hbl_cls" ]]; then
					printf "Unsupported type for attribute: [%s].  Did you mean ':reference'?\n" \
						"$attr_type" >&2 || return $HBL_ERROR
				fi
			done
			printf "Unsupported attribute type: %s\n" "$attr_type" && return $HBL_ERROR
			;;
	esac

	return $HBL_SUCCESS
}

function hbl__class__reference() {
	local cls cls_prefs attr attr_type
	cls="$1" attr="$2" attr_type="$3"

	for hbl_cls in "${__hbl__classes[@]}"; do
		if [[ "$attr_type" = "$hbl_cls" ]]; then
			$cls.__prefs cls_prefs
			local -n cls_prefs__ref=$cls_prefs
			cls_prefs__ref[$attr]="$attr_type"
			return $HBL_SUCCESS
		fi
	done

	return $HBL_ERROR
}

function hbl__class__instance_method() {
	local cls cls_pvtbl meth_func meth_name
	cls="$1" meth_name="$2" meth_func="$3"

	$cls.__pvtbl cls_pvtbl

	local -n cls_pvtbl__ref=$cls_pvtbl
	cls_pvtbl__ref[$meth_name]="$meth_func"
}

function hbl__class__static_method() {
	local cls cls_vtbl meth_func meth_name
	cls="$1" meth_name="$2" meth_func="$3"

	$cls._vtbl cls_vtbl

	local -n cls_vtbl__ref=$cls_vtbl
	cls_vtbl__ref[$meth_name]="$meth_func"
}

function hbl__class__new() {
	local cls
	cls=$1

	if $cls:super $2; then
		local -n obj="$2"
		$obj:__ctor "${@:3}"
	fi
}

function hbl__class__init() {
	return 0
}
