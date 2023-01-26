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

function dump_stack_() {
	printf "\n* * * * * S T A C K * * * * *\n"
	for item in "${__hbl__stack[@]}"; do
		printf "%s\n" "$item"
	done
	printf "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^\n\n"
}

function dump_array_() {
	printf "\n* * * * * %s * * * * *\n" "$1"
	local -n _dump_array__ref="$1"
	for item in "${_dump_array__ref[@]}"; do
		printf "%s\n" "$item"
	done
	printf "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^\n\n"
}

function __hbl__Object__get_method_() {
	[[ $# -eq 4 && -n "$1" && -n "$2" && -n "$3" && -n "$4" ]] || return $HBL_ERR_ARGUMENT
	local dobj dmeth
	dobj="$1" dmeth="$2"
	local -n dcls__ref="$3" dfunc__ref="$4"

	local -n dobj__ref="$dobj"
	if [[ -v dobj__ref[__methods__] ]]; then
		local -n dmethods__ref="${dobj__ref[__methods__]}"
		if [[ -v dmethods__ref[$dmeth] ]]; then
			dcls__ref="${dobj__ref[__class__]}"
			dfunc__ref="${dmethods__ref[$dmeth]}"
			return $HBL_SUCCESS
		fi
	fi

	__hbl__Class__get_prototype_method_ "${dobj__ref[__class__]}" "$dmeth" \
		"${!dcls__ref}" "${!dfunc__ref}" || return

	return $HBL_SUCCESS
}

function __hbl__Object__dispatch_function_() {
	[[ $# -ge 4 && -n "$1" && -n "$2" && -n "$3" && -n "$4" ]] || return $HBL_ERR_ARGUMENT
	local dcls dfunc dobj
	dsel="$1" dcls="$2" dfunc="$3" dobj="$4"; shift 4

	# push to the stack
	__hbl__stack+=("$dobj $dsel $dcls $dfunc")
	rc=$HBL_SUCCESS
	"$dfunc" "$dobj" "$@" || rc=$?
	unset __hbl__stack[-1]
	return $rc
}

function __hbl__Object__dispatch_() {
	[[ $# -ge 2 && -n "$1" && -n "$2" ]] || return $HBL_ERR_ARGUMENT
	[[ "$2" =~ ^\. ]] || return $HBL_ERR_ARGUMENT
	local dobj dsel dcls dfunc dsuper head tail
	local -a dargs
	dobj="$1" dsel="${2#\.}" dcls='' dfunc='' dargs=()
	shift 2

	head="${dsel%%.*}" tail="${dsel#${head}}"
	[[ -n "$tail" ]] && dargs+=("$tail") || true
	dargs+=("$@")

	if [[ "$head" = 'super' ]]; then
		[[ ${#__hbl__stack[@]} -gt 0 ]] || {
			printf "no previous function call to execute super.\n";
			return $HBL_ERR_ILLEGAL_INSTRUCTION;
		}
		[[ -z "$tail" ]] || {
			printf "super cannot be chained\n";
			return $HBL_ERR_ILLEGAL_INSTRUCTION;
		}
		local -a stack_head=(${__hbl__stack[-1]})
		if [[ "$dobj" = "${stack_head[0]}" && "${FUNCNAME[1]}" = "${stack_head[3]}" ]]; then
			# look for a prototype method for the parent class
			local -n dcls__ref="${stack_head[2]}"
			__hbl__Class__get_prototype_method_ "${dcls__ref[__superclass__]}" \
				"${stack_head[1]}" dcls dfunc || return
		else
			printf "bad\n"
			return $HBL_ILLEGAL_INSTRUCTION
		fi
	elif [[ "$head" = 'class' ]]; then
		return 0
	else
		__hbl__Object__get_method_ "$dobj" "$head" dcls dfunc || return
	fi

	if [[ -n "$dfunc" ]]; then
		rc=$HBL_SUCCESS
		__hbl__Object__dispatch_function_ "$head" "$dcls" "$dfunc" "$dobj" "${dargs[@]}" || rc=$?
		return $rc
	fi

	__hbl__Class__get_method_ "$dobj" "$dsel" dfunc || return

	if [[ -n "$dfunc" ]]; then
		# call the function
		${dfunc} "$@"
	else
		return $HBL_ERR_UNDEFINED_METHOD
	fi
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
		if [[ -n mcls__ref[__superclass__] && "${mcls__ref[__superclass__]}" != "$mcls" ]]; then
			mcls="${mcls__ref[__superclass__]}"
			continue
		fi
		mcls=""
	done

	return $HBL_SUCCESS
}

function __hbl__Object__add_method() {
	local -n this="$1"
	local -n obj__ref="$1"

	local -n omethods__ref="${obj__ref[__methods__]}"

	omethods__ref[$2]="$3"

	return $HBL_SUCCESS
}

function __hbl__Object__add_getter() {
	[[ $# -eq 2 && -n "$1" && -n "$2" ]] || return $HBL_ERR_ARGUMENT

	local attr="$2"
	local -n this="$1"

	# make getter function
	local getter="${!this}_get_${attr}"
	source /dev/stdin <<-EOF
		function ${getter}() {
			__hbl__Object__read_attribute "\$1" "$attr" "\${@:2}";
		};
	EOF

	__hbl__Object__add_method "${!this}" "get_$attr" "$getter"
}

function __hbl__Object__add_setter() {
	[[ $# -eq 2 && -n "$1" && -n "$2" ]] || return $HBL_ERR_ARGUMENT

	local -n this="$1"
	local attr="$2"

	# make getter function
	local setter="${!this}__set_${attr}"
	source /dev/stdin <<-EOF
		function ${setter}() {
			__hbl__Object__write_attribute "\$1" "$attr" "\${@:2}";
		};
	EOF

	__hbl__Object__add_method "${!this}" "set_$attr" "$setter"
}

function __hbl__Object__add_reference() {
	[[ $# -eq 3 && -n "$1" && -n "$2" ]] || return $HBL_ERR_ARGUMENT

	local ref="$2"
	local -n this="$1"

	local ref_func="${!this}__ref__${ref}"
	source /dev/stdin <<-EOF
		function ${ref_func}() {
			__hbl__Object__delegate_to_reference "\$1" "$ref" "\${@:2}";
		};
	EOF

	__hbl__Object__add_method "${!this}" "$ref" "$ref_func"
}

function __hbl__Object__read_attribute() {
	[[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] || return $HBL_ERR_ARGUMENT

	local -n obj__ref="$1"

	local -n ret__ref="$3"

	ret__ref="${obj__ref[$2]}"

	return $HBL_SUCCESS
}

function __hbl__Object__write_attribute() {
	[[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] || return $HBL_ERR_ARGUMENT

	local -n this="$1"

	this[$2]="$3"

	return $HBL_SUCCESS
}

function __hbl__Object__assign_reference() {
	[[ $# -eq 3 && -n "$1" && -n "$2" && -n "$3" ]] || return $HBL_ERR_ARGUMENT

	local -n this="$1"

	if [[ "$3" =~ ^__hbl__Object__dispatch_ ]]; then
		local obj_id
		$3._get_id_ obj_id
		this[__ref_$2]="$obj_id"
	else
		this[__ref_$2]="$3"
	fi

}

function __hbl__Object__delegate_to_reference() {
	[[ $# -ge 3 && -n "$1" && -n "$2" && -n "$3" ]] || return $HBL_ERR_ARGUMENT

	# TODO: Add some sanity checking
	local -n this="$1"
	__hbl__Object__dispatch_ "${this[__ref_$2]}" "$3" "${@:4}"
}

function __hbl__Object__get_id_() {
	local -n this="$1"
	local -n val__ref="$2"
	val__ref="${this[__id__]}"
}

function __hbl__Object__init() {
	return $HBL_SUCCESS
}

function __hbl__Object__new_() {
	[[ $# -eq 1 && -n "$1" ]] || return $HBL_ERR_ARGUMENT

	local -n obj__ref="$1"

	obj__ref[0]="__hbl__Object__dispatch_ $1 "
	obj__ref[__id__]=$1
	obj__ref[__methods__]="${1}__methods"

	declare -Ag "${obj__ref[__methods__]}"
	local -n obj_methods__ref="${obj__ref[__methods__]}"
	obj_methods__ref=()
	__hbl__object__id=$((__hbl__object__id+1))

	return $HBL_SUCCESS
}

function __hbl__Object__new() {
	[[ $# -eq 2 && -n "$1" && -n "$2" ]] || return $HBL_ERR_ARGUMENT

	local cls
	cls="$1"
	local -n id__ref="$2"

	id__ref="__hbl__${cls}_${__hbl__object__id}"

	declare -Ag "$id__ref"
	__hbl__Object__new_ "$id__ref" || return

	return $HBL_SUCCESS
}
