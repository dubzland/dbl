declare -Ag Class__vtable
Class__vtable=(
	[define]=_class_define
	[new]=class_new
	[method]=_instance_method
	[static_method]=_class_method
	[__next]=Object__vtable
)

declare -Ag Class__prototype
Class__prototype=(
	[__ctor]=_class_init
	[__next]=Object__prototype
)

declare -Ag _Class
_Class=(
	[__name]="Class"
	[__ancestor]=""
	[__vtable]=Class__vtable
	[__prototype]=Class__prototype
)

declare -g Class
Class="_dispatch Class__vtable Class__vtable _Class '' "
readonly Class

function _class_define() {
	local parent_class parent_vtable parent_prototype define_class_name define_class_new define_class
	local class_vtable_name class_prototype_name
	parent_class="$1" define_class_name="$2" define_class_new="$3" define_class_dispatch="$4"

	# create the class vtable
	$parent_class._vtable parent_vtable
	$parent_class._prototype parent_prototype
	class_vtable_name="_Class_${define_class_name}__vtable"
	declare -Ag $class_vtable_name
	local -n class_vtable__ref=$class_vtable_name
	# printf "setting __next vtable to %s\n" "$parent_vtable"
	class_vtable__ref=(
		[__next]=$parent_vtable
	)

	# create the class prototype
	class_prototype_name="_Class_${define_class_name}__prototype"
	declare -Ag $class_prototype_name
	local -n class_prototype__ref=$class_prototype_name
	# printf "setting __next prototype for %s to %s\n" "$define_class_name" "$parent_prototype"
	class_prototype__ref=(
		[__ctor]=$define_class_new
		[__next]=$parent_prototype
	)

	# create the class
	define_class="_Class_$define_class_name"
	declare -Ag $define_class
	local -n class__ref=$define_class
	class__ref=(
		[__name]=$define_class_name
		[__ancestor]="Object"
		[__vtable]=$class_vtable_name
		[__prototype]=$class_prototype_name
	)
	declare -g "$define_class_name"
	local -n class_dispatch__ref=$define_class_name
	class_dispatch__ref="_dispatch $class_vtable_name $class_vtable_name ${define_class} '' "
}

function _instance_method() {
	# printf "*** _instance_method() ***\n"
	# printf "args: %s\n" "$@"
	local class_prototype class method_name method_function class_id
	local class="$1" method_name="$2" method_function="$3"

	$class._prototype class_prototype

	local -n class_prototype__ref=$class_prototype
	class_prototype__ref[$method_name]="$method_function"
}

function class_new() {
	local class
	class=$1

	$class:super $2
	local -n object="$2"

	$object:__ctor "$object"
}

function _class_init() {
	printf "*** _class_init() ***\n"
	local object
	object=$1
	$object._base_id= 8675309
	return 0
}
