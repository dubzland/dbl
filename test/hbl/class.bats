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
