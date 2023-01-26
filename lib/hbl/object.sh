#!/usr/bin/env bash

function __hbl__Object__get_id_() {
	[[ $# -eq 2 && -n "$1" && -n "$2" ]] || $Error.argument || return
	local -n this="$1" val__ref="$2"
	val__ref="${this[__id__]}"
}

function __hbl__Object__resolve_method_() {
	local lcls lfunc
	local -a stack
	local -n _disp="__hbl__dispatcher"
	local -n dobj__ref="${_disp[obj]}"

	_disp[head]="${_disp[sel]#\.}"
	_disp[head]="${_disp[head]%%.*}"
	_disp[tail]="${_disp[sel]#\.}"
	_disp[tail]="${_disp[tail]#${_disp[head]}}"
	_disp[cls]="${dobj__ref[__class__]}"

	case "${_disp[head]}" in
		super)
			[[ ${#__hbl__stack[@]} -gt 0 ]] || {
				printf "no previous function call to execute super.\n";
				$Error.illegal_instruction || return
			}
			[[ -z "${_disp[tail]}" ]] || {
				printf "super cannot be chained\n";
				$Error.illegal_instruction || return
			}

			stack=(${__hbl__stack[-1]})

			[[ "${_disp[obj]}" = "${stack[0]}" ]] || return
			[[ "${FUNCNAME[2]}" = "${stack[3]}" ]] || return

			# We're still in the last function we called.
			# Grab a reference to the last class we dispatched to and move
			# to its superclass.
			local -n dcls__ref="${stack[2]}"

			_disp[cls]="${dcls__ref[__superclass__]}"
			_disp[head]="${stack[1]}"
			;;
		class)
			;;
		*)
			if [[ -v dobj__ref[__methods__] ]]; then
				local -n dmethods__ref="${dobj__ref[__methods__]}"
				if [[ -v dmethods__ref[${_disp[head]}] ]]; then
					_disp[cls]="${dobj__ref[__class__]}"
					_disp[func]="${dmethods__ref[${_disp[head]}]}"
					_disp[resolved]=1
				fi
			fi
			;;
	esac

	if [[ ${_disp[resolved]} -ne 1 ]]; then
		lcls="${_disp[cls]}"
		while [[ -n "$lcls" ]]; do
			local -n pcls__ref="$lcls"
			if [[ -v pcls__ref[__prototype__] ]]; then
				local -n cproto__ref="${pcls__ref[__prototype__]}"
				if [[ -v cproto__ref[__methods__] ]]; then
					local -n pmethods__ref="${cproto__ref[__methods__]}"
					if [[ -v pmethods__ref[${_disp[head]}] ]]; then
						_disp[cls]="${lcls}"
						_disp[func]="${pmethods__ref[${_disp[head]}]}"
						_disp[resolved]=1
						break
					fi
				fi
			fi
			if [[ -n pcls__ref[__superclass__] && "${pcls__ref[__superclass__]}" != "$lcls" ]]; then
				lcls="${pcls__ref[__superclass__]}"
				continue
			fi
			lcls=""
		done
	fi

	return 0
}

function __hbl__Object__dispatch_function_() {
	[[ $# -ge 4 && -n "$1" && -n "$2" && -n "$3" && -n "$4" ]] ||
		$Error.argument || return
	local dcls dfunc dobj rc
	dsel="$1" dcls="$2" dfunc="$3" dobj="$4" rc=0; shift 4

	# push to the stack
	__hbl__stack+=("$dobj $dsel $dcls $dfunc")

	# run the function
	"$dfunc" "$dobj" "$@" || rc=$?

	# pop the stack
	unset __hbl__stack[-1]

	return $rc
}

function __hbl__Object__dispatch_() {
	[[ $# -ge 2 && -n "$1" && -n "$2" && "$2" =~ ^\. ]] ||
		$Error.argument || return

	local -n _disp="__hbl__dispatcher"

	_disp[obj]="$1" _disp[sel]="$2" _disp[head]="" _disp[tail]="" _disp[cls]=""
	_disp[func]="" _disp[resolved]=0

	shift 2

	__hbl__Object__resolve_method_ || return

	if [[ ${_disp[resolved]} -eq 1 ]]; then
		if [[ -n "${_disp[tail]}" ]]; then
			set -- "${_disp[tail]}" "$@"
		fi
		__hbl__Object__dispatch_function_ \
			"${_disp[head]}" \
			"${_disp[cls]}" \
			"${_disp[func]}" \
			"${_disp[obj]}" \
			"$@"
		return
	fi

	__hbl__Class__resolve_method_ || return


	if [[ ${_disp[resolved]} -eq 1 ]]; then
		# call the function
		${_disp[func]} "$@"
		return
	fi

	$Error.undefined_method || exit
}

function __hbl__Object__new_() {
	[[ $# -eq 1 && -n "$1" ]] || $Error.argument || return

	local -n obj__ref="$1"

	obj__ref[0]="__hbl__Object__dispatch_ $1 "
	obj__ref[__id__]=$1
	obj__ref[__methods__]="${1}__methods"

	declare -Ag "${obj__ref[__methods__]}"
	local -n obj_methods__ref="${obj__ref[__methods__]}"
	obj_methods__ref=()
	__hbl__object__id=$((__hbl__object__id+1))

	__hbl__objects+=("${!obj__ref}")

	return 0
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

function __hbl__Object__add_method() {
	local -n this="$1"
	local -n omethods__ref="${this[__methods__]}"

	omethods__ref[$2]="$3"

	return 0
}

function __hbl__Object__add_getter() {
	[[ $# -eq 2 && -n "$1" && -n "$2" ]] || $Error.argument || return

	local obj attr getter
	obj="$1" attr="$2" getter=""

	# make getter function
	getter="${obj}_get_${attr}"
	source /dev/stdin <<-EOF
		function ${getter}() {
			__hbl__Object__read_attribute "\$1" "$attr" "\${@:2}";
		};
	EOF

	__hbl__Object__add_method "${obj}" "get_$attr" "$getter"
}

function __hbl__Object__add_setter() {
	[[ $# -eq 2 && -n "$1" && -n "$2" ]] || $Error.argument || return

	local obj attr setter
	obj="$1" attr="$2" setter=""

	# make getter function
	setter="${obj}__set_${attr}"
	source /dev/stdin <<-EOF
		function ${setter}() {
			__hbl__Object__write_attribute "\$1" "${attr}" "\${@:2}";
		};
	EOF

	__hbl__Object__add_method "${obj}" "set_${attr}" "${setter}"
}

function __hbl__Object__add_reference() {
	[[ $# -eq 3 && -n "$1" && -n "$2" ]] || $Error.argument || return

	local ref ref_func
	ref="$2"
	local -n this="$1"

	ref_func="${!this}__ref__${ref}"

	source /dev/stdin <<-EOF
		function ${ref_func}() {
			__hbl__Object__delegate_to_reference "\$1" "$ref" "\${@:2}";
		};
	EOF

	__hbl__Object__add_method "${!this}" "$ref" "$ref_func"
}

function __hbl__Object__read_attribute() {
	[[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] ||
		$Error.argument || return

	local -n obj__ref="$1" ret__ref="$3"

	ret__ref="${obj__ref[$2]}"

	return 0
}

function __hbl__Object__write_attribute() {
	[[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] || $Error.argument || return

	local -n this="$1"

	this[$2]="$3"

	return 0
}

function __hbl__Object__assign_reference() {
	[[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] || $Error.argument || return

	local obj_id
	local -n this="$1"

	if [[ "$3" =~ ^__hbl__Object__dispatch_ ]]; then
		$3._get_id_ obj_id
		this[__ref_$2]="$obj_id"
	else
		this[__ref_$2]="$3"
	fi

}

function __hbl__Object__delegate_to_reference() {
	[[ $# -ge 3 && -n "$1" && -n "$2" && -n "$3" ]] || $Error.argument || return

	# TODO: Add some sanity checking
	local -n this="$1"
	__hbl__Object__dispatch_ "${this[__ref_$2]}" "$3" "${@:4}"
}

function __hbl__Object__init() {
	return 0
}

function __hbl__Object__new() {
	[[ $# -eq 2 && -n "$1" && -n "$2" ]] || $Error.argument || return

	local cls
	cls="$1"
	local -n id__ref="$2"

	id__ref="__hbl__${cls}_${__hbl__object__id}"

	declare -Ag "$id__ref"
	__hbl__Object__new_ "$id__ref" || return

	return 0
}
