setup() {
	load '../../test_helper/common'
	load '../../test_helper/command'
	common_setup
}

@test 'Option:new succeeds' {
	local opt
	run $Option:new opt verbose
	assert_success
	refute_output
}

@test 'options allow the type to be set' {
	local opt
	$Option:new opt verbose
	run $opt.type= string
	assert_success
	refute_output
}

@test 'options allow the type to be retrieved' {
	local opt type
	$Option:new opt verbose
	$opt.type= string
	$opt.type type
	assert_equal "$type" string
}

@test 'options allow the short flag to be set' {
	local opt
	$Option:new opt verbose
	run $opt.short_flag= v
	assert_success
	refute_output
}

@test 'options allow the short flag to be retrieved' {
	local opt short_flag
	$Option:new opt verbose
	$opt.short_flag= v
	$opt.short_flag short_flag
	assert_equal "$short_flag" v
}

@test 'options allow the long flag to be set' {
	local opt
	$Option:new opt verbose
	run $opt.long_flag= v
	assert_success
	refute_output
}

@test 'options allow the long flag to be retrieved' {
	local opt long_flag
	$Option:new opt verbose
	$opt.long_flag= v
	$opt.long_flag long_flag
	assert_equal "$long_flag" v
}

@test 'options allow the description to be set' {
	local opt
	$Option:new opt verbose
	run $opt.description= 'Increase verbosity'
	assert_success
	refute_output
}

@test 'options allow the description to be retrieved' {
	local opt description
	$Option:new opt verbose
	$opt.description= 'Increase verbosity'
	$opt.description description
	assert_equal "$description" 'Increase verbosity'
}
