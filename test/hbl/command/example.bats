setup() {
	load '../../test_helper/common'
	load '../../test_helper/command'
	common_setup
	declare -Ag HBL_COMMANDS
	HBL_COMMANDS=([test]="HBL_TEST")
	declare -Ag HBL_TEST
	HBL_TEST=([module]="HBL_TEST")
}

@test "init() assigns the EXAMPLES module" {
	hbl::command::examples::init 'test'
	run hbl_test::is_dict "HBL_TEST_EXAMPLES"
	assert_success
}
