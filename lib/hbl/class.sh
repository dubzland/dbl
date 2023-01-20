#!/usr/bin/env bash

function __hbl__can_super() {
	[[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] ||
		$Error.invocation $FUNCNAME "$@" || return
	local obj selector func cls
	obj="$1" selector="$2" func="$3"
	local -n obj__ref="$obj"

	cls="${obj__ref[__class]}"

	# if there is a call on the stack
	if [[ ${#__hbl__stack[@]} -gt 0 ]]; then
		local -a stack_head=(${__hbl__stack[0]})

		# if the current object and function match the call
		if [[ "$obj" = "${stack_head[0]}" && "$func" = "${stack_head[3]}" ]]; then
			# advance the cls by one level and go
			[[ -v ${cls}[__base] ]] ||
				$Error.illegal_instruction "${obj}.${selector}" \
					'no base class found' || return
			return $HBL_SUCCESS
			local -n cls__ref="$cls"
		else
			# not in the last function we called.  can' super
			$Error.illegal_instruction "${obj}.${selector}" \
				'invalid context for super' || return
		fi
	else
		# stack empty.  no super method exists
		$Error.illegal_instruction "${obj}.${selector}" \
			'invalid context for super' || return
	fi
}

function __hbl__find_static_selector_() {
	[[ $# -ge 2 && -n "$1" && -n "$2" ]] ||
		$Error.invocation $FUNCNAME "$@" || return
	if [[ $# -gt 2 ]]; then
		[[ $# -eq 5 && -n "$3" && -n "$4" && -n "$5" ]] ||
			$Error.invocation $FUNCNAME "$@" || return
	fi

	local cls ltype
	cls="$1" ltype=""

	while [[ -n "$cls" ]]; do
		local -n cls__ref="$cls"

		# check for a method
		if [[ -n cls__ref[__methods] ]]; then
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
				scls__ref="$1" stype__ref=$ltype

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

function __hbl__find_prototype_selector_() {
	[[ $# -ge 2 && -n "$1" && -n "$2" ]] ||
		$Error.invocation $FUNCNAME "$@" || return
	if [[ $# -gt 2 ]]; then
		[[ $# -eq 5 && -n "$3" && -n "$4" && -n "$5" ]] ||
			$Error.invocation $FUNCNAME "$@" || return
	fi

	local cls
	cls="$1"

	while [[ -n "$cls" ]]; do
		local -n cls__ref="$cls"

		# check for the selector in this prototype
		if [[ -v cls__ref[__prototype] ]]; then
			local -n cls_prototype__ref="${cls__ref[__prototype]}"

			if [[ -v cls_prototype__ref[$2] ]]; then
				local -a proto_arr=(${cls_prototype__ref[$2]})
				if [[ $# -gt 2 ]]; then
					local -n tcls__ref="$3" ttype__ref="$4" tgt__ref="$5"
					tcls__ref="$cls"
					ttype__ref="${proto_arr[0]}"
					tgt__ref="${proto_arr[1]}"
				fi
				return $HBL_SUCCESS
			fi
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

function Class__dispatch_() {
	[[ $# -ge 2 && -n "$1" && -n "$2" ]] || $Error.invocation $FUNCNAME "$@" || return
	[[ "$2" =~ ^\. ]] || $Error.undefined_method "$1" "$2" || return

	local obj selector cls cache_key super scls stype stgt
	obj="$1" selector="${2#\.}" super=0 cache_key="${obj}:${selector}"
	shift 2

	hbl__util__is_associative_array Util "$obj" ||
		$Error.argument $FUNCNAME object "$obj" || return

	local -n obj__ref="$obj"
	cls="${obj__ref[__class]}"

	if [[ "$selector" = 'super' ]]; then
		__hbl__can_super "$obj" "$selector" "${FUNCNAME[1]}" || return
		local -n cls__ref="$cls"
		local -a stack_head=(${__hbl__stack[0]})

		super=1 selector="${stack_head[2]}" cls="${cls__ref[__base]}"
		cache_key="${obj}:${selector}:super"
	fi

	if [[ -v __hbl__dispatch_cache["$cache_key"] ]]; then
		printf ">> CACHE HIT << for %s\n" "$cache_key" >&3
		local -a cached=(${__hbl__dispatch_cache["$cache_key"]})
		scls="${cached[0]}" stype="${cached[1]}" stgt="${cached[2]}"
	fi

	if [[ -z "$scls" ]]; then
		rc=0
		__hbl__find_prototype_selector_ \
			"$cls" "$selector" scls stype stgt || rc=$?
		[[ $rc -eq $HBL_SUCCESS || $rc -eq $HBL_ERROR ]] || return $rc
	fi

	if [[ -n "$scls" && -n "$stype" && -n "$stgt" ]]; then
		if [[ ! -v __hbl__dispatch_cache[$cache_key] ]]; then
			__hbl__dispatch_cache[$cache_key]="${scls} ${stype} ${stgt}"
		fi
		case "$stype" in
			"$HBL_SELECTOR_METHOD")
				# push to the stack
				__hbl__stack+=("$obj $scls $selector $stgt")
				rc=0
				"$stgt" "$obj" "$@" || rc=$?
				__hbl__stack=("${__hbl__stack[@]:1}")
				return $rc
				;;
		esac
	fi

	# not a method.  check for a getter/setter
	if [[ -z "$scls" ]]; then
		if [[ "$selector" =~ ^get_* && -v obj__ref[${selector#get_}] ]]; then
			# getter
			[[ $# -eq 1 ]] || $Error.invocation "${obj}.${selector}" "$@" || return
			local -n attr_var__ref="$1"
			attr_var__ref="${obj__ref[${selector#get_}]}"
			return $HBL_SUCCESS
		elif [[ "$selector" =~ ^set_* && -v obj__ref[${selector#set_}] ]]; then
			# setter
			[[ $# -ge 1 ]] || $Error.invocation "${obj}.${selector}" "$@" || return
			[[ "$selector" =~ ^__* ]] &&
				{ $Error.illegal_instruction "${obj}.${selector}" \
					'system attributes cannot be set'; return; }
			obj__ref[${selector#set_}]="$1"
			return $HBL_SUCCESS
		fi
	fi

	# no idea what the caller wanted
	$Error.undefined_method "$obj" "$selector" || return
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
	[[ -n "$ncls_init" ]] && ncls_prototype__ref[__init]="$HBL_SELECTOR_METHOD $ncls_init"

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
	! __hbl__find_static_selector_ "$1" "$2" ||
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

	local cls selector cache_key scls stype stgt
	cls="$1" selector="${2#\.}" cache_key="${cls}:${selector}"
	shift 2

	hbl__util__is_associative_array Util "$cls" ||
		$Error.argument $FUNCNAME object "$1" || return

	if [[ -v __hbl__dispatch_cache["$cache_key"] ]]; then
		printf ">> CACHE HIT << for %s\n" "$cache_key" >&3
		local -a cached=(${__hbl__dispatch_cache["$cache_key"]})
		scls="${cached[0]}"
		stype="${cached[1]}"
		stgt="${cached[2]}"
	fi

	if [[ -z "$scls" ]]; then
		rc=0
		__hbl__find_static_selector_ \
			"$cls" "$selector" scls stype stgt || rc=$?
		[[ $rc -eq $HBL_SUCCESS || $rc -eq $HBL_ERROR ]] || return $rc
	fi

	if [[ -n "$scls" && -n "$stype" && -n "$stgt" ]]; then
		if [[ ! -v __hbl__dispatch_cache["$cache_key"] ]]; then
			__hbl__dispatch_cache[$cache_key]="${scls} ${stype} ${stgt}"
		fi

		case "$stype" in
			"$HBL_SELECTOR_METHOD")
				"$stgt" "$scls" "$@"
				return
				;;
			"$HBL_SELECTOR_GETTER")
				[[ $# -eq 1 ]] || $Error.invocation "${cls}.${selector}" "$@" || return
				local -n scls__ref="$scls"
				local -n attr_var__ref="$1"
				attr_var__ref="${scls__ref[$stgt]}"
				return $HBL_SUCCESS
				;;
			"$HBL_SELECTOR_SETTER")
				[[ $# -ge 1 ]] || $Error.invocation "${cls}.${selector}" "$@" || return
				[[ "$stgt" =~ ^__* ]] &&
					{ $Error.illegal_instruction "${cls}.${selector}" \
						'system attributes cannot be set'; return; }
				local -n scls__ref="$scls"
				scls__ref[$stgt]="$1"
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
	)
	nobj_var__ref="$obj_id"

	# call the initializer
	$nobj__ref.__init "${@:3}" || return

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
	[__init]="$HBL_SELECTOR_METHOD Class__init"
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
