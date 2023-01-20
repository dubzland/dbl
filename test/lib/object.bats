setup() {
	load '../test_helper/common'
	common_setup
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

@test 'inspecting an object displays attributes' {
	local -A obj=()
	Object__init obj
	obj[attrA]='red'
	obj[attrB]='blue'
	run Object__inspect obj
	assert_success
	assert_output "<obj attrA='red' attrB='blue'>"
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

# creating an object
# inspecting an object

# @test 'retrieving a system attribute succeeds' {
# 	local var

# 	for attr in "${!Object[@]}"; do
# 		run $Object.get_$attr var
# 		assert_success
# 		refute_output

# 		$Object.get_$attr var
# 		assert_equal "$var" "${Object[$attr]}"
# 	done
# }

# @test 'attempting to set a system attribute fails' {
# 	local var
# 	TRACE=1

# 	for attr in "${!Object[@]}"; do
# 		[[ "$attr" =~ ^__* ]] || continue
# 		run $Object.set_${attr} foo
# 		assert_failure $HBL_ERR_ILLEGAL_INSTRUCTION
# 	done
# }

# @test 'Object.define() succeeds' {
# 	run $Object.define Thing
# 	assert_success
# 	refute_output
# }

# @test 'Object.define() accepts an initializer' {
# 	$Object.define Thing thing_init
# 	assert_equal "${Thing[__init]}" 'thing_init'
# }

# @test 'Object.define() prevents redefining existing classes' {
# 	$Object.define Thing
# 	run $Object.define Thing
# 	assert_failure $HBL_ERR_ALREADY_DEFINED
# }

# @test 'Object.define() creates the global class' {
# 	$Object.define Thing
# 	assert_defined Thing
# }

# @test 'Object.define() assigns the correct attributes' {
# 	$Object.define Thing
# 	assert_equal "${Thing[0]}" 'Object__static__dispatch_ Thing '
# 	assert_equal "${Thing[__name]}"    Thing
# 	assert_equal "${Thing[__base]}"    Object
# 	assert_equal "${Thing[__methods]}" Thing__methods
# }

# @test 'Object.static_method() succeeds' {
# 	function thing_test() { echo "I am the Thing object type.\n"; }
# 	$Object.define Thing
# 	run $Thing.static_method test_method thing_test
# 	assert_success
# 	refute_output
# }

# @test 'Object.static_method() assigns the method to the class' {
# 	function thing_test() { printf "I am the Thing object type.\n"; }
# 	export -f thing_test
# 	$Object.define Thing
# 	$Thing.static_method test_method thing_test
# 	run $Thing.test_method
# 	assert_success
# 	assert_output 'I am the Thing object type.'
# }

# @test 'Object.static_method() prevents overriding a base static method' {
# 	function thing_test() { return 0; }
# 	$Object.define Thing
# 	run $Thing.static_method define thing_test
# 	assert_failure $HBL_ERR_ILLEGAL_INSTRUCTION
# }

# @test 'Object.static_method() with a non-function argument fails' {
# 	$Object.define Thing
# 	run $Thing.static_method define anything
# 	assert_failure $HBL_ERR_ARGUMENT
# }

# @test 'accessing a class attribute via getter succeeds' {
# 	local var

# 	$Object.define Thing
# 	Thing[foo]='bar'
# 	$Thing.get_foo var
# 	assert_equal "$var" 'bar'
# }

# @test 'accessing a non-existent class attribute fails' {
# 	local var

# 	$Object.define Thing
# 	run $Thing.get_foo var
# 	assert_failure $HBL_ERR_UNDEFINED_METHOD
# }

# @test 'setting a class attribute succeeds' {
# 	$Object.define Thing
# 	Thing[foo]='bar'
# 	$Thing.set_foo 'baz'
# 	assert_equal ${Thing[foo]} baz
# }

# @test 'setting a non-existent object type attribute fails' {
# 	$Object.define Thing
# 	run $Thing.set_foo 'baz'
# 	assert_failure $HBL_ERR_UNDEFINED_METHOD
# }

# @test 'overriding a getter succeeds' {
# 	function get_thing_foo() { printf "I am overridden!\n"; return; }
# 	$Object.define Thing
# 	$Thing.static_method get_foo get_thing_foo
# 	run $Thing.get_foo var
# 	assert_success
# 	assert_output 'I am overridden!'
# }

# @test 'overriding a setter succeeds' {
# 	function set_thing_foo() { local -n this="$1"; this[foo]="overridden:$2"; }
# 	$Object.define Thing
# 	$Thing.static_method set_foo set_thing_foo
# 	$Thing.set_foo 'bar'
# 	assert_equal "${Thing[foo]}" "overridden:bar"
# }

# @test 'defining an instance method succeeds' {
# 	function Thing_test() { return 0; }
# 	$Object.define Thing
# 	run $Thing.method tester Thing_test
# 	assert_success
# }

# @test 'defining an instance method assigns it to the prototype' {
# 	function Thing_test() { return 0; }
# 	$Object.define Thing
# 	$Thing.method tester Thing_test
# 	local -n prototype="${Thing[__prototype]}"
# 	assert_dict_has_key "${!prototype}" 'tester'
# 	assert_equal "${prototype[tester]}" "$HBL_SELECTOR_METHOD Thing_test"
# }


# # # @test 'Object:new succeeds' {
# # # 	local object
# # # 	run $Object:new object
# # # 	assert_success
# # # }

# # # @test 'objects have an id' {
# # # 	local object object_id
# # # 	$Object:new object
# # # 	$object.__id object_id
# # # 	assert_equal $object_id __hbl__Object_0
# # # }

# # # @test 'objects have a class' {
# # # 	local object class_name
# # # 	$Object:new object
# # # 	$object.__class class_name
# # # 	assert_equal $class_name Object
# # # }

# # # @test 'objects have a vtable' {
# # # 	local object vtbl
# # # 	$Object:new object
# # # 	$object.__vtbl vtbl
# # # 	assert_equal $vtbl __hbl__Object__pvtbl
# # # }

# # # @test 'objects allow setting attributes' {
# # # 	local object
# # # 	$Object:new object
# # # 	run $object.foo= 'bar'
# # # 	assert_success
# # # }

# # # @test 'objects prevent setting system attributes' {
# # # 	local object
# # # 	$Object:new object
# # # 	run $object.__bar= 'foo'
# # # 	assert_failure
# # # }

# # # @test 'objects allow retrieving attributes' {
# # # 	local object val
# # # 	$Object:new object
# # # 	$object.foo= 'bar'
# # # 	run $object.foo val
# # # 	assert_success
# # # }

# # # @test 'objects retrieve attributes properly' {
# # # 	local object val
# # # 	$Object:new object
# # # 	$object.foo= 'bar'
# # # 	$object.foo val
# # # 	assert_equal $val 'bar'
# # # }

# # # @test 'calling an undefined method results in an error' {
# # # 	local object
# # # 	$Object:new object
# # # 	run $object:bad_function
# # # 	assert_failure $HBL_ERR_UNDEFINED_METHOD
# # # }

# # # @test 'objects can be inspected' {
# # # 	local object
# # # 	$Object:new object
# # # 	run $object:inspect
# # # 	assert_success
# # # 	assert_output '<__hbl__Object_0>'
# # # }

# # # @test 'object inspection includes available attributes' {
# # # 	local object
# # # 	$Object:new object
# # # 	$object.foo= 'bar'
# # # 	$object.size= 107
# # # 	$object.color= 'blue'
# # # 	run $object:inspect
# # # 	assert_success
# # # 	assert_output "<__hbl__Object_0 color='blue' foo='bar' size='107'>"
# # # }
