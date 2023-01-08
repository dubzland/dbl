setup() {
	load '../test_helper/common'
	load '../test_helper/command'
	common_setup
	hbl::init
}

#
# hbl::command::init()
#
@test 'hbl::command::init() creates the __hbl_params associative array' {
	hbl::command::init
	assert_dict '__hbl_params'
}

@test 'hbl::command::init() sets verbose to 0' {
	hbl::command::init
	assert_equal ${__hbl_params[verbose]} 0
}

@test 'hbl::command::init() sets showhelp to 0' {
	hbl::command::init
	assert_equal ${__hbl_params[showhelp]} 0
}

@test 'hbl::command::init() creates the __hbl_commands array' {
	hbl::command::init
	assert_array '__hbl_commands'
}

@test 'hbl::command::init() succeeds' {
	run hbl::command::init
	assert_success
	refute output
}
