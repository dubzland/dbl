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

function Object__can_super_() {
	[[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] ||
		$Error.invocation $FUNCNAME "$@" || return
	local obj selector func cls
	obj="$1" selector="$2" func="$3"
	local -n obj__ref="$obj"

	cls="${obj__ref[__class]}"

	# if there is a call on the stack
	if [[ ${#__hbl__stack[@]} -gt 0 ]]; then
		local -a stack_head=(${__hbl__stack[-1]})

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
			'invalid context for super1' || return
	fi
}

function Object__set_reference_() {
	local -n this="$1"
	this["_$2"]="$3"
}

function Object__find_selector_() {
	[[ $# -ge 2 && -n "$1" && -n "$2" ]] ||
		$Error.invocation $FUNCNAME "$@" || return
	if [[ $# -gt 2 ]]; then
		[[ $# -eq 5 && -n "$3" && -n "$4" && -n "$5" ]] ||
			$Error.invocation $FUNCNAME "$@" || return
	fi

	local cls head tail
	cls="$1"

	while [[ -n "$cls" ]]; do
		local -n cls__ref="$cls"

		head="${2%%.*}"
		tail="${2#${head}}"

		# check for the selector in this prototype
		if [[ -v cls__ref[__prototype] ]]; then
			local -n cls_prototype__ref="${cls__ref[__prototype]}"

			if [[ -v cls_prototype__ref[$head] ]]; then
				local -a proto_arr=(${cls_prototype__ref[$head]})
				if [[ ${proto_arr[0]} -eq $HBL_SELECTOR_METHOD ]]; then
					if [[ -z "$tail" ]]; then
						if [[ $# -gt 2 ]]; then
							local -n tcls__ref="$3" ttype__ref="$4" tgt__ref="$5"
							tcls__ref="$cls"
							ttype__ref="${proto_arr[0]}"
							tgt__ref="${proto_arr[1]}"
						fi
						return $HBL_SUCCESS
					fi
				elif [[ ${proto_arr[0]} -eq $HBL_SELECTOR_REFERENCE ]]; then
					if [[ -n "$tail" ]]; then
						if [[ $# -gt 2 ]]; then
							local -n tcls__ref="$3" ttype__ref="$4" tgt__ref="$5"
							tcls__ref="${proto_arr[1]}"
							ttype__ref="${proto_arr[0]}"
							tgt__ref="$tail"
						fi
						return $HBL_SUCCESS
					fi
				fi
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

function Object__dispatch_() {
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
		Object__can_super_ "$obj" "$selector" "${FUNCNAME[1]}" || return
		local -n cls__ref="$cls"
		local -a stack_head=(${__hbl__stack[-1]})

		super=1 selector="${stack_head[2]}" cls="${cls__ref[__base]}"
		cache_key="${obj}:${selector}:super"
	fi

	if [[ -v __hbl__dispatch_cache["$cache_key"] ]]; then
		local -a cached=(${__hbl__dispatch_cache["$cache_key"]})
		scls="${cached[0]}" stype="${cached[1]}" stgt="${cached[2]}"
	fi

	if [[ -z "$scls" ]]; then
		rc=0
		Object__find_selector_ \
			"$cls" "$selector" scls stype stgt || rc=$?
		[[ $rc -eq $HBL_SUCCESS || $rc -eq $HBL_ERROR ]] || return $rc
	fi

	if [[ -n "$scls" && -n "$stype" && -n "$stgt" ]]; then
		if [[ ! -v __hbl__dispatch_cache[$cache_key] ]]; then
			__hbl__dispatch_cache[$cache_key]="${scls} ${stype} ${stgt}"
		fi
		case "$stype" in
			$HBL_SELECTOR_METHOD)
				# push to the stack
				__hbl__stack+=("$obj $scls $selector $stgt")
				rc=0
				"$stgt" "$obj" "$@" || rc=$?
				unset __hbl__stack[-1]
				return $rc
				;;
			$HBL_SELECTOR_REFERENCE)
				head="${selector%%.*}"
				# ensure the reference is assigned
				if [[ -v obj__ref[_${head}] ]]; then
					rc=0
					Object__dispatch_ "${obj__ref[_${head}]}" "$stgt" "$@" || rc=$?
					return $rc
				else
					printf "reference not set!\n" && return $HBL_ERROR
				fi
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

function Object__static__is_object() {
	[[ $# -ge 2 && "$1" = 'Object' && -n "$2" ]] ||
		$Error.invocation $FUNCNAME "$@" || return

	$Util.is_associative_array $2 || return $HBL_ERROR
	local -n obj__ref="$2"
	[[ -v obj__ref[__class] ]] || return $HBL_ERROR

	return $HBL_SUCCESS
}

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
	[_set_reference]="$HBL_SELECTOR_METHOD Object__set_reference_"
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
