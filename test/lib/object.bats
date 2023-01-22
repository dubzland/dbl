setup() {
	load '../test_helper/common'
	common_setup
}

@test 'Object.is_object() for a valid object succeeds' {
	local -A obj=([__class]=Object)
	run $Object.is_object obj
	assert_success
	refute_output
}

@test 'Object.is_object() for an invalid object succeeds' {
	local -A obj=()
	run $Object.is_object obj
	assert_failure $HBL_ERROR
	refute_output
}

@test 'initializing an object succeeds' {
	local -A obj=()
	run Object__init obj
	assert_success
	refute_output
}

@test 'initializing an object assigns the proper attributes' {
	local -A obj=()
	Object__init obj
	assert_dict_has_key obj __class
	assert_equal "${obj[__class]}" Object
	assert_dict_has_key obj __prototype
	assert_equal "${obj[__prototype]}" Object__prototype
}

@test 'Object#inspect() succeeds' {
	local -A obj=()
	Object__init obj
	run Object__inspect obj
	assert_success
}

@test 'Object#inspect() displays attributes' {
	local -A obj=()
	Object__init obj
	obj[_attrA]='red'
	obj[_attrB]='blue'
	run Object__inspect obj
	assert_output "<obj _attrB='blue' _attrA='red'>"
}
