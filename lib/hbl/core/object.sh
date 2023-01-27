#!/usr/bin/env bash

function __hbl__Object__get_id_() {
	[[ $# -eq 2 && -n "$1" && -n "$2" ]] || $Error.argument || return
	local -n this="$1" val__ref="$2"
	val__ref="${this[__id__]}"
}

function __hbl__Object__get_class_() {
	[[ $# -eq 2 && -n "$1" && -n "$2" ]] || $Error.argument || return
	local -n this="$1" val__ref="$2"
	val__ref="${this[__class__]}"
}

function __hbl__Object__push_frame_() {
	[[ $# -ge 1 && -n "$1" ]] || $Error.argument || return

	local rc=0
	local -n frame__ref="$1" && shift

	if [[ -n "${frame[object]}" ]]; then
		# push a frame to the stack
		local frame_str
		printf -v frame_str "%q %q %q %q" \
			"${frame__ref[object]}" \
			"${frame__ref[method]}" \
			"${frame__ref[class]}" \
			"${frame__ref[function]}"

		__hbl__stack+=("${frame_str}")

		# run the function
		${frame__ref[function]} "${frame__ref[object]}" "$@" || rc=$?

		# pop the stack
		unset __hbl__stack[-1]
	else
		# static methods don't need anything on the stack
		${frame__ref[function]} "$@" || rc=$?
	fi

	return $rc
}

function __hbl__Object__dispatch_() {
	[[ $# -ge 2 && -n "$1" && -n "$2" && "$2" =~ ^\. ]] ||
		$Error.argument || return

	local selector lcls lfunc
	local -i resolved
	local -a pframe
	local -A frame

	selector="${2#\.}" lcls="" lfunc=""
	pframe=() frame=() resolved=0

	frame[object]="$1" frame[method]="" frame[class]="" frame[function]=""

	shift 2

	frame[method]="${selector%%.*}"
	if [[ -n "${selector#${frame[method]}}" ]]; then
		set -- "${selector#${frame[method]}}" "$@"
	fi

	local -n __obj__ref="${frame[object]}"
	lcls="${__obj__ref[__class__]}"
	frame[class]="${lcls}"

	if [[ "${frame[method]}" = super ]]; then
		[[ ${#__hbl__stack[@]} -gt 0 ]] || {
			printf "no previous function call to execute super.\n";
			$Error.illegal_instruction || return
		}

		pframe=(${__hbl__stack[-1]})

		[[ "${frame[object]}" = "${pframe[0]}" ]] || return
		[[ "${FUNCNAME[1]}" = "${pframe[3]}" ]] || return


		# We're still in the last function we called.
		# Grab a reference to the last class we dispatched to and move
		# to its superclass.
		local -n scls__ref="${pframe[2]}"
		frame[class]="${scls__ref[__superclass__]}"
		frame[method]="${pframe[1]}"
	else
		if [[ "${frame[method]}" = class ]]; then
			# set the object to this object's class
			frame[object]="${frame[class]}"
			local -n ccls__ref="${frame[object]}"
			frame[class]="${ccls__ref[__class__]}"
			frame[method]="$1"
			frame[method]="${frame[method]%%.*}"
			set -- "${1#${frame[method]}}" "${@:2}"
			frame[method]="${frame[method]#\.}"
		fi

		local -n dobj__ref="${frame[object]}"
		if [[ -v dobj__ref[__methods__] ]]; then
			local -n dmethods__ref="${dobj__ref[__methods__]}"
			if [[ -v dmethods__ref[${frame[method]}] ]]; then
				frame[function]="${dmethods__ref[${frame[method]}]}"
				resolved=1
			fi
		fi
	fi

	if [[ $resolved -ne 1 ]]; then
		lcls="${frame[class]}"
		while [[ -n "$lcls" ]]; do
			local -n pcls__ref="$lcls"
			if [[ -v pcls__ref[__prototype__] ]]; then
				local -n cproto__ref="${pcls__ref[__prototype__]}"
				if [[ -v cproto__ref[__methods__] ]]; then
					local -n pmethods__ref="${cproto__ref[__methods__]}"
					if [[ -v pmethods__ref[${frame[method]}] ]]; then
						frame[class]="${lcls}"
						frame[function]="${pmethods__ref[${frame[method]}]}"
						resolved=1
						break
					fi
				fi
			fi
			if [[ -n pcls__ref[__superclass__] &&
				"${pcls__ref[__superclass__]}" != "$lcls" ]]; then
				lcls="${pcls__ref[__superclass__]}"
				continue
			fi
			lcls=""
		done
	fi

	if [[ $resolved -eq 1 ]]; then
		__hbl__Object__push_frame_ frame "$@"
		return
	fi

	lcls="${frame[object]}"
	while [[ -n "$lcls" ]]; do
		local -n mcls__ref="$lcls"
		if [[ -v mcls__ref[__static_methods__] ]]; then
			local -n cmethods__ref="${mcls__ref[__static_methods__]}"
			if [[ -v cmethods__ref[${frame[method]}] ]]; then
				frame[function]="${cmethods__ref[${frame[method]}]}"
				resolved=1
				break
			fi
		fi

		if [[ -v mcls__ref[__superclass__] &&
			"${mcls__ref[__superclass__]}" != "$lcls" ]]; then
			lcls="${mcls__ref[__superclass__]}"
			continue
		fi
		lcls=""
	done

	if [[ $resolved -eq 1 ]]; then
		# call the function
		frame[object]=''
		__hbl__Object__push_frame_ frame "$@"
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
