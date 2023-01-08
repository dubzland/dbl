setup() {
	load '../test_helper/common'

	common_setup

	function ensure_dict() {
		hbl::dict::ensure_dict "$@"
	}
}

#
# hbl::dict::set()
#
@test 'hbl::dict::set() validates its arguments' {
	# insufficient arguments
	run hbl::dict::set
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::dict::set 'dict' 'key' 'value' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty dict name
	run hbl::dict::set '' 'key' 'value'
	assert_failure $HBL_ERR_ARGUMENT

	# empty dict key
	run hbl::dict::set 'dict' '' 'value'
	assert_failure $HBL_ERR_ARGUMENT

	# invalid dict
	function hbl::dict::ensure_dict() { return 1; }
	run hbl::dict::set "dict" "key" "value"
	unset hbl::dict::ensure_dict
	assert_failure
}

@test 'hbl::dict::set() succeeds' {
	declare -A dict
	run hbl::dict::set "dict" "key" "myval"
	assert_success
}

@test 'hbl::dict::set() assigns a value to the dict (by reference)' {
	declare -A dict
	hbl::dict::set 'dict' 'key' 'myval'
	assert_equal "${dict[key]}" 'myval'
}

@test 'hbl::dict::set() supports values with spaces' {
	declare -A dict
	hbl::dict::set 'dict' 'key' 'myval with space'
	assert_equal "${dict[key]}" 'myval with space'
}

#
# hbl::dict::has_key()
#
@test 'hbl::dict::has_key() validates its arguments' {
	# insufficient arguments
	run hbl::dict::has_key
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::dict::has_key 'dict' 'key' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty dict name
	run hbl::dict::has_key '' 'key'
	assert_failure $HBL_ERR_ARGUMENT

	# empty dict key
	run hbl::dict::has_key 'dict' ''
	assert_failure $HBL_ERR_ARGUMENT

	# invalid dict
	function hbl::dict::ensure_dict() { return 1; }
	run hbl::dict::has_key 'dict' 'example'
	unset hbl::dict::ensure_dict
	assert_failure
}

@test 'hbl::dict::has_key() with a non-existent key fails' {
	declare -Ag dict
	run hbl::dict::has_key 'dict' 'key'
	assert_failure $HBL_ERROR
}

@test 'hbl::dict::has_key() with a valid key succeeds' {
	declare -Ag dict
	dict[key]='value'
	run hbl::dict::has_key 'dict' 'key'
	assert_success
}

#
# hbl::dict::get()
#
@test 'hbl::dict::get() validates its arguments' {
	# insufficient arguments
	run hbl::dict::get
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::dict::get 'dict' 'key' 'value_var' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty dict name
	run hbl::dict::get '' 'key' 'value_var'
	assert_failure $HBL_ERR_ARGUMENT

	# with an empty key
	run hbl::dict::get 'dict' '' 'value_var'
	assert_failure $HBL_ERR_ARGUMENT

	# invalid dict
	function hbl::dict::ensure_dict() { return 1; }
	run hbl::dict::get 'dict' 'key' 'value_var'
	unset hbl::dict::ensure_dict
	assert_failure
}

@test 'hbl::dict::get() succeeds' {
	declare -A dict
	local value_var
	dict=([key]='value')
	run hbl::dict::get 'dict' 'key' 'value_var'
	assert_success
}

@test 'hbl::dict::get() assigns the value by reference' {
	declare -A dict
	dict=([key]='value')
	local value_var
	hbl::dict::get 'dict' 'key' 'value_var'
	assert_equal "$value_var" "value"
}

#
# hbl::dict::ensure_dict()
#
@test 'hbl::dict::ensure_dict() validates its arguments' {
	# insufficient arguments
	run ensure_dict
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run ensure_dict 'dict' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty dict name
	run ensure_dict ''
	assert_failure $HBL_ERR_ARGUMENT
}

@test 'hbl::dict::ensure_dict() with an undefined dict var fails with UNDEFINED' {
	run ensure_dict 'dict'
	assert_failure $HBL_ERR_UNDEFINED
}

@test 'hbl::dict::ensure_dict() with a non-dict variable fails with INVALID_DICT' {
	declare -a dict
	run ensure_dict 'dict'
	assert_failure $HBL_ERR_INVALID_DICT
}

@test 'hbl::dict::ensure_dict() with a valid dict succeeds' {
	declare -A dict
	run ensure_dict 'dict'
	assert_success
}
