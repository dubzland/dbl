setup() {
	load '../test_helper/common'
	common_setup
}

@test 'Object:new succeeds' {
	local object
	run $Object:new object
	assert_success
}

@test 'objects have an id' {
	local object object_id
	$Object:new object
	$object.__id object_id
	assert_equal $object_id __hbl__Object_0
}

@test 'objects have a class' {
	local object class_name
	$Object:new object
	$object.__class class_name
	assert_equal $class_name Object
}

@test 'objects have a vtable' {
	local object vtbl
	$Object:new object
	$object.__vtbl vtbl
	assert_equal $vtbl __hbl__Object__pvtbl
}

@test 'objects allow setting attributes' {
	local object
	$Object:new object
	run $object.foo= 'bar'
	assert_success
}

@test 'objects prevent setting system attributes' {
	local object
	$Object:new object
	run $object.__bar= 'foo'
	assert_failure
}

@test 'objects allow retrieving attributes' {
	local object val
	$Object:new object
	$object.foo= 'bar'
	run $object.foo val
	assert_success
}

@test 'objects retrieve attributes properly' {
	local object val
	$Object:new object
	$object.foo= 'bar'
	$object.foo val
	assert_equal $val 'bar'
}

@test 'calling an undefined method results in an error' {
	local object
	$Object:new object
	run $object:bad_function
	assert_failure $HBL_ERR_UNDEFINED_METHOD
}

@test 'objects can be inspected' {
	local object
	$Object:new object
	run $object:inspect
	assert_success
	assert_output '<__hbl__Object_0>'
}

@test 'object inspection includes available attributes' {
	local object
	$Object:new object
	$object.foo= 'bar'
	$object.size= 107
	$object.color= 'blue'
	run $object:inspect
	assert_success
	assert_output "<__hbl__Object_0 color='blue' foo='bar' size='107'>"
}
