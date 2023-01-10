setup() {
	load 'test_helper/common'
	load 'test_helper/command'
	common_setup
}

#
# hbl::init()
#
@test 'hbl::init() assigns the program to the __hbl dict' {
	hbl::init '/my/executable'
	assert_equal "${__hbl[program]}" "/my/executable"
}

@test ".init() assigns the script to the __hbl dict" {
	hbl::init '/my/executable'
	assert_equal "${__hbl[script]}" "executable"
}
