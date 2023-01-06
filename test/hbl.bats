setup() {
	load 'test_helper/common'
	load 'test_helper/command'
	common_setup
}

@test ".init() creates the HBL dict" {
	hbl::init "/my/executable" && [ $? -eq 0 ]
	[ -v HBL[@] ]
}

@test ".init() assigns the program to the HBL dict" {
	hbl::init "/my/executable" && [ $? -eq 0 ]
	assert_equal "${HBL[program]}" "/my/executable"
}

@test ".init() assigns the script to the HBL dict" {
	hbl::init "/my/executable" && [ $? -eq 0 ]
	assert_equal "${HBL[script]}" "executable"
}
