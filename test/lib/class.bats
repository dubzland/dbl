setup() {
	load '../test_helper/common'
	common_setup
}

@test 'Class.define() succeeds' {
	run $Class.define Tester
	assert_success
	refute_output
}

@test 'Class.define() creates the global object' {
	$Class.define Tester
	assert_dict Tester
}

@test 'Class.define() assigns the __name' {
	$Class.define Tester
	assert_equal "${Tester[__name]}" Tester
}

@test 'Class.define() assigns the __base' {
	$Class.define Tester
	assert_equal "${Tester[__base]}" Class
}

@test 'Class.define() assigns the __methods' {
	$Class.define Tester
	assert_equal "${Tester[__methods]}" Tester__methods
}

@test 'Class.define() creates the __methods global object' {
	$Class.define Tester
	assert_dict Tester__methods
}

@test 'Class.define() initializes the methods to empty' {
	$Class.define Tester
	assert_equal ${#Tester__methods[@]} 0
}

@test 'Class.define() assigns the __prototype' {
	$Class.define Tester
	assert_equal "${Tester[__prototype]}" Tester__prototype
}

@test 'Class.define() creates the __prototype global object' {
	$Class.define Tester
	assert_dict Tester__prototype
}

@test 'Class.define() initializes the prototype to empty' {
	$Class.define Tester
	assert_equal ${#Tester__prototype[@]} 0
}

@test 'Class.define() accepts an initializer' {
	function Tester__init() { return 0; }
	$Class.define Tester Tester_init
	assert_equal "${Tester__prototype[__init]}" "$HBL_SELECTOR_METHOD Tester_init"
}

@test 'Class.static_method() succeeds' {
	function Tester_test() { return 0; }
	$Class.define Tester
	run $Tester.static_method test Tester_test
	assert_success
	refute_output
}

@test 'Class.static_method() assigns the method to the class' {
	function Tester_test() { printf "I am the Tester class.\n"; }
	$Class.define Tester
	$Tester.static_method test Tester_test
	assert_dict_has_key Tester__methods test
	assert_equal "${Tester__methods[test]}" Tester_test
}

@test 'Class.static_method() prevents overriding an existing method' {
	function Tester_test() { return 0; }
	$Class.define Tester
	run $Tester.static_method define Tester_test
	assert_failure $HBL_ERR_ILLEGAL_INSTRUCTION
}

@test 'Class.static_method() with a non-function argument fails' {
	$Class.define Tester
	run $Tester.static_method test anything
	assert_failure $HBL_ERR_ARGUMENT
}

@test 'Class.method() succeeds' {
	function Tester_test() { return 0; }
	$Class.define Tester
	run $Tester.method test Tester_test
	assert_success
	refute_output
}

@test 'Class.method() assigns the method to the prototype' {
	function Tester_test() { return 0; }
	$Class.define Tester
	$Tester.method test Tester_test
	assert_equal "${Tester__prototype[test]}" "$HBL_SELECTOR_METHOD Tester_test"
}

@test 'Class.method() prevents overriding an existing method' {
	function Tester_test() { return 0; }
	$Class.define Tester
	$Tester.method test Tester_test
	run $Tester.method test Tester_test
	assert_failure $HBL_ERR_ILLEGAL_INSTRUCTION
}

@test 'Class.method() with a non-function argument fails' {
	$Class.define Tester
	run $Tester.method test anything
	assert_failure $HBL_ERR_ARGUMENT
}

@test 'Class.reference() succeeds' {
	$Class.define Tester
	run $Tester.reference children Array
	assert_success
	refute_output
}

@test 'Class.reference() assigns the reference to the prototype' {
	$Class.define Tester
	$Tester.reference children Array
	assert_dict_has_key Tester__prototype children
	assert_equal "${Tester__prototype[children]}" "$HBL_SELECTOR_REFERENCE Array"
}

@test 'Class.new() succeeds' {
	$Class.define Tester
	run $Tester.new obj
	assert_success
	refute_output
}

@test 'Class.new() calls the initializer' {
	local tester
	function Tester__init() {
		printf "I am the tester initializer\n"
		local -n this="$1"
		$this.super
	}
	$Class.define Tester Tester__init
	run $Tester.new tester
	assert_success
	assert_output 'I am the tester initializer'
}

@test 'Class.new() creates the global object' {
	$Class.define Tester
	$Tester.new obj
	assert_dict "${obj}"
}

@test 'Class.new() assigns the dispatcher' {
	$Class.define Tester
	$Tester.new obj
	assert_dict_has_key "$obj" 0
	local -n obj__ref="$obj"
	assert_equal "${obj__ref[0]}" "Object__dispatch_ $obj "
}

@test 'Class.new() assigns the __id' {
	$Class.define Tester
	$Tester.new obj
	assert_dict_has_key "$obj" __id
	local -n obj__ref="$obj"
	assert_equal "${obj__ref[__id]}" "$obj"
}

@test 'Class.new() assigns the __class' {
	$Class.define Tester
	$Tester.new obj
	assert_dict_has_key "$obj" __class
	local -n obj__ref="$obj"
	assert_equal "${obj__ref[__class]}" Tester
}

@test 'calling a static method succeeds' {
	function Tester_test() { return 0; }
	$Class.define Tester
	$Tester.static_method test Tester_test
	run $Tester.test
	assert_success
}

@test 'calling a static method passes the proper arguments' {
	function Tester_test() {
		assert_equal $# 1
		assert_equal "$1" 'foo'
	}
	$Class.define Tester
	$Tester.static_method test Tester_test
	$Tester.test 'foo'
}

@test 'calling a static method returns the function return code' {
	function Tester_test() {
		return 123
	}
	$Class.define Tester
	$Tester.static_method test Tester_test
	run $Tester.test
	assert_failure 123
}

@test 'retrieving system class attributes succeeds' {
	local var
	$Class.define Tester

	for attr in "${!Tester[@]}"; do
		[[ "$attr" =~ ^__* ]] || continue
		run $Tester.get_$attr var
		assert_success
		refute_output

		$Tester.get_$attr var
		assert_equal "$var" "${Tester[$attr]}"
	done
}

@test 'retrieving normal class attributes succeeds' {
	local var
	$Class.define Tester
	Tester[myvar]='red'
	run $Tester.get_myvar var
	assert_success
	refute_output
}

@test 'retrieving non existent class attributes fails' {
	local var
	$Class.define Tester
	run $Tester.get_myvar var
	assert_failure $HBL_ERR_UNDEFINED_METHOD
}

@test 'assigning system class attributes fails' {
	$Class.define Tester

	for attr in "${!Tester[@]}"; do
		[[ "$attr" =~ ^__* ]] || continue
		run $Tester.set_$attr 'value'
		assert_failure $HBL_ERR_ILLEGAL_INSTRUCTION
	done
}

@test 'assigning non-existent class attributes fails' {
	$Class.define Tester
	run $Tester.set_var 'test'
	assert_failure $HBL_ERR_UNDEFINED_METHOD
}

@test 'assigning a class attribute succeeds' {
	$Class.define Tester
	Tester[color]='red'
	run $Tester.set_color 'blue'
	assert_success
	refute_output
}

@test 'assigning a class attribute sets the value' {
	$Class.define Tester
	Tester[color]='red'
	$Tester.set_color 'blue'
	assert_equal "${Tester[color]}" 'blue'
}

@test 'calling an instance method succeeds' {
	function Tester_test() { return 0; }
	$Class.define Tester
	$Tester.method test Tester_test
	$Tester.new obj
	run ${!obj}.test
	assert_success
}

@test 'calling an instance method passes the arguments' {
	function Tester_test() {
		assert_equal $# 2
		assert_equal "$1" "$obj"
		assert_equal "$2" 'foo'
	}
	$Class.define Tester
	$Tester.method test Tester_test
	$Tester.new obj
	${!obj}.test 'foo'
}

@test 'calling an instance method adds an item to the stack' {
	function Tester_test() {
		assert_equal "${#__hbl__stack[@]}" 1
		assert_equal "${__hbl__stack[0]}" "$1 Tester test Tester_test"
	}
	$Class.define Tester
	$Tester.method test Tester_test
	$Tester.new obj
	local -n obj__ref="$obj"
	$obj__ref.test
}

@test 'calling an instance method pops the stack when complete' {
	function Tester_test() { return 0; }
	$Class.define Tester
	$Tester.method test Tester_test
	$Tester.new obj
	local -n obj__ref="$obj"
	$obj__ref.test
	assert_equal "${#__hbl__stack[@]}" 0
}

@test 'Class#super() within an instance method succeeds' {
	function Tester_inspect() {
		local -n this="$1"
		$this.super
	}
	$Class.define Tester
	$Tester.method inspect Tester_inspect
	$Tester.new obj
	run ${!obj}.inspect
	assert_success
}

@test 'Class#super() within an instance method calls both methods' {
	function Tester_inspect() {
		local -n this="$1"
		printf "Tester_inspect()\n"
		$this.super
	}
	$Class.define Tester
	$Tester.method inspect Tester_inspect
	$Tester.new obj
	local -n obj__ref="$obj"
	obj__ref[attrA]='red'
	obj__ref[attrB]='blue'
	run $obj__ref.inspect
	assert_line --index 0 "Tester_inspect()"
	assert_line --index 1 "<${obj} attrA='red' attrB='blue'>"
}

@test 'Class#get_attr() for a valid attribute succeeds' {
	function Tester__init() {
		local -n this="$1"
		this[_foo]='bar'
	}
	$Class.define Tester Tester__init
	$Tester.new obj
	run ${!obj}.get_foo var
	assert_success
}

@test 'Class#get_attr() for a valid attribute returns the value' {
	function Tester__init() {
		local -n this="$1"
		this[_foo]='bar'
	}
	$Class.define Tester Tester__init
	$Tester.new obj
	${!obj}.get_foo var
	assert_equal "$var" 'bar'
}

@test 'Class#get_attr() for an invalid attribute fails' {
	$Class.define Tester
	$Tester.new obj
	run ${!obj}.get_foo var
	assert_failure $HBL_ERR_UNDEFINED_METHOD
}

@test 'Class#set_attr() for a valid attribute succeeds' {
	function Tester__init() {
		local -n this="$1"
		this[_foo]='bar'
	}
	$Class.define Tester Tester__init
	$Tester.new obj
	run ${!obj}.set_foo 'baz'
	assert_success
}

@test 'Class#set_attr() for a valid attribute updates the value' {
	function Tester__init() {
		local -n this="$1"
		this[_foo]='bar'
	}
	$Class.define Tester Tester__init
	$Tester.new obj
	${!obj}.set_foo 'baz'
	local -n objr="$obj"
	assert_equal "${objr[_foo]}" 'baz'
}

@test 'Class#set_attr() for an invalid attribute fails' {
	$Class.define Tester
	$Tester.new obj
	run ${!obj}.set_foo 'baz'
	assert_failure $HBL_ERR_UNDEFINED_METHOD
}

@test 'Class#_set_reference() within an instance method succeeds' {
	function Tester__init() {
		local -n this="$1"
		local children
		$Array.new children
		run $this._set_reference children "$children"
		assert_success
		refute_output
	}
	$Class.define Tester Tester__init
	$Tester.reference children Array
	$Tester.new tester
}

@test 'Class#_set_reference() within an instance method assigns the reference' {
	function Tester__init() {
		local -n this="$1"
		local children
		$Array.new children
		$this._set_reference children "$children"
	}
	$Class.define Tester Tester__init
	$Tester.reference children Array
	$Tester.new tester
	local -n t__ref="$tester"
	assert_dict_has_key "$tester" '_children'
}

@test 'Class#reference() provides access to the referenced object' {
	function Tester__init() {
		local -n this="$1"
		local children
		$Array.new children
		${!children}.push 'foo'
		$this._set_reference children "$children"
	}
	$Class.define Tester Tester__init
	$Tester.reference children Array
	$Tester.new tester
	run ${!tester}.children.contains 'foo'
	assert_success
	run ${!tester}.children.contains 'bar'
	assert_failure "$HBL_ERROR"
}
