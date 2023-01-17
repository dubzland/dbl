#!/usr/bin/env bash

declare -a __hbl__objects
__hbl__objects=()

declare -Ag __hbl__Object__vtbl
__hbl__Object__vtbl=(
	[new]=hbl__object__new
)
readonly __hbl__Object__vtbl

declare -Ag __hbl__Object__pvtbl
__hbl__Object__pvtbl=(
	[inspect]=hbl__object__inspect
)
readonly __hbl__Object__pvtbl

declare -Ag __hbl__Object__pattrs
__hbl__Object__pattrs=()
readonly __hbl__Object__pattrs

declare -Ag __hbl__Object
__hbl__Object=(
	[__name]="Object"
	[__cls]="__hbl__Object"
	[__vtbl]=__hbl__Object__vtbl
	[__pvtbl]=__hbl__Object__pvtbl
	[__pattrs]=__hbl__Object__pattrs
)
readonly __hbl__Object

declare -g Object
Object="hbl__object__dispatch_ __hbl__Object__vtbl __hbl__Object__vtbl __hbl__Object '' "
readonly Object

function hbl__object__inspect() {
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

function hbl__object__find_method_() {
	# printf "*** hbl__object__find_method_() ***\n"
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

function hbl__object__process_attribute_() {
	# printf "*** hbl__object__process_attribute_() ***\n" >&3
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
		[[ -v attrs__ref[${attr%=}] ]] || printf "invalid attribute: %s\n" "${attr%=}" || return 1
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

function hbl__object__process_method_() {
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

	if hbl__object__find_method_ $meth_vtbl $meth meth_vtbl; then
		local -n meth_vtbl__ref=$meth_vtbl
		${meth_vtbl__ref[$meth]} \
			"hbl__object__dispatch_ $tgt_vtbl $meth_vtbl $tgt $meth " \
			"${dispatch_args[@]}"
	else
		hbl__error__undefined_method_ 3 "$meth" || return
	fi
}

function hbl__object__dispatch_() {
	# printf "*** hbl__object__dispatch_() ***\n" >&3
	# printf "args: %s\n" "$@" >&3
	local selector
	selector="$5"

	if [[ "$selector" =~ ^\. ]]; then
		hbl__object__process_attribute_ "$@"
	elif [[ "$selector" =~ ^\: ]]; then
		hbl__object__process_method_ "$@"
	else
		printf "bad selector: %s\n" "$selector" >&2 && return 1
	fi
}

function hbl__object__new() {
	# printf "*** _object__new() ***\n" >&3
	# printf "args: %s\n" "$@" >&3
	[[ $# -ge 2 ]] || hbl__error__invocation_ 3 "$@" || return
	[[ -n "$1" ]] || hbl__error__argument_ 3 base_name "$1" || return
	[[ -n "$2" ]] || hbl__error__argument_ 3 dispatch_var "$2" || return

	local cls cls_name cls_pattrs nobj_dispatch nobj_id
	cls="$1" nobj_dispatch="$2"

	# get the base class name and prototype
	$cls.__name cls_name
	$cls.__pvtbl cls_pvtbl
	$cls.__pattrs cls_pattrs

	# build a unique object_id based on class and object count
	nobj_id="__hbl__${cls_name}_${#__objects[@]}"

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
	local -n cls_pattrs__ref="$cls_pattrs"
	for key in "${!cls_pattrs__ref[@]}"; do
		case "${cls_pattrs__ref[$key]}" in
			$HBL_STRING) nobj_attrs__ref[$key]='' ;;
			$HBL_ARRAY|$HBL_ASSOCIATIVE_ARRAY)
				local attr_id="${nobj_id}__attrs__$key"
				if [[ ${cls_pattrs__ref[$key]} -eq $HBL_ARRAY ]]; then
					declare -ag $attr_id
				else
					declare -Ag $attr_id
				fi
				local -n attr__ref=$attr_id
				attr__ref=()
				nobj_attrs__ref[$key]=$attr_id
				;;
			*)
				local -i found=0
				for hbl_cls in "${__hbl__classes[@]}"; do
					# just set it to empty string for now.
					# TODO: figure out how to delay initialization to allow
					# classes to initialize their children
					if [[ "${cls_pattrs__ref[$key]}" = "$hbl_cls" ]]; then
						nobj_attrs__ref[$key]=''
						found=1
						break
					fi
				done
				[[ $found -eq 1 ]] ||
					printf "unknown attribute type: %s - %s\n" \
						"$key" \
						"${cls_pattrs__ref[$key]}" ||
					return 1
				;;
		esac
	done


	# setup the dispatch command
	local -n nobj_dispatch__ref=$nobj_dispatch
	nobj_dispatch__ref="hbl__object__dispatch_ ${nobj[__vtbl]} ${nobj[__vtbl]} $nobj_id '' "

	# store the object in the global array
	__objects+=($nobj_id)

	return $HBL_SUCCESS
}
