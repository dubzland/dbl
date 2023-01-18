setup() {
	load '../test_helper/common'
	common_setup
}

@test 'Dict:new succeeds' {
	local dict
	run $Dict:new dict
	assert_success
	refute_output
}

@test 'dicts can set a value' {
	local dict
	$Dict:new dict
	run $dict:set 'foo' 'bar'
	assert_success
	refute_output
}

@test 'dicts can retrieve a value' {
	local dict myval
	$Dict:new dict
	$dict:set 'foo' 'bar'
	run $dict:get 'foo' myval
	assert_success
	refute_output

	$dict:get 'foo' myval
	assert_equal "$myval" 'bar'
}

@test 'dicts know whether or not a key exists' {
	local dict
	$Dict:new dict
	$dict:set 'foo' 'bar'
	run $dict:has_key 'foo'
	assert_success
	refute_output

	run $dict:has_key 'bar'
	assert_failure
	refute_output
}

@test 'can convert to a bash associative array' {
	local dict
	local -A dict_raw

	$Dict:new dict
	$dict:set 'foo' 'bar'
	$dict:to_dict dict_raw
	assert_dict dict_raw
}
