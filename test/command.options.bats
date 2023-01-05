setup() {
	load 'test_helper/common'
	load 'test_helper/command'
	common_setup
	declare -Ag HBL_COMMANDS
	HBL_COMMANDS=([test]="HBL_TEST")
	declare -Ag HBL_TEST
	HBL_TEST=([module]="HBL_TEST")
}

@test "init() assigns the OPTIONS module" {
	hbl::command::options::init 'test'
	run is_defined "HBL_TEST_OPTIONS"
	assert_success
}
