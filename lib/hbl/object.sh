#!/usr/bin/env bash

declare -a __objects
__objects=()

declare -Ag __Object__vtable
__Object__vtable=(
	[new]=_object_new
)
readonly __Object__vtable

declare -Ag __Object__prototype
__Object__prototype=(
	[inspect]=_object_inspect
)
readonly __Object__prototype

declare -Ag __Object
__Object=(
	[__name]="Object"
	[__class]="__Object"
	[__vtable]=__Object__vtable
	[__prototype]=__Object__prototype
)
readonly __Object

declare -g Object
Object="_object_dispatch __Object__vtable __Object__vtable __Object '' "
readonly Object

function _object_inspect() {
	local attributes object object_id
	object=$1
	$object.__id object_id
	printf "<%s" "$object_id"
	$object.__attributes attributes
	local -n attributes__ref=$attributes
	for key in "${!attributes__ref[@]}"; do
		printf " %s='%s'" "$key" "${attributes__ref[$key]}"
	done

	printf ">\n"
}

function _object_find_method() {
	# printf "*** _object_find_method() ***\n"
	# printf "args: %s\n" "$@"
	local vtable method_name method_vtable_var
	vtable=$1 method_name=$2 method_vtable_var="$3"

	while [[ -n $vtable ]]; do
		local -n vtable__ref=$vtable
		if [[ -v ${vtable}[$method_name] ]]; then
			local -n method_vtable__ref=$method_vtable_var
			method_vtable__ref=$vtable
			break
		else
			local -n vtable__ref=$vtable
			if [[ -v ${vtable}[__next] ]]; then
				vtable=${vtable__ref[__next]}
				continue
			else
				vtable=""
			fi
		fi
	done

	[[ -n "$method_vtable__ref" ]]
}

function _object_process_attribute() {
	# printf "*** _object_process_attribute() ***\n" >&3
	# printf "args: %s\n" "$@" >&3
	local target attribute
	target=$3 attribute="${5#.}"

	local -n target__ref=$target
	if [[ "$attribute" =~ \=$ ]]; then
		if [[ "$attribute" =~ ^__ ]]; then
			printf "setting system attributes is not allowed.\n" && return 1
		fi
		local -n attributes__ref=${target__ref[__attributes]}
		# set an attribute value
		[[ $# -ge 6 ]] || printf "Missing attribute ref\n" >&2 || return 1
		attributes__ref[${attribute%=}]="$6"
	else
		# get an attribute value
		local -n attribute__ref="$6"
		if [[ "$attribute" =~ ^__ ]]; then
			if [[ -v target__ref[${attribute}] ]]; then
				attribute__ref="${target__ref[$attribute]}"
			else
				printf "did not find system attribute %s on %s.\n" "$attribute" "$target"
				return 1
			fi
		else
			local -n attributes__ref=${target__ref[__attributes]}
			if [[ -v attributes__ref[${attribute}] ]]; then
				attribute__ref="${attributes__ref[$attribute]}"
			else
				printf "did not find attribute %s on %s.\n" "$attribute" "$target"
				return 1
			fi
		fi
	fi
}

function _object_process_method() {
	# printf "*** _object_process_method() ***\n"
	# printf "args: %s\n" "$@"
	local target_vtable super_vtable target current_method method method_vtable
	local target_vtable=$1 super_vtable=$2 target=$3 current_method=$4 method=$5
	local -a dispatch_args
	local -n target_vtable__ref=$target_vtable

	if [[ "$method" = ":super" ]]; then
		method="$current_method"
		local -n super_vtable__ref=$super_vtable
		method_vtable="${super_vtable__ref[__next]}"
	else
		method="${5#\:}"
		method_vtable=$target_vtable
	fi
	dispatch_args=("${@:6}")

	# printf "method_vtable: %s\n" "$method_vtable"
	# printf "super_vtable:  %s\n" "$super_vtable"
	# printf "method: %s\n" "$method"
	if _object_find_method $method_vtable $method method_vtable; then
		# printf "found method %s on vtable %s\n" $method $method_vtable
		local -n method_vtable__ref=$method_vtable
		${method_vtable__ref[$method]} \
			"_object_dispatch $target_vtable $method_vtable $target $method " "${dispatch_args[@]}"
	else
		hbl__error__undefined_method_ 3 "$method" || return
	fi
}

function _object_dispatch() {
	local selector
	selector="$5"

	if [[ "$selector" =~ ^\. ]]; then
		_object_process_attribute "$@"
	elif [[ "$selector" =~ ^\: ]]; then
		_object_process_method "$@"
	else
		printf "bad selector\n" >&2 && return 1
	fi
}

function _object_new() {
	# printf "*** _object_new() ***\n" >&3
	# printf "args: %s\n" "$@" >&3
	[[ $# -ge 2 ]] || hbl__error__invocation_ 3 "$@" || return
	[[ -n "$1" ]] || hbl__error__argument_ 3 base_name "$1" || return
	[[ -n "$2" ]] || hbl__error__argument_ 3 dispatch_var "$2" || return

	local base base_name object_dispatch object_id vtable
	base="$1" object_dispatch="$2"

	# get the base class name and prototype
	$base.__name base_name
	$base.__prototype vtable

	# build a unique object_id based on class and object count
	object_id="__${base_name}_${#__objects[@]}"

	# declare and initialize the global object
	declare -Ag $object_id
	local -n obj=$object_id
	obj=(
		[__id]=$object_id
		[__class]=$base_name
		[__attributes]="${object_id}__attributes"
		[__vtable]=$vtable
	)

	# declare and initialize the attributes associative array
	declare -Ag ${obj[__attributes]}
	local -n attributes__ref="${obj[__attributes]}"
	attributes__ref=()

	# setup the dispatch command
	local -n object_dispatch__ref=$object_dispatch
	object_dispatch__ref="_object_dispatch ${vtable} ${vtable} ${object_id} '' "

	# store the object in the global array
	__objects+=($object_id)
}
