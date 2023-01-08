setup() {
	load '../test_helper/common'
	load '../test_helper/command'
	common_setup
	hbl::init
}

#
# hbl::command::init()
#
@test 'hbl::command::init() creates the HBL_COMMAND associative array' {
	hbl::command::init
	assert_dict 'HBL_COMMAND'
}

@test 'hbl::command::init() assigns an empty command name' {
	hbl::command::init
	assert_equal "${HBL_COMMAND[name]}" ''
}

@test 'hbl::command::init() creates the HBL_PARAMS associative array' {
	hbl::command::init
	assert_dict 'HBL_PARAMS'
}

@test 'hbl::command::init() sets verbose to 0' {
	hbl::command::init
	assert_equal ${HBL_PARAMS[verbose]} 0
}

@test 'hbl::command::init() sets showhelp to 0' {
	hbl::command::init
	assert_equal ${HBL_PARAMS[showhelp]} 0
}

@test 'hbl::command::init() creates the HBL_COMMANDS array' {
	hbl::command::init
	assert_array 'HBL_COMMANDS'
}

@test 'hbl::command::init() succeeds' {
	run hbl::command::init
	assert_success
	refute output
}
