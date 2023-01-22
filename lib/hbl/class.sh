#!/usr/bin/env bash

function __hbl__Class__static__find_selector_() {
	[[ $# -ge 2 && -n "$1" && -n "$2" ]] || return $HBL_ERR_ARGUMENT
	if [[ $# -gt 2 ]]; then
		[[ $# -eq 5 && -n "$3" && -n "$4" && -n "$5" ]] || return $HBL_ERR_ARGUMENT
	fi

	local cls ltype
	cls="$1" ltype=""

	while [[ -n "$cls" ]]; do
		local -n cls__ref="$cls"

		# check for a method
		if [[ -v cls__ref[__methods] ]]; then
			local -n cls_methods__ref="${cls__ref[__methods]}"
			[[ -v cls_methods__ref[$2] ]] && ltype=$HBL_SELECTOR_METHOD
		fi

		# not a method. check for a getter/setter
		if [[ -z "$ltype" ]]; then
			if [[ "$2" =~ ^get_* && -v cls__ref[${2#get_}] ]]; then
				ltype=$HBL_SELECTOR_GETTER
			elif [[ "$2" =~ ^set_* && -v cls__ref[${2#set_}] ]]; then
				ltype=$HBL_SELECTOR_SETTER
			fi
		fi

		if [[ -n "$ltype" ]]; then
			# caller may only care about existence
			if [[ $# -gt 2 ]]; then

				local -n scls__ref="$3" stype__ref="$4" stgt__ref="$5"
				scls__ref="$cls" stype__ref=$ltype

				case $ltype in
					$HBL_SELECTOR_METHOD)
						local -n cls_methods__ref="${cls__ref[__methods]}"
						stgt__ref="${cls_methods__ref[$2]}"
						;;
					$HBL_SELECTOR_GETTER) stgt__ref="${2#get_}" ;;
					$HBL_SELECTOR_SETTER) stgt__ref="${2#set_}" ;;
				esac
			fi
			return $HBL_SUCCESS
		fi

		# did not find a match.  move to the next class in the heirarchy
		if [[ -v cls__ref[__base] ]]; then
			cls="${cls__ref[__base]}"
			continue
		fi

		# reached the end of the heirarchy
		cls=""
	done

	return $HBL_ERROR
}

function __hbl__Class__static__define() {
	[[ $# -ge 2 && -n "$1" && -n "$2" ]] || return $HBL_ERR_ARGUMENTj

	local pcls ncls_name ncls_init
	pcls="$1" ncls_name="$2"
	[[ -n "$3" ]] && ncls_init="$3"

	# ensure a class by this name doesn't exist
	! $Util.is_defined "$ncls_name" || return $HBL_ERR_ALREADY_DEFINED

	# Create the class
	declare -Ag "$ncls_name"
	local -n ncls__ref="$ncls_name"
	ncls__ref=(
		[0]="__hbl__Class__static__dispatch_ $ncls_name "
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
	[[ -n "$ncls_init" ]] && ncls_prototype__ref[__init]="$HBL_SELECTOR_METHOD $ncls_init"

	# create the methods associative array
	declare -Ag "${ncls__ref[__methods]}"
	local -n ncls_methods__ref="${ncls__ref[__methods]}"
	ncls_methods__ref=()
}

function __hbl__Class__static__prototype_method() {
	[[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] || return $HBL_ERR_ARGUMENT
	[[ "$1" != Object ]] || return $HBL_ERR_ILLEGAL_INSTRUCTION
	[[ "$1" != Class ]] || return $HBL_ERR_ILLEGAL_INSTRUCTION

	# ensure we were passed an actual function
	$Util.is_function "$3" || return $HBL_ERR_ARGUMENT

	local -n cls__ref="$1"
	local -n cls_prototype__ref="${cls__ref[__prototype]}"

	# ensure we don't have an existing method/reference for this selector
	[[ ! -v cls_prototype__ref[$2] ]] || return $HBL_ERR_ILLEGAL_INSTRUCTION

	cls_prototype__ref[$2]="$HBL_SELECTOR_METHOD $3"

	return $HBL_SUCCESS
}

function __hbl__Class__static__prototype_reference() {
	[[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] || return $HBL_ERR_ARGUMENT
	[[ "$1" != Object ]] || return $HBL_ERR_ILLEGAL_INSTRUCTION
	[[ "$1" != Class ]] || return $HBL_ERR_ILLEGAL_INSTRUCTION

	local vclass=0
	# ensure we were passed an actual class
	for cls in "${__hbl__classes[@]}"; do
		if [[ "$cls" = "$3" ]]; then
			vclass=1; break
		fi
	done

	[[ $vclass -eq 1 ]] || $HBL_ERR_ARGUMENT

	local -n cls__ref="$1"
	local -n cls_prototype__ref="${cls__ref[__prototype]}"

	# ensure we don't have an existing method/reference for this selector
	[[ ! -v cls_prototype__ref[$2] ]] || return $HBL_ERR_ILLEGAL_INSTRUCTION

	cls_prototype__ref[$2]="$HBL_SELECTOR_REFERENCE $3"

	return $HBL_SUCCESS
}

function __hbl__Class__static__method() {
	[[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] || return $HBL_ERR_ARGUMENT
	[[ "$1" != Object ]] || return $HBL_ERR_ILLEGAL_INSTRUCTION
	[[ "$1" != Class ]] || return $HBL_ERR_ILLEGAL_INSTRUCTION

	# ensure we were passed an actual function
	$Util.is_function "$3" || return $HBL_ERR_ARGUMENT

	# ensure we don't have an existing accessor in the tree by this name
	! __hbl__Class__static__find_selector_ "$1" "$2" ||
		return $HBL_ERR_ILLEGAL_INSTRUCTION

	local -n cls__ref="$1"
	local -n cls_methods__ref="${cls__ref[__methods]}"

	cls_methods__ref[$2]="$3"

	return $HBL_SUCCESS
}

function __hbl__Class__static__dispatch_() {
	[[ $# -ge 2 && -n "$1" && -n "$2" ]] || $HBL_ERR_ARGUMENT
	[[ "$2" =~ ^\. ]] || $HBL_ERR_UNDEFINED_METHOD

	local cls selector cache_key scls stype stgt
	cls="$1" selector="${2#\.}" cache_key="${cls}:${selector}"
	scls="" stype="" stgt=""
	shift 2

	__hbl__Util__static__is_associative_array "$cls" || return $HBL_ERR_ARGUMENT

	if [[ -v __hbl__dispatch_cache["$cache_key"] ]]; then
		local -a cached=(${__hbl__dispatch_cache["$cache_key"]})
		scls="${cached[0]}" stype="${cached[1]}" stgt="${cached[2]}"
	fi

	if [[ -z "$scls" ]]; then
		rc=0
		__hbl__Class__static__find_selector_ \
			"$cls" "$selector" scls stype stgt || rc=$?
		[[ $rc -eq $HBL_SUCCESS || $rc -eq $HBL_ERROR ]] || return $rc
	fi

	if [[ -n "$scls" && -n "$stype" && -n "$stgt" ]]; then
		if [[ ! -v __hbl__dispatch_cache["$cache_key"] ]]; then
			__hbl__dispatch_cache[$cache_key]="${scls} ${stype} ${stgt}"
		fi

		case "$stype" in
			"$HBL_SELECTOR_METHOD")
				if [[ "$scls" = 'Class' ]]; then
					"$stgt" "$cls" "$@"
				else
					"$stgt" "$@"
				fi
				return
				;;
			"$HBL_SELECTOR_GETTER")
				[[ $# -eq 1 ]] || $HBL_ERR_ARGUMENT
				local -n scls__ref="$scls"
				local -n attr_var__ref="$1"
				attr_var__ref="${scls__ref[$stgt]}"
				return $HBL_SUCCESS
				;;
			"$HBL_SELECTOR_SETTER")
				[[ $# -ge 1 ]] || $HBL_ERR_ARGUMENT
				[[ "$stgt" =~ ^__* ]] && return $HBL_ERR_ILLEGAL_INSTRUCTION
				local -n scls__ref="$scls"
				scls__ref[$stgt]="$1"
				return $HBL_SUCCESS
				;;
		esac
	fi

	return $HBL_ERR_UNDEFINED_METHOD
}

function __hbl__Class__static__new() {
	[[ $# -ge 2 && -n "$1" && -n "$2" ]] || return $HBL_ERR_ARGUMENT

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
		[0]="Object__dispatch_ $obj_id "
		[__class]="$1"
	)
	nobj_var__ref="$obj_id"

	# call the initializer
	$nobj__ref.__init "${@:3}" || return

	return $HBL_SUCCESS
}

function __hbl__Class__init() {
	[[ $# -ge 1  && -n "$1" ]] || return $HBL_ERR_ARGUMENT

	$Object.is_object "$1" || return $HBL_ERR_ARGUMENT

	local -n obj__ref="$1"
	obj__ref[__id]="$1"
}

################################################################################
# Class
################################################################################
declare -Ag __hbl__Class__methods
__hbl__Class__methods=(
	[define]=__hbl__Class__static__define
	[ref]=__hbl__Class__static__reference
	[static_method]=__hbl__Class__static__method
	[method]=__hbl__Class__static__prototype_method
	[reference]=__hbl__Class__static__prototype_reference
	[new]=__hbl__Class__static__new
)
readonly __hbl__Class__methods

declare -Ag __hbl__Class__prototype
__hbl__Class__prototype=(
	[__init]="$HBL_SELECTOR_METHOD __hbl__Class__init"
)
readonly __hbl__Class__prototype

declare -Ag Class
Class=(
	[0]='__hbl__Class__static__dispatch_ Class '
	[__name]=Class
	[__base]=Object
	[__methods]=__hbl__Class__methods
	[__prototype]=__hbl__Class__prototype
)
readonly Class

__hbl__classes+=('Class')
