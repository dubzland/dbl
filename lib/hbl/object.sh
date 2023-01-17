#!/usr/bin/env bash

declare -a __objects
__objects=()

declare -Ag __Object__vtbl
__Object__vtbl=(
	[new]=_object_new
)
readonly __Object__vtbl

declare -Ag __Object__pvtbl
__Object__pvtbl=(
	[inspect]=_object_inspect
)
readonly __Object__pvtbl

declare -Ag __Object__pattrs
__Object__pattrs=()
readonly __Object__pattrs

declare -Ag __Object
__Object=(
	[__name]="Object"
	[__cls]="__Object"
	[__vtbl]=__Object__vtbl
	[__pvtbl]=__Object__pvtbl
	[__pattrs]=__Object__pattrs
)
readonly __Object

declare -g Object
Object="_object_dispatch __Object__vtbl __Object__vtbl __Object '' "
readonly Object

function _object_inspect() {
	local attrs obj obj_id
	obj=$1
	$obj.__id obj_id
	printf "<%s" "$obj_id"
	$object.__attrs attrs
	local -n attrs__ref=$attrs
	for key in "${!attrs__ref[@]}"; do
		printf " %s='%s'" "$key" "${attrs__ref[$key]}"
	done

	printf ">\n"
}

function _object_find_method() {
	# printf "*** _object_find_method() ***\n"
	# printf "args: %s\n" "$@"
	local vtbl meth_name meth_vtbl_var
	vtbl=$1 meth_name=$2 meth_vtbl_var="$3"

	while [[ -n $vtbl ]]; do
		local -n vtbl__ref=$vtbl
		if [[ -v ${vtbl}[$meth_name] ]]; then
			local -n meth_vtbl__ref=$meth_vtbl_var
			meth_vtbl__ref=$vtbl
			break
		else
			if [[ -v ${vtbl}[__next] ]]; then
				vtbl=${vtbl__ref[__next]}
				continue
			else
				vtbl=""
			fi
		fi
	done

	[[ -n "$meth_vtbl__ref" ]]
}

function _object_process_attribute() {
	# printf "*** _object_process_attribute() ***\n" >&3
	# printf "args: %s\n" "$@" >&3
	local tgt attr
	tgt=$3 attr="${5#.}"

	local -n tgt__ref=$tgt
	if [[ "$attr" =~ \=$ ]]; then
		if [[ "$attr" =~ ^__ ]]; then
			printf "setting system attributes is not allowed.\n" && return 1
		fi
		local -n attrs__ref=${tgt__ref[__attrs]}
		# set an attribute value
		[[ $# -ge 6 ]] || printf "Missing attribute ref\n" >&2 || return 1
		attrs__ref[${attr%=}]="$6"
	else
		# get an attribute value
		local -n attr__ref="$6"
		if [[ "$attr" =~ ^__ ]]; then
			if [[ -v tgt__ref[${attr}] ]]; then
				attr__ref="${tgt__ref[$attr]}"
			else
				printf "did not find system attribute %s on %s.\n" "$attr" "$tgt"
				return 1
			fi
		else
			local -n attrs__ref=${tgt__ref[__attrs]}
			if [[ -v attrs__ref[${attr}] ]]; then
				attr__ref="${attrs__ref[$attr]}"
			else
				printf "did not find attribute %s on %s.\n" "$attr" "$tgt"
				return 1
			fi
		fi
	fi
}

function _object_process_method() {
	# printf "*** _object_process_method() ***\n"
	# printf "args: %s\n" "$@"
	local tgt_vtbl sup_vtbl tgt curr_meth meth meth_vtbl
	local tgt_vtbl=$1 sup_vtbl=$2 tgt=$3 curr_meth=$4 meth=$5
	local -a dispatch_args
	local -n tgt_vtbl__ref=$tgt_vtbl

	if [[ "$meth" = ":super" ]]; then
		meth="$curr_meth"
		local -n sup_vtbl__ref=$sup_vtbl
		meth_vtbl="${sup_vtbl__ref[__next]}"
	else
		meth="${5#\:}"
		meth_vtbl=$tgt_vtbl
	fi
	dispatch_args=("${@:6}")

	if _object_find_method $meth_vtbl $meth meth_vtbl; then
		local -n meth_vtbl__ref=$meth_vtbl
		${meth_vtbl__ref[$meth]} \
			"_object_dispatch $tgt_vtbl $meth_vtbl $tgt $meth " \
			"${dispatch_args[@]}"
	else
		hbl__error__undefined_method_ 3 "$meth" || return
	fi
}

function _object_dispatch() {
	# printf "*** _object_dispatch() ***\n" >&3
	# printf "args: %s\n" "$@" >&3
	local selector
	selector="$5"

	if [[ "$selector" =~ ^\. ]]; then
		_object_process_attribute "$@"
	elif [[ "$selector" =~ ^\: ]]; then
		_object_process_method "$@"
	else
		printf "bad selector: %s\n" "$selector" >&2 && return 1
	fi
}

function _object_declare_associative_array() {
	return 0
}

function _object_new() {
	# printf "*** _object_new() ***\n" >&3
	# printf "args: %s\n" "$@" >&3
	[[ $# -ge 2 ]] || hbl__error__invocation_ 3 "$@" || return
	[[ -n "$1" ]] || hbl__error__argument_ 3 base_name "$1" || return
	[[ -n "$2" ]] || hbl__error__argument_ 3 dispatch_var "$2" || return

	local cls cls_name nobj_dispatch nobj_id
	cls="$1" nobj_dispatch="$2"

	# get the base class name and prototype
	$cls.__name cls_name
	$cls.__pvtbl cls_pvtbl

	# build a unique object_id based on class and object count
	nobj_id="__${cls_name}_${#__objects[@]}"

	# declare and initialize the global object
	declare -Ag $nobj_id
	local -n nobj=$nobj_id
	nobj=(
		[__id]=$nobj_id
		[__class]=$cls_name
		[__attrs]="${nobj_id}__attrs"
		[__vtbl]=$cls_pvtbl
	)

	# create the object attributes
	declare -Ag ${nobj[__attrs]}
	local -n nobj_attrs__ref=${nobj[__attrs]}
	nobj_attrs__ref=()

	# setup the dispatch command
	local -n nobj_dispatch__ref=$nobj_dispatch
	nobj_dispatch__ref="_object_dispatch ${nobj[__vtbl]} ${nobj[__vtbl]} $nobj_id '' "

	# store the object in the global array
	__objects+=($nobj_id)
}
