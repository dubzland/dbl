setup() {
	load '../../test_helper/common'
	common_setup
}

@test 'Option.new succeeds' {
	local opt
	run $Option.new opt verbose
	assert_success
	refute_output
}

@test 'options allow the type to be set' {
	local opt
	$Option.new opt verbose
	run $opt.set_type string
	assert_success
	refute_output
}

@test 'options allow the type to be retrieved' {
	local opt type
	$Option.new opt verbose
	$opt.set_type string
	$opt.get_type type
	assert_equal "$type" string
}

@test 'options allow the short flag to be set' {
	local opt
	$Option.new opt verbose
	run $opt.set_short_flag v
	assert_success
	refute_output
}

@test 'options allow the short flag to be retrieved' {
	local opt short_flag
	$Option.new opt verbose
	$opt.set_short_flag v
	$opt.get_short_flag short_flag
	assert_equal "$short_flag" v
}

@test 'options allow the long flag to be set' {
	local opt
	$Option.new opt verbose
	run $opt.set_long_flag v
	assert_success
	refute_output
}

@test 'options allow the long flag to be retrieved' {
	local opt long_flag
	$Option.new opt verbose
	$opt.set_long_flag v
	$opt.get_long_flag long_flag
	assert_equal "$long_flag" v
}

@test 'options allow the description to be set' {
	local opt
	$Option.new opt verbose
	run $opt.set_description 'Increase verbosity'
	assert_success
	refute_output
}

@test 'options allow the description to be retrieved' {
	local opt description
	$Option.new opt verbose
	$opt.set_description 'Increase verbosity'
	$opt.get_description description
	assert_equal "$description" 'Increase verbosity'
}
