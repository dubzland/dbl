#!/usr/bin/env bash

function __hbl__find_static_selector_() {
	[[ $# -ge 2 && -n "$1" && -n "$2" && -n "$3" && -n "$4" && -n "$5" ]] ||
		$Error.invocation $FUNCNAME "$@" || return

	local cls
	cls="$1"
	local -n target_obj_var__ref="$3" target_type_var__ref="$4" target_var__ref="$5"

	while [[ -n "$cls" ]]; do
		local -n cls__ref="$cls"

		# check for a method
		if [[ -n cls__ref[__methods] ]]; then
			local -n cls_methods__ref="${cls__ref[__methods]}"

			if [[ -v cls_methods__ref[$2] ]]; then
				target_obj_var__ref="$1"
				target_type_var__ref=$HBL_SELECTOR_METHOD
				target_var__ref="${cls_methods__ref[$2]}"
				return $HBL_SUCCESS
			fi
		fi

		# check for a getter
		if [[ "$2" =~ ^get_* && -v cls__ref[${2#get_}] ]]; then
			# getter
			target_obj_var__ref="$1"
			target_type_var__ref=$HBL_SELECTOR_GETTER
			target_var__ref="${2#get_}"
			return $HBL_SUCCESS
		fi

		if [[ "$2" =~ ^set_* && -v cls__ref[${2#set_}] ]]; then
			# setter
			target_obj_var__ref="$1"
			target_type_var__ref=$HBL_SELECTOR_SETTER
			target_var__ref="${2#set_}"
			return $HBL_SUCCESS
		fi

		# did not find a match.  walk the tree
		if [[ -v cls__ref[__base] ]]; then
			cls="${cls__ref[__base]}"
			continue
		fi

		# reached the end of the heirarchy
		cls=""
	done

	return $HBL_ERROR
}

function __hbl__find_prototype_selector_() {
	[[ $# -ge 2 && -n "$1" && -n "$2" && -n "$3" && -n "$4" && -n "$5" ]] ||
		$Error.invocation $FUNCNAME "$@" || return

	local cls
	cls="$1"
	local -n target_class_var__ref="$3" target_type_var__ref="$4" target_var__ref="$5"

	while [[ -n "$cls" ]]; do
		local -n cls__ref="$cls"

		if [[ -n cls__ref[__prototype] ]]; then
			local -n cls_prototype__ref="${cls__ref[__prototype]}"

			if [[ -v cls_prototype__ref[$2] ]]; then
				target_class_var__ref="$cls"
				local -a proto_arr=(${cls_prototype__ref[$2]})
				target_type_var__ref="${proto_arr[0]}"
				target_var__ref="${proto_arr[1]}"
				return $HBL_SUCCESS
			fi
		fi

		# did not find a match.  walk the tree
		if [[ -v cls__ref[__base] ]]; then
			cls="${cls__ref[__base]}"
			continue
		fi

		# reached the end of the heirarchy
		cls=""
	done

	return $HBL_ERROR
}

function Class__dispatch_() {
	[[ $# -ge 2 && -n "$1" && -n "$2" ]] || $Error.invocation $FUNCNAME "$@" || return
	[[ "$2" =~ ^\. ]] || $Error.undefined_method "$1" "$2" || return

	local obj selector cls sobj sobj_type sobj_target
	obj="$1" selector="${2#\.}"

	hbl__util__is_associative_array Util "$obj" ||
		$Error.argument $FUNCNAME object "$1" || return

	local -n obj__ref="$obj"
	cls="${obj__ref[__class]}"

	if __hbl__find_prototype_selector_ \
		"$cls" "$selector" sobj sobj_type sobj_target; then
		case "$sobj_type" in
			"$HBL_SELECTOR_METHOD")
				# push to the stack
				local -n stack__ref="${obj__ref[__stack]}"
				rc=0
				stack__ref+=("$cls $obj $selector")
				"$sobj_target" "$obj" "${@:3}" || rc=$?
				stack__ref=("${stack__ref[@]:1}")
				return $rc
				;;
			"$HBL_SELECTOR_GETTER")
				[[ $# -eq 3 ]] || $Error.invocation "${cls}.${selector}" "$@" || return
				local -n sobj__ref="$sobj"
				local -n attr_var__ref="$3"
				attr_var__ref="${sobj__ref[$sobj_target]}"
				return $HBL_SUCCESS
				;;
			"$HBL_SELECTOR_SETTER")
				[[ $# -ge 3 ]] || $Error.invocation "${cls}.${selector}" "$@" || return
				[[ "$sobj_target" =~ ^__* ]] &&
					{ $Error.illegal_instruction "${cls}.${selector}" \
						'system attributes cannot be set'; return; }
				local -n sobj__ref="$sobj"
				sobj__ref[$sobj_target]="$3"
				return $HBL_SUCCESS
				;;
		esac
	fi

	$Error.undefined_method "$cls" "$selector" || return
	return 0
}

function Class__init() {
	[[ $# -ge 1  && -n "$1" ]] || $Error.invocation $FUNCNAME "$@" || return

	$Object.is_object "$1" || $Error.argument $FUNCNAME 'object' "$1" || return

	local -n obj__ref="$1"
	obj__ref[__id]="$1"
}

function Class__static__define() {
	[[ $# -ge 2 ]] || $Error.invocation $FUNCNAME "$@" || return
	[[ -n "$1" ]] || $Error.argument $FUNCNAME 'parent object type' "$1" || return
	[[ -n "$2" ]] || $Error.argument $FUNCNAME 'object name' "$2" || return

	local pcls ncls_name ncls_init
	pcls="$1" ncls_name="$2"
	[[ -n "$3" ]] && ncls_init="$3"

	# ensure a class by this name doesn't exist
	! $Util.is_defined "$ncls_name" ||
		$Error.already_defined "$ncls_name" || return

	# Create the class
	declare -Ag "$ncls_name"
	local -n ncls__ref="$ncls_name"
	ncls__ref=(
		[0]="Class__static__dispatch_ $ncls_name "
		[__name]="$ncls_name"
		[__base]="$pcls"
		[__methods]="${ncls_name}__methods"
		[__prototype]="${ncls_name}__prototype"
	)

	# create the prototype object
	declare -Ag "${ncls__ref[__prototype]}"
	local -n ncls_prototype__ref="${ncls__ref[__prototype]}"
	ncls_prototype__ref=()

	# if an initialzer was pased, assign it
	[[ -n "$ncls_init" ]] && ncls__ref[__init]="$ncls_init"

	# create the methods associative array
	declare -Ag "${ncls__ref[__methods]}"
	local -n ncls_methods__ref="${ncls__ref[__methods]}"
	ncls_methods__ref=()
}

function Class__static__prototype_method() {
	[[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] ||
		$Error.invocation $FUNCNAME "$@" || return
	[[ "$1" != Object ]] ||
		$Error.illegal_instruction 'Class.static_method' \
		'cannot alter Object' || return
	[[ "$1" != Class ]] ||
		$Error.illegal_instruction 'Class.static_method' \
		'cannot alter Class' || return

	# ensure we were passed an actual function
	$Util.is_function "$3" || $Error.argument $FUNCNAME 'function' "$3" || return

	local -n cls__ref="$1"
	local -n cls_prototype__ref="${cls__ref[__prototype]}"

	# ensure we don't have an existing method/reference for this selector
	[[ ! -v cls_prototype__ref[$2] ]] ||
		$Error.illegal_instruction "${1}.method" \
		'a selector by that name already exists' || return

	cls_prototype__ref[$2]="$HBL_SELECTOR_METHOD $3"

	return $HBL_SUCCESS
}

function Class__static__method() {
	[[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] ||
		$Error.invocation $FUNCNAME "$@" || return
	[[ "$1" != Object ]] ||
		$Error.illegal_instruction 'Class.static_method' \
		'cannot alter Object' || return
	[[ "$1" != Class ]] ||
		$Error.illegal_instruction 'Class.static_method' \
		'cannot alter Class' || return

	# ensure we were passed an actual function
	$Util.is_function "$3" || $Error.argument $FUNCNAME 'function' "$3" || return

	# ensure we don't have an existing accessor in the tree by this name
	! __hbl__find_static_selector_ "$1" "$2" _ _ _ ||
		$Error.illegal_instruction "${1}.static_method" \
		'cannot redefine existing static method' || return

	local -n cls__ref="$1"
	local -n cls_methods__ref="${cls__ref[__methods]}"

	cls_methods__ref[$2]="$3"

	return $HBL_SUCCESS
}

function Class__static__dispatch_() {
	[[ $# -ge 2 && -n "$1" && -n "$2" ]] || $Error.invocation $FUNCNAME "$@" || return
	[[ "$2" =~ ^\. ]] || $Error.undefined_method "$1" "$2" || return

	local cls selector sobj sobj_type sobj_target
	cls="$1" selector="${2#\.}"

	hbl__util__is_associative_array Util "$cls" ||
		$Error.argument $FUNCNAME object "$1" || return

	if __hbl__find_static_selector_ \
		"$cls" "$selector" sobj sobj_type sobj_target; then
		case "$sobj_type" in
			"$HBL_SELECTOR_METHOD")
				"$sobj_target" "$sobj" "${@:3}"
				return
				;;
			"$HBL_SELECTOR_GETTER")
				[[ $# -eq 3 ]] || $Error.invocation "${cls}.${selector}" "$@" || return
				local -n sobj__ref="$sobj"
				local -n attr_var__ref="$3"
				attr_var__ref="${sobj__ref[$sobj_target]}"
				return $HBL_SUCCESS
				;;
			"$HBL_SELECTOR_SETTER")
				[[ $# -ge 3 ]] || $Error.invocation "${cls}.${selector}" "$@" || return
				[[ "$sobj_target" =~ ^__* ]] &&
					{ $Error.illegal_instruction "${cls}.${selector}" \
						'system attributes cannot be set'; return; }
				local -n sobj__ref="$sobj"
				sobj__ref[$sobj_target]="$3"
				return $HBL_SUCCESS
				;;
		esac
	fi

	$Error.undefined_method "$cls" "$selector" || return
}

function Class__static__new() {
	[[ $# -ge 2 ]] || $Error.invocation $FUNCNAME "$@" || return
	[[ -n "$1" ]] || $Error.argument $FUNCNAME class "$1" || return
	[[ -n "$2" ]] || $Error.argument $FUNCNAME object_var "$2" || return

	local obj_id

	# Generate an object id
	while true; do
		obj_id="${1}_$RANDOM"
		$Util.is_defined "$obj_id" || break
	done

	# create the actual object
	declare -Ag "$obj_id"
	local -n nobj_var__ref="$2"
	local -n nobj__ref="$obj_id"
	nobj__ref=(
		[0]="Class__dispatch_ $obj_id "
		[__class]="$1"
		[__stack]="${1}__stack"
	)
	nobj_var__ref="$obj_id"

	declare -ag "${nobj__ref[__stack]}"
	local -n nobj_stack__ref="${nobj__ref[__stack]}"
	nobj_stack__ref=()

	return $HBL_SUCCESS
}

# function hbl__class__define() {
# 	# printf "*** hbl__class__define() ***\n" >&3
# 	# printf "args: %s\n" "$@" >&3
# 	local pcls pcls_vtbl pcls_pvtbl ncls ncls_name ncls_ctor
# 	pcls="$1" ncls_name="$2" ncls_ctor="$3"

# 	# create the class
# 	ncls="__hbl__Class__$ncls_name"
# 	declare -Ag $ncls
# 	local -n ncls__ref=$ncls
# 	ncls__ref=(
# 		[__name]=$ncls_name
# 		[__ancestor]='Object'
# 		[__vtbl]="${ncls}__vtbl"
# 		[__pvtbl]="${ncls}__pvtbl"
# 		[__pattrs]="${ncls}__pattrs"
# 		[__prefs]="${ncls}__prefs"
# 	)
# 	declare -g "$ncls_name"

# 	# create the class vtable
# 	$pcls.__vtbl pcls_vtbl
# 	declare -Ag ${ncls__ref[__vtbl]}
# 	local -n ncls_vtbl__ref=${ncls__ref[__vtbl]}
# 	ncls_vtbl__ref=(
# 		[__next]=$pcls_vtbl
# 	)

# 	# create the class prototype vtable
# 	$pcls.__pvtbl pcls_pvtbl
# 	declare -Ag ${ncls__ref[__pvtbl]}
# 	local -n ncls_pvtbl__ref=${ncls__ref[__pvtbl]}
# 	ncls_pvtbl__ref=(
# 		[__next]=$pcls_pvtbl
# 	)
# 	[[ -n "$ncls_ctor" ]] && ncls_pvtbl__ref[__ctor]=$ncls_ctor

# 	# create the class prototype_attributes
# 	declare -Ag ${ncls__ref[__pattrs]}
# 	local -n ncls_pattrs__ref=${ncls__ref[__pattrs]}
# 	ncls_pattrs__ref=()

# 	# create the class prototype reference objects
# 	declare -Ag ${ncls__ref[__prefs]}
# 	local -n ncls_prefs__ref=${ncls__ref[__prefs]}
# 	ncls_prefs__ref=()

# 	local -n ncls_dispatch__ref=$ncls_name
# 	ncls_dispatch__ref="hbl__object__dispatch_ ${ncls__ref[__vtbl]} ${ncls__ref[__vtbl]} $ncls '' "

# 	__hbl__classes+=("$ncls_name")
# }

# function hbl__class__attribute() {
# 	local cls cls_pattrs attr attr_type
# 	cls="$1" attr="$2" attr_type="$3"

# 	case $attr_type in
# 		$HBL_STRING|$HBL_NUMBER|$HBL_ARRAY|$HBL_ASSOCIATIVE_ARRAY)
# 			$cls.__pattrs cls_pattrs
# 			local -n cls_pattrs__ref=$cls_pattrs
# 			cls_pattrs__ref[$attr]="$attr_type"
# 			;;
# 		*)
# 			for hbl_cls in "${__hbl__classes[@]}"; do
# 				if [[ "$attr_type" = "$hbl_cls" ]]; then
# 					printf "Unsupported type for attribute: [%s].  Did you mean ':reference'?\n" \
# 						"$attr_type" >&2 || return $HBL_ERROR
# 				fi
# 			done
# 			printf "Unsupported attribute type: %s\n" "$attr_type" && return $HBL_ERROR
# 			;;
# 	esac

# 	return $HBL_SUCCESS
# }

# function hbl__class__reference() {
# 	local cls cls_prefs attr attr_type
# 	cls="$1" attr="$2" attr_type="$3"

# 	for hbl_cls in "${__hbl__classes[@]}"; do
# 		if [[ "$attr_type" = "$hbl_cls" ]]; then
# 			$cls.__prefs cls_prefs
# 			local -n cls_prefs__ref=$cls_prefs
# 			cls_prefs__ref[$attr]="$attr_type"
# 			return $HBL_SUCCESS
# 		fi
# 	done

# 	return $HBL_ERROR
# }

# function hbl__class__instance_method() {
# 	local cls cls_pvtbl meth_func meth_name
# 	cls="$1" meth_name="$2" meth_func="$3"

# 	$cls.__pvtbl cls_pvtbl

# 	local -n cls_pvtbl__ref=$cls_pvtbl
# 	cls_pvtbl__ref[$meth_name]="$meth_func"
# }

# function hbl__class__static_method() {
# 	local cls cls_vtbl meth_func meth_name
# 	cls="$1" meth_name="$2" meth_func="$3"

# 	$cls._vtbl cls_vtbl

# 	local -n cls_vtbl__ref=$cls_vtbl
# 	cls_vtbl__ref[$meth_name]="$meth_func"
# }

# function hbl__class__new() {
# 	local cls
# 	cls=$1

# 	if $cls:super $2; then
# 		local -n obj="$2"
# 		$obj:__ctor "${@:3}"
# 	fi
# }

# function hbl__class__init() {
# 	return 0
# }

################################################################################
# Class
################################################################################
declare -Ag Class__methods
Class__methods=(
	[define]=Class__static__define
	[ref]=Class__static__reference
	[method]=Class__static__prototype_method
	[static_method]=Class__static__method
	[new]=Class__static__new
)
readonly Class__methods

declare -Ag Class__prototype
Class__prototype=(
	[__ctor]="$HBL_SELECTOR_METHOD Class__init"
)
readonly Class__prototype

declare -Ag Class
Class=(
	[0]='Class__static__dispatch_ Class '
	[__name]=Class
	[__base]=Object
	[__methods]=Class__methods
	[__prototype]=Class__prototype
)

__hbl__classes+=('Class')
