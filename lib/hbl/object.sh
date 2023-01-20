#!/usr/bin/env bash

HBL_SELECTOR_METHOD=1
HBL_SELECTOR_GETTER=2
HBL_SELECTOR_SETTER=3

function Object__init() {
	local -n this="$1"

	[[ -v this[__class] ]] || this[__class]=Object
	[[ -v this[__prototype] ]] || this[__prototype]=Object__prototype
	return 0
}

function Object__inspect() {
	local -n this="$1"
	printf "<%s" "$1"
	for attr in "${!this[@]}"; do
		[[ "$attr" =~ ^__* || "$attr" = "0" ]] && continue
		printf " %s='%s'" "$attr" "${this[$attr]}"
	done
	printf ">\n"
}

#########################################
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

# function Object__static__define() {
# 	[[ $# -ge 2 && "$1" = Object ]] || $Error.invocation $FUNCNAME "$@" || return
# 	[[ -n "$1" ]] || $Error.argument $FUNCNAME 'parent object type' "$1" || return
# 	[[ -n "$2" ]] || $Error.argument $FUNCNAME 'object name' "$2" || return

# 	local pcls ncls_name ncls_init
# 	pcls="$1" ncls_name="$2"
# 	[[ -n "$3" ]] && ncls_init="$3"

# 	# ensure a class by this name doesn't exist
# 	! $Util.is_defined "$ncls_name" ||
# 		$Error.already_defined "$ncls_name" || return

# 	# Create the class
# 	declare -Ag "$ncls_name"
# 	local -n ncls__ref="$ncls_name"
# 	ncls__ref=(
# 		[0]="Object__static__dispatch_ $ncls_name "
# 		[__name]="$ncls_name"
# 		[__base]="$pcls"
# 		[__methods]="${ncls_name}__methods"
# 		[__prototype]="${ncls_name}__prototype"
# 	)

# 	# create the prototype object
# 	declare -Ag "${ncls__ref[__prototype]}"
# 	local -n ncls_prototype__ref="${ncls__ref[__prototype]}"
# 	ncls_prototype__ref=()

# 	# if an initialzer was pased, assign it
# 	[[ -n "$ncls_init" ]] && ncls__ref[__init]="$ncls_init"

# 	# create the methods associative array
# 	declare -Ag "${ncls__ref[__methods]}"
# 	local -n ncls_methods__ref="${ncls__ref[__methods]}"
# 	ncls_methods__ref=()
# }

# function Object__static__method() {
# 	[[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] ||
# 		$Error.invocation $FUNCNAME "$@" || return
# 	[[ "$1" != Object ]] ||
# 		$Error.illegal_instruction 'Object.method' \
# 		'cannot alter Object' || return

# 	# ensure we were passed an actual function
# 	$Util.is_function "$3" || $Error.argument $FUNCNAME 'function' "$3" || return

# 	# ensure we don't have an existing prototype method in the tree by this name
# 	! Object__static__find_prototype_function_ "$1" "$2" _ _ _ ||
# 		$Error.illegal_instruction 'Object.method' \
# 		'cannot redefine existing method' || return

# 	local -n cls__ref="$1"
# 	local -n cls_prototype__ref="${cls__ref[__prototype]}"

# 	cls_prototype__ref[$2]="$HBL_SELECTOR_METHOD $3"

# 	return $HBL_SUCCESS

# 	return $HBL_SUCCESS
# }

# function Object__static__static_method() {
# 	[[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] ||
# 		$Error.invocation $FUNCNAME "$@" || return
# 	[[ "$1" != Object ]] ||
# 		$Error.illegal_instruction 'Object.static_method' \
# 		'cannot alter Object' || return

# 	# ensure we were passed an actual function
# 	$Util.is_function "$3" || $Error.argument $FUNCNAME 'function' "$3" || return

# 	# ensure we don't have an existing accessor in the tree by this name
# 	! Object__static__find_static_selector_ "$1" "$2" _ _ _ ||
# 		$Error.illegal_instruction 'Object.static_method' \
# 		'cannot redefine existing static method' || return

