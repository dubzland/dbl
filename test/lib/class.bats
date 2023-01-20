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
	assert_equal "${Tester[__init]}" 'Tester_init'
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

@test 'Class properly dispatches to the static method' {
	function Tester_test() { printf "I am the Tester class.\n"; }
	$Class.define Tester
	$Tester.static_method test Tester_test
	run $Tester.test
	assert_success
	assert_output 'I am the Tester class.'
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

@test 'retrieving non_existent class attributes fails' {
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

@test 'Class.new() succeeds' {
	$Class.define Tester
	run $Tester.new obj
	assert_success
	refute_output
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
	assert_equal "${obj__ref[0]}" "Class__dispatch_ $obj "
}

@test 'Class.new() creates the stack' {
	$Class.define Tester
	$Tester.new obj
	assert_array Tester__stack
	assert_dict_has_key "$obj" __stack
}

# @test 'Class.new() assigns the __id' {
# 	$Class.define Tester
# 	$Tester.new obj
# 	assert_dict_has_key "$obj" __id
# 	local -n obj__ref="$obj"
# 	assert_equal "${obj__ref[__id]}" "$obj"
# }

@test 'Class.new() assigns the __class' {
	$Class.define Tester
	$Tester.new obj
	assert_dict_has_key "$obj" __class
	local -n obj__ref="$obj"
	assert_equal "${obj__ref[__class]}" Tester
}

@test 'calling an instance method adds an item to the stack' {
	function Tester_test() {
		local -n this="$1"
		local -n stack="${this[__stack]}"
		assert_equal "${#stack[@]}" 1
		assert_equal "${stack[0]}" "Tester $1 test"
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
	local -n stack="${obj__ref[__stack]}"
	assert_equal "${#stack[@]}" 0
}

# super

# accessing class attributes

# @test 'can instantiate newly defined classes' {
# 	local tester
# 	$Class:define Tester
# 	run $Tester:new tester
# 	assert_success
# 	refute_output
# }

# @test 'can add scalar attributes to classes' {
# 	$Class:define Tester
# 	run $Tester:attr str $HBL_STRING
# 	assert_success
# 	refute_output
# }

# @test 'can set scalar attributes on instantiated classes' {
# 	local tester
# 	$Class:define Tester
# 	$Tester:attr str $HBL_STRING
# 	$Tester:new tester
# 	run $tester.str= 'foo'
# 	assert_success
# 	refute_output
# }

# @test 'can add array attributes to classes' {
# 	$Class:define Tester
# 	run $Tester:attr arr $HBL_ARRAY
# 	assert_success
# 	refute_output
# }

# @test 'can access array attributes on instantiated classes' {
# 	local tester myarray
# 	$Class:define Tester
# 	$Tester:attr arr $HBL_ARRAY
# 	$Tester:new tester
# 	$tester.arr myarray
# 	assert_array $myarray
# }

# @test 'can add associative array attributes to classes' {
# 	$Class:define Tester
# 	run $Tester:attr dict $HBL_ASSOCIATIVE_ARRAY
# 	assert_success
# 	refute_output
# }

# @test 'can access associative array attributes on instantiated classes' {
# 	local tester mydict
# 	$Class:define Tester
# 	$Tester:attr dict $HBL_ASSOCIATIVE_ARRAY
# 	$Tester:new tester
# 	$tester.dict mydict
# 	assert_dict $mydict
# }

# @test 'can add instance methods to classes' {
# 	$Class:define Tester
# 	function test_func() { echo "testing\n"; }
# 	run $Tester:method testing test_func
# 	assert_success
# 	refute_output
# }

# @test 'can call instance methods on instantiated classes' {
# 	$Class:define Tester
# 	function test_func() { printf "testing\n"; }
# 	$Tester:method testing test_func
# 	$Tester:new tester
# 	run $tester:testing
# 	assert_success
# 	assert_output "testing"
# }
