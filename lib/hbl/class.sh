declare -Ag __Class__vtbl
__Class__vtbl=(
	[define]=_class_define
	[new]=class_new
	[method]=_instance_method
	[static_method]=_class_method
	[__next]=__Object__vtbl
)
readonly __Class__vtbl

declare -Ag __Class__pvtbl
__Class__pvtbl=(
	[__ctor]=_class_init
	[__next]=__Object__pvtbl
)
readonly __Class__pvtbl

declare -Ag __Class__pattrs
__Class__pattrs=()
readonly __Class__pattrs

declare -Ag __Class
__Class=(
	[__name]="Class"
	[__ancestor]=""
	[__vtbl]=__Class__vtbl
	[__pvtbl]=__Class__pvtbl
	[__pattrs]=__Class__pattrs
)

declare -g Class
Class="_object_dispatch __Class__vtbl __Class__vtbl __Class '' "
readonly Class

function _class_define() {
	local pcls pcls_vtbl pcls_pvtbl ncls ncls_name ncls_ctor
	pcls="$1" ncls_name="$2" ncls_ctor="$3"

	# create the class
	ncls="_Class_$ncls_name"
	declare -Ag $ncls
	local -n ncls__ref=$ncls
	ncls__ref=(
		[__name]=$ncls_name
		[__ancestor]='Object'
		[__vtbl]="__Class_${ncls_name}__vtbl"
		[__pvtbl]="__Class_${ncls_pvtbl}__pvtbl"
		[__pattrs]="__Class_${ncls_name}__pattrs"
	)
	declare -g "$ncls_name"

	# create the class vtable
	$pcls.__vtbl pcls_vtbl
	declare -Ag ${ncls__ref[__vtbl]}
	local -n ncls_vtbl__ref=${ncls__ref[__vtbl]}
	ncls_vtbl__ref=(
		[__next]=$pcls_vtbl
	)

	# create the class prototype vtable
	$pcls.__pvtbl pcls_pvtbl
	declare -Ag ${ncls__ref[__pvtbl]}
	local -n ncls_pvtbl__ref=${ncls__ref[__pvtbl]}
	ncls_pvtbl__ref=(
		[__next]=$pcls_pvtbl
	)
	[[ -n "$cls_ctor" ]] && ncls_pvtbl__ref[__ctor]=$cls_ctor

	# create the class prototype_attributes
	declare -Ag ${ncls__ref[__pattrs]}
	local -n ncls_pattrs__ref=${ncls__ref[__pattrs]}
	ncls_pattrs__ref=()

	local -n ncls_dispatch__ref=$ncls_name
	ncls_dispatch__ref="_object_dispatch ${ncls__ref[__vtbl]} ${ncls__ref[__vtbl]} $ncls '' "
}

function _instance_method() {
	# printf "*** _instance_method() ***\n"
	# printf "args: %s\n" "$@"
	local cls cls_pvtbl meth_func meth_name
	cls="$1" meth_name="$2" meth_func="$3"

	$cls.__pvtbl cls_pvtbl

	local -n cls_pvtbl__ref=$cls_pvtbl
	cls_pvtbl__ref[$meth_name]="$meth_func"
}

function _static_method() {
	# printf "*** _static_method() ***\n"
	# printf "args: %s\n" "$@"
	local cls cls_vtbl meth_func meth_name
	cls="$1" meth_name="$2" meth_func="$3"

	$cls._vtbl cls_vtbl

	local -n cls_vtbl__ref=$cls_vtbl
	cls_vtbl__ref[$meth_name]="$meth_func"
}

function _private_attribute() {
	local class
}

function class_new() {
	# printf "*** class_new() ***\n" >&3
	# printf "args: %s\n" "$@" >&3
	local cls
	cls=$1

	$cls:super $2
	local -n obj="$2"
	$obj:__ctor "$obj"
}

function _class_init() {
	# printf "*** _class_init() ***\n"
	# printf "args: %s\n" "$@" >&3
	local obj
	obj=$1
	$obj._base_id= 8675309
	return 0
}
