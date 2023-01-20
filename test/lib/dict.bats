setup() {
	load '../test_helper/common'
	common_setup
}

@test 'Dict.new() succeeds' {
	local dict
	run $Dict.new dict
	assert_success
	refute_output
}

@test 'dict.set()  succeeds' {
	local dict
	$Dict.new dict
	run ${!dict}.set 'foo' 'bar'
	assert_success
	refute_output
}

@test 'dict.set() stores the value' {
	local dict mydict
	$Dict.new dict
	${!dict}.set 'foo' 'bar'
	${!dict}.get__raw mydict
	assert_dict "$mydict"
	assert_dict_has_key "$mydict" foo
	local -n dict__ref="$mydict"
	assert_equal "${dict__ref[foo]}" 'bar'
}

@test 'dict.get() succeeds' {
	local dict
	$Dict.new dict
	${!dict}.set 'foo' 'bar'
	run ${!dict}.get 'foo' val
	assert_success
	refute_output
}

@test 'dict.get() returns the value' {
	local dict myval
	$Dict.new dict
	${!dict}.set 'foo' 'bar'
	${!dict}.get 'foo' myval
	assert_equal "$myval" 'bar'
}

@test 'dict.has_key() succeeds' {
	local dict
	$Dict.new dict
	${!dict}.set 'foo' 'bar'
	run ${!dict}.has_key 'foo'
	assert_success
	refute_output
}

@test 'dict.has_key() for a missing value fails' {
	local dict
	$Dict.new dict
	run ${!dict}.has_key 'foo'
	assert_failure $HBL_ERROR
	refute_output
}

@test 'dict.to_associative_array() succeeds' {
	local dict
	declare -Ag myaarr
	$Dict.new dict
	run ${!dict}.to_associative_array myaarr
	assert_success
	refute_output
}

@test 'dict.to_associative_array() populates the associative array' {
	local dict
	declare -Ag myaarr
	$Dict.new dict
	${!dict}.set 'foo' 'bar'
	${!dict}.to_associative_array myaarr
	assert_dict_has_key myaarr 'foo'
	assert_equal "${myaarr[foo]}" 'bar'
}
