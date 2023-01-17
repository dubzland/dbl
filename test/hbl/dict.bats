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

#function stub_private() {
#	function hbl__dict__set_() { printf "set_: [$*]\n"; }
#	function hbl__dict__has_key_() { printf "has_key_: [$*]\n"; }
#	function hbl__dict__get_() { printf "get_: [$*]\n"; }
#}

##
## hbl__dict__set()
##
#@test 'hbl__dict__set() validates its arguments' {
#	# insufficient arguments
#	run hbl__dict__set
#	assert_failure $HBL_ERR_INVOCATION

#	# too many arguments
#	run hbl__dict__set 'dict' 'key' 'value' 'extra'
#	assert_failure $HBL_ERR_INVOCATION

#	# empty dict name
#	run hbl__dict__set '' 'key' 'value'
#	assert_failure $HBL_ERR_ARGUMENT

#	# empty dict key
#	run hbl__dict__set 'dict' '' 'value'
#	assert_failure $HBL_ERR_ARGUMENT

#	# invalid dict
#	function hbl__dict__ensure_dict() { return 1; }
#	run hbl__dict__set "dict" "key" "value"
#	unset hbl__dict__ensure_dict
#	assert_failure
#}

#@test 'hbl__dict__set() calls the private function' {
#	stub_private
#	declare -A dict
#	run hbl__dict__set "dict" "key" "myval"
#	assert_output 'set_: [dict key myval]'
#}
##
## hbl__dict__set_()
##
#@test 'hbl__dict__set_() validates its arguments' {
#	# insufficient arguments
#	run hbl__dict__set_
#	assert_failure $HBL_ERR_INVOCATION

#	# too many arguments
#	run hbl__dict__set_ 'dict' 'key' 'value' 'extra'
#	assert_failure $HBL_ERR_INVOCATION

#	# empty dict name
#	run hbl__dict__set_ '' 'key' 'value'
#	assert_failure $HBL_ERR_ARGUMENT

#	# empty dict key_
#	run hbl__dict__set 'dict' '' 'value'
#	assert_failure $HBL_ERR_ARGUMENT
#}

#@test 'hbl__dict__set_() succeeds' {
#	declare -A dict
#	run hbl__dict__set_ "dict" "key" "myval"
#	assert_success
#}

#@test 'hbl__dict__set_() assigns a value to the dict (by reference)' {
#	declare -A dict
#	hbl__dict__set_ 'dict' 'key' 'myval'
#	assert_equal "${dict[key]}" 'myval'
#}

#@test 'hbl__dict__set_() supports values with spaces' {
#	declare -A dict
#	hbl__dict__set_ 'dict' 'key' 'myval with space'
#	assert_equal "${dict[key]}" 'myval with space'
#}

##
## hbl__dict__has_key()
##
#@test 'hbl__dict__has_key() validates its arguments' {
#	# insufficient arguments
#	run hbl__dict__has_key
#	assert_failure $HBL_ERR_INVOCATION

#	# too many arguments
#	run hbl__dict__has_key 'dict' 'key' 'extra'
#	assert_failure $HBL_ERR_INVOCATION

#	# empty dict name
#	run hbl__dict__has_key '' 'key'
#	assert_failure $HBL_ERR_ARGUMENT

#	# empty dict key
#	run hbl__dict__has_key 'dict' ''
#	assert_failure $HBL_ERR_ARGUMENT

#	# invalid dict
#	function hbl__dict__ensure_dict() { return 1; }
#	run hbl__dict__has_key 'dict' 'example'
#	unset hbl__dict__ensure_dict
#	assert_failure
#}

#@test 'hbl__dict__has_key() calls the private function' {
#	stub_private
#	declare -Ag dict
#	run hbl__dict__has_key 'dict' 'key'
#	assert_output 'has_key_: [dict key]'
#}
##
## hbl__dict__has_key_()
##
#@test 'hbl__dict__has_key_() validates its arguments' {
#	# insufficient arguments
#	run hbl__dict__has_key_
#	assert_failure $HBL_ERR_INVOCATION

#	# too many arguments
#	run hbl__dict__has_key_ 'dict' 'key' 'extra'
#	assert_failure $HBL_ERR_INVOCATION