# 	local -n cls__ref="$1"
# 	local -n cls_methods__ref="${cls__ref[__methods]}"

# 	cls_methods__ref[$2]="$3"

# 	return $HBL_SUCCESS
# }

function Object__static__is_object() {
	[[ $# -ge 2 && "$1" = 'Object' && -n "$2" ]] ||
		$Error.invocation $FUNCNAME "$@" || return

	$Util.is_associative_array $2 || return $HBL_ERROR
	local -n obj__ref="$2"
	[[ -v obj__ref[__class] ]] || return $HBL_ERROR

	return $HBL_SUCCESS
}

# function Object__static__find_static_selector_() {
# 	[[ $# -ge 2 && -n "$1" && -n "$2" && -n "$3" && -n "$4" && -n "$5" ]] ||
# 		$Error.invocation $FUNCNAME "$@" || return

# 	local cls
# 	cls="$1"
# 	local -n target_obj_var__ref="$3" target_type_var__ref="$4" target_var__ref="$5"

# 	while [[ -n "$cls" ]]; do
# 		local -n cls__ref="$cls"

# 		# check for a method
# 		if [[ -n cls__ref[__methods] ]]; then
# 			local -n cls_methods__ref="${cls__ref[__methods]}"

# 			if [[ -v cls_methods__ref[$2] ]]; then
# 				target_obj_var__ref="$1"
# 				target_type_var__ref=$HBL_SELECTOR_METHOD
# 				target_var__ref="${cls_methods__ref[$2]}"
# 				return $HBL_SUCCESS
# 			fi
# 		fi

# 		# check for a getter
# 		if [[ "$2" =~ ^get_* && -v cls__ref[${2#get_}] ]]; then
# 			# getter
# 			target_obj_var__ref="$1"
# 			target_type_var__ref=$HBL_SELECTOR_GETTER
# 			target_var__ref="${2#get_}"
# 			return $HBL_SUCCESS
# 		fi

# 		if [[ "$2" =~ ^set_* && -v cls__ref[${2#set_}] ]]; then
# 			# setter
# 			target_obj_var__ref="$1"
# 			target_type_var__ref=$HBL_SELECTOR_SETTER
# 			target_var__ref="${2#set_}"
# 			return $HBL_SUCCESS
# 		fi

# 		# did not find a match.  walk the tree
# 		if [[ -v cls__ref[__base] ]]; then
# 			cls="${cls__ref[__base]}"
# 			continue
# 		fi

# 		# reached the end of the heirarchy
# 		cls=""
# 	done

# 	return $HBL_ERROR
# }

# function Object__static__find_prototype_method_() {
# 	[[ $# -ge 2 && -n "$1" && -n "$2" && -n "$3" && -n "$4" && -n "$5" ]] ||
# 		$Error.invocation $FUNCNAME "$@" || return

# 	local cls
# 	cls="$1"
# 	local -n target_class_var__ref="$3" target_type_var__ref="$4" target_var__ref="$5"

# 	while [[ -n "$cls" ]]; do
# 		local -n cls__ref="$cls"

# 		if [[ -n cls__ref[__prototype] ]]; then
# 			local -n cls_prototype__ref="${cls__ref[__prototype]}"

# 			if [[ -v cls_prototype__ref[$2] ]]; then
# 				target_class_var__ref="$cls"
# 				local -a proto_arr=(${cls_prototype__ref[$2]})
# 				target_type_var__ref="${proto_arr[0]}"
# 				target_var__ref="${proto_arr[1]}"
# 				return $HBL_SUCCESS
# 			fi
# 		fi

# 		# did not find a match.  walk the tree
# 		if [[ -v cls__ref[__base] ]]; then
# 			cls="${cls__ref[__base]}"
# 			continue
# 		fi

# 		# reached the end of the heirarchy
# 		cls=""
# 	done

# 	return $HBL_ERROR
# }

# function Object__static__dispatch_() {
# 	[[ $# -ge 2 && -n "$1" && -n "$2" ]] || $Error.invocation $FUNCNAME "$@" || return
# 	[[ "$2" =~ ^\. ]] || $Error.undefined_method "$1" "$2" || return

# 	local cls selector sobj sobj_type sobj_target
# 	cls="$1" selector="${2#\.}"

# 	hbl__util__is_associative_array Util "$cls" ||
# 		$Error.argument $FUNCNAME object "$1" || return

# 	if Object__static__find_static_selector_ \
# 		"$cls" "$selector" sobj sobj_type sobj_target; then
# 		case "$sobj_type" in
# 			"$HBL_SELECTOR_METHOD")
# 				"$sobj_target" "$sobj" "${@:3}"
# 				return
# 				;;
# 			"$HBL_SELECTOR_GETTER")
# 				[[ $# -eq 3 ]] || $Error.invocation "${cls}.${selector}" "$@" || return
# 				local -n sobj__ref="$sobj"
# 				local -n attr_var__ref="$3"
# 				attr_var__ref="${sobj__ref[$sobj_target]}"
# 				return $HBL_SUCCESS
# 				;;
# 			"$HBL_SELECTOR_SETTER")
# 				[[ $# -ge 3 ]] || $Error.invocation "${cls}.${selector}" "$@" || return
# 				[[ "$sobj_target" =~ ^__* ]] &&
# 					{ $Error.illegal_instruction "${cls}.${selector}" \
# 						'system attributes cannot be set'; return; }
# 				local -n sobj__ref="$sobj"
# 				sobj__ref[$sobj_target]="$3"
# 				return $HBL_SUCCESS
# 				;;
# 		esac
# 	fi

# 	$Error.undefined_method "$cls" "$selector" || return
# }
# function hbl__object__inspect() {
# 	local attrs obj obj_id
# 	obj=$1
# 	$obj.__id obj_id
# 	printf "<%s" "$obj_id"
# 	$obj.__attrs attrs
# 	local -n attrs__ref=$attrs
# 	for key in "${!attrs__ref[@]}"; do
# 		printf " %s='%s'" "$key" "${attrs__ref[$key]}"
# 	done

# 	printf ">\n"
# }

# function hbl__object__find_method_() {
# 	# printf "*** hbl__object__find_method_() ***\n"
# 	# printf "args: %s\n" "$@"
# 	local vtbl meth_name meth_vtbl_var
# 	vtbl=$1 meth_name=$2 meth_vtbl_var="$3"

# 	while [[ -n $vtbl ]]; do
# 		local -n vtbl__ref=$vtbl
# 		if [[ -v ${vtbl}[$meth_name] ]]; then
# 			local -n meth_vtbl__ref=$meth_vtbl_var
# 			meth_vtbl__ref=$vtbl
# 			break
# 		else
# 			if [[ -v ${vtbl}[__next] ]]; then
# 				vtbl=${vtbl__ref[__next]}
# 				continue
# 			else
# 				vtbl=""
# 			fi
# 		fi
# 	done

# 	[[ -n "$meth_vtbl__ref" ]]
# }

# function hbl__object__set_reference_() {
# 	return 0
# }

# function hbl__object__get_reference_() {
# 	return 0
# }

# function hbl__object__set_attribute_() {
# 	return 0
# }

# function hbl__object__get_attribute_() {
# 	return 0
# }

# function hbl__object__exec_function_() {
# 	return 0
# }

# function hbl__object__process_accessor_() {
# 	# printf "*** hbl__object__process_accessor_() ***\n" >&3
# 	# printf "args: %s\n" "$@" >&3
# 	local tgt attr
# 	tgt=$3 attr="${5#.}"

# 	# grab everything up to : or .
# 	local head="${attr%%[.:]*}"
# 	local tail="${attr#${head}}"

# 	local -n tgt__ref=$tgt

# 	if [[ -v tgt__ref[__refs] ]]; then
# 		local -n refs__ref=${tgt__ref[__refs]}
# 		local key="${head%=}"
# 		# printf "looking for accessor %s on %s\n" "$key" "$tgt" >&3
# 		if [[ -v refs__ref[$key] ]]; then
# 			# printf "accessor found for %s on %s\n" "$key" "$tgt" >&3
# 			if [[ "$head" =~ \=$ ]]; then
# 				# printf "assigning [%s] to refs__ref[%s]\n" "$6" "$key" >&3
# 				refs__ref[$key]="$6"
# 				return
# 			else
# 				# grab the reference and pass the rest of the attr
# 				local ref="${refs__ref[$key]}"
# 				$ref$tail "${@:6}"
# 				return
# 			fi
# 		fi
# 	fi

# 	hbl__object__process_attribute_ "$@"
# }

# function hbl__object__process_attribute_() {
# 	# printf "*** _object_process_attribute_() ***\n"
# 	# printf "args: %s\n" "$@"
# 	local tgt attr
# 	tgt=$3 attr="${5#.}"

# 	local -n tgt__ref=$tgt

# 	if [[ "$attr" =~ \=$ ]]; then
# 		if [[ "$attr" =~ ^__ ]]; then
# 			printf "setting system attributes is not allowed.\n" && return 1
# 		fi
# 		local -n attrs__ref=${tgt__ref[__attrs]}
# 		# set an attribute value
# 		if [[ $# -lt 6 ]]; then
# 			printf "Missing attribute ref for attr %s\n" "$attr" >&2
# 			exit 1
# 		fi
# 		[[ -v attrs__ref[${attr%=}] ]] || printf "invalid attribute: %s\n" "${attr%=}" || return 1
# 		attrs__ref[${attr%=}]="$6"
# 	else
# 		[[ -z "$tail" ]] || return "illegal nesting call: %s\n" "$attr" >&2 || return 1
# 		# get an attribute value
# 		local -n attr__ref="$6"
# 		if [[ "$attr" =~ ^__ ]]; then
# 			if [[ -v tgt__ref[${attr}] ]]; then
# 				attr__ref="${tgt__ref[$attr]}"
# 			else
# 				printf "did not find system attribute %s on %s.\n" "$attr" "$tgt"
# 				return 1
# 			fi
# 		else
# 			local -n attrs__ref=${tgt__ref[__attrs]}
# 			if [[ -v attrs__ref[${attr}] ]]; then
# 				attr__ref="${attrs__ref[$attr]}"
# 			else
# 				printf "did not find attribute %s on %s.\n" "$attr" "$tgt"
# 				return 1
# 			fi
# 		fi
# 	fi
# }

# function hbl__object__dispatch_cache_key_() {
# 	local -n cache_key__ref="$1"
# 	printf -v cache_key__ref "%s**%s**%s**%s**%s" "$1" "$2" "$3" "$4" "$5"
# }

# function hbl__object__process_method_() {
# 	# printf "*** _object_process_method() ***\n"
# 	# printf "args: %s\n" "$@"
# 	local tgt_vtbl sup_vtbl tgt curr_meth meth meth_vtbl
# 	local tgt_vtbl=$1 sup_vtbl=$2 tgt=$3 curr_meth=$4 meth=$5
# 	local -a dispatch_args
# 	local -n tgt_vtbl__ref=$tgt_vtbl

# 	if [[ "$meth" = ":super" ]]; then
# 		meth="$curr_meth"
# 		local -n sup_vtbl__ref=$sup_vtbl
# 		meth_vtbl="${sup_vtbl__ref[__next]}"
# 	else
# 		meth="${5#\:}"
# 		meth_vtbl=$tgt_vtbl
# 	fi
# 	dispatch_args=("${@:6}")

# 	local cache_key
# 	hbl__object__dispatch_cache_key_ cache_key

# 	if hbl__object__find_method_ $meth_vtbl $meth meth_vtbl; then
# 		local -n meth_vtbl__ref=$meth_vtbl
# 		${meth_vtbl__ref[$meth]} \
# 			"hbl__object__dispatch_ $tgt_vtbl $meth_vtbl $tgt $meth " \
# 			"${dispatch_args[@]}"
# 	else
# 		hbl__error__undefined_method_ 3 "$meth" || return
# 	fi
# }

# function hbl__object__dispatch_() {
# 	# printf "*** hbl__object__dispatch_() ***\n" >&3
# 	# printf "args: %s\n" "$@" >&3
# 	local selector
# 	selector="$5"

# 	if [[ "$selector" =~ ^\. ]]; then
# 		hbl__object__process_accessor_ "$@" || exit
# 	elif [[ "$selector" =~ ^\: ]]; then
# 		hbl__object__process_method_ "$@" || exit
# 	else
# 		printf "bad selector: %s\n" "$selector" >&2 && return 1
# 	fi
# }

# function hbl__object__new() {
# 	# printf "*** _object__new() ***\n" >&3
# 	# printf "args: %s\n" "$@" >&3
# 	[[ $# -ge 2 ]] || hbl__error__invocation_ 3 "$@" || return
# 	[[ -n "$1" ]] || hbl__error__argument_ 3 base_name "$1" || return
# 	[[ -n "$2" ]] || hbl__error__argument_ 3 dispatch_var "$2" || return

# 	local cls cls_name cls_pvtbl cls_pattrs cls_prefs nobj_dispatch nobj_id
# 	cls="$1" nobj_dispatch="$2"

# 	# get the base class name and prototype
# 	$cls.__name cls_name
# 	$cls.__pvtbl cls_pvtbl
# 	$cls.__pattrs cls_pattrs
# 	$cls.__prefs cls_prefs

# 	# build a unique object_id based on class and object count
# 	nobj_id="__hbl__${cls_name}_${#__objects[@]}"

# 	# declare and initialize the global object
# 	declare -Ag $nobj_id
# 	local -n nobj=$nobj_id
# 	nobj=(
# 		[__id]=$nobj_id
# 		[__class]=$cls_name
# 		[__attrs]="${nobj_id}__attrs"
# 		[__vtbl]=$cls_pvtbl
# 		[__refs]="${nobj_id}__refs"
# 	)

# 	# create the object attributes
# 	declare -Ag ${nobj[__attrs]}
# 	local -n nobj_attrs__ref=${nobj[__attrs]}
# 	nobj_attrs__ref=()
# 	local -n cls_pattrs__ref="$cls_pattrs"
# 	for key in "${!cls_pattrs__ref[@]}"; do
# 		case "${cls_pattrs__ref[$key]}" in
# 			$HBL_STRING) nobj_attrs__ref[$key]='' ;;
# 			$HBL_ARRAY|$HBL_ASSOCIATIVE_ARRAY)
# 				local attr_id="${nobj_id}__attrs__$key"
# 				if [[ ${cls_pattrs__ref[$key]} -eq $HBL_ARRAY ]]; then
# 					declare -ag $attr_id
# 				else
# 					declare -Ag $attr_id
# 				fi
# 				local -n attr__ref=$attr_id
# 				attr__ref=()
# 				nobj_attrs__ref[$key]=$attr_id
# 				;;
# 			*)
# 				printf "unknown attribute type: %s - %s\n" "$key" \
# 						"${cls_pattrs__ref[$key]}" ||
# 					return 1
# 				;;
# 		esac
# 	done

	# create the references
	# declare -Ag ${nobj[__refs]}
	# local -n nobj_refs__ref=${nobj[__refs]}
	# nobj_refs__ref=()
	# local -n cls_prefs__ref="$cls_prefs"
	# for key in "${!cls_prefs__ref[@]}"; do
	# 	nobj_refs__ref[$key]=""
	# done

# 	# setup the dispatch command
# 	local -n nobj_dispatch__ref=$nobj_dispatch
# 	nobj_dispatch__ref="hbl__object__dispatch_ ${nobj[__vtbl]} ${nobj[__vtbl]} $nobj_id '' "

# 	# store the object in the global array
# 	__objects+=($nobj_id)

# 	return $HBL_SUCCESS
# }

################################################################################
# Object
################################################################################
declare -Ag Object__methods
Object__methods=(
	[is_object]=Object__static__is_object
)
readonly Object__methods

declare -Ag Object__prototype
Object__prototype=(
	[__init]=Object__init
	[inspect]="$HBL_SELECTOR_METHOD Object__inspect"
)
readonly Object__prototype

declare -Ag Object
Object=(
	[0]='Class__static__dispatch_ Object '
	[__methods]=Object__methods
	[__prototype]=Object__prototype
)
readonly Object

__hbl__classes+=('Object')
