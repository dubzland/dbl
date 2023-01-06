setup() {
	load '../test_helper/common'
	load '../test_helper/command'
	common_setup
	hbl::init
}

@test ".init() creates the HBL_COMMAND associative array" {
	hbl::command::init
	run hbl::util::is_dict HBL_COMMAND
	assert_success
}

@test ".init() assigns an empty command name" {
	hbl::command::init
	assert_equal "${HBL_COMMAND[name]}" ""
}

@test ".init() creates the HBL_PARAMS associative array" {
	hbl::command::init
	run hbl::util::is_dict HBL_PARAMS
	assert_success
}

@test ".init() sets verbose to 0" {
	hbl::command::init
	assert_equal ${HBL_PARAMS[verbose]} 0
}

@test ".init() sets showhelp to 0" {
	hbl::command::init
	assert_equal ${HBL_PARAMS[showhelp]} 0
}

@test ".init() creates the HBL_COMMANDS array" {
	hbl::command::init
	run hbl::util::is_array HBL_COMMANDS
	assert_success
}