#	# empty dict name
#	run hbl__dict__has_key_ '' 'key'
#	assert_failure $HBL_ERR_ARGUMENT

#	# empty dict key
#	run hbl__dict__has_key_ 'dict' ''
#	assert_failure $HBL_ERR_ARGUMENT
#}

#@test 'hbl__dict__has_key_() with a non-existent key fails' {
#	declare -Ag dict
#	run hbl__dict__has_key_ 'dict' 'key'
#	assert_failure $HBL_ERROR
#}

#@test 'hbl__dict__has_key_() with a valid key succeeds' {
#	declare -Ag dict
#	dict[key]='value'
#	run hbl__dict__has_key_ 'dict' 'key'
#	assert_success
#}

##
## hbl__dict__get()
##
#@test 'hbl__dict__get() validates its arguments' {
#	# insufficient arguments
#	run hbl__dict__get
#	assert_failure $HBL_ERR_INVOCATION

#	# too many arguments
#	run hbl__dict__get 'dict' 'key' 'value_var' 'extra'
#	assert_failure $HBL_ERR_INVOCATION

#	# empty dict name
#	run hbl__dict__get '' 'key' 'value_var'
#	assert_failure $HBL_ERR_ARGUMENT

#	# with an empty key
#	run hbl__dict__get 'dict' '' 'value_var'
#	assert_failure $HBL_ERR_ARGUMENT

#	# invalid dict
#	function hbl__dict__ensure_dict() { return 1; }
#	run hbl__dict__get 'dict' 'key' 'value_var'
#	unset hbl__dict__ensure_dict
#	assert_failure
#}

#@test 'hbl__dict__get() calls the private function' {
#	stub_private
#	declare -A dict
#	local value_var
#	dict=([key]='value')
#	run hbl__dict__get 'dict' 'key' 'value_var'
#	assert_success
#	assert_output 'get_: [dict key value_var]'
#}

##
## hbl__dict__get_()
##
#@test 'hbl__dict__get_() validates its arguments' {
#	# insufficient arguments
#	run hbl__dict__get_
#	assert_failure $HBL_ERR_INVOCATION

#	# too many arguments
#	run hbl__dict__get_ 'dict' 'key' 'value_var' 'extra'
#	assert_failure $HBL_ERR_INVOCATION

#	# empty dict name
#	run hbl__dict__get_ '' 'key' 'value_var'
#	assert_failure $HBL_ERR_ARGUMENT

#	# with an empty key
#	run hbl__dict__get_ 'dict' '' 'value_var'
#	assert_failure $HBL_ERR_ARGUMENT
#}

#@test 'hbl__dict__get_() succeeds' {
#	declare -A dict
#	local value_var
#	dict=([key]='value')
#	run hbl__dict__get_ 'dict' 'key' 'value_var'
#	assert_success
#}

#@test 'hbl__dict__get_() assigns the value by reference' {
#	declare -A dict
#	dict=([key]='value')
#	local value_var
#	hbl__dict__get_ 'dict' 'key' 'value_var'
#	assert_equal "$value_var" "value"
#}

##
## hbl__dict__ensure_dict()
##
#@test 'hbl__dict__ensure_dict() validates its arguments' {
#	# insufficient arguments
#	run ensure_dict
#	assert_failure $HBL_ERR_INVOCATION

#	# too many arguments
#	run ensure_dict 'dict' 'extra'
#	assert_failure $HBL_ERR_INVOCATION

#	# empty dict name
#	run ensure_dict ''
#	assert_failure $HBL_ERR_ARGUMENT
#}

#@test 'hbl__dict__ensure_dict() with an undefined dict var fails with UNDEFINED' {
#	run ensure_dict 'dict'
#	assert_failure $HBL_ERR_UNDEFINED
#}

#@test 'hbl__dict__ensure_dict() with a non-dict variable fails with INVALID_DICT' {
#	declare -a dict
#	run ensure_dict 'dict'
#	assert_failure $HBL_ERR_INVALID_DICT
#}

#@test 'hbl__dict__ensure_dict() with a valid dict succeeds' {
#	declare -A dict
#	run ensure_dict 'dict'
#	assert_success
#}
