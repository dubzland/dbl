setup() {
	load '../test_helper/common'
	common_setup
}

@test 'Class:define succeeds' {
	local Tester
	run $Class:define Tester
	assert_success
	refute_output
}

@test 'can instantiate newly defined classes' {
	local tester
	$Class:define Tester
	run $Tester:new tester
	assert_success
	refute_output
}

@test 'can add scalar attributes to classes' {
	$Class:define Tester
	run $Tester:attr str $HBL_STRING
	assert_success
	refute_output
}

@test 'can set scalar attributes on instantiated classes' {
	local tester
	$Class:define Tester
	$Tester:attr str $HBL_STRING
	$Tester:new tester
	run $tester.str= 'foo'
	assert_success
	refute_output
}

@test 'can add array attributes to classes' {
	$Class:define Tester
	run $Tester:attr arr $HBL_ARRAY
	assert_success
	refute_output
}

@test 'can access array attributes on instantiated classes' {
	local tester myarray
	$Class:define Tester
	$Tester:attr arr $HBL_ARRAY
	$Tester:new tester
	$tester.arr myarray
	assert_array $myarray
}

@test 'can add associative array attributes to classes' {
	$Class:define Tester
	run $Tester:attr dict $HBL_ASSOCIATIVE_ARRAY
	assert_success
	refute_output
}

@test 'can access associative array attributes on instantiated classes' {
	local tester mydict
	$Class:define Tester
	$Tester:attr dict $HBL_ASSOCIATIVE_ARRAY
	$Tester:new tester
	$tester.dict mydict
	assert_dict $mydict
}

@test 'can add instance methods to classes' {
	$Class:define Tester
	function test_func() { echo "testing\n"; }
	run $Tester:method testing test_func
	assert_success
	refute_output
}

@test 'can call instance methods on instantiated classes' {
	$Class:define Tester
	function test_func() { printf "testing\n"; }
	$Tester:method testing test_func
	$Tester:new tester
	run $tester:testing
	assert_success
	assert_output "testing"
}
