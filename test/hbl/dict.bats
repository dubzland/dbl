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
@test ".set() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::dict::set
	assert_failure $HBL_ERR_INVOCATION
}

@test ".set() with too many arguments exits with ERR_INVOCATION" {
	run hbl::dict::set "dict" "key" "value" "extra"
	assert_failure $HBL_ERR_INVOCATION
}

@test ".set() with an empty dict name exits with ERR_ARGUMENT" {
	run hbl::dict::set "" "key" "value"
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".set() with an empty key exits with ERR_ARGUMENT" {
	run hbl::dict::set "dict" "" "value"
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".set() with an undefined dictionary exits with ERR_UNDEFINED" {
	run hbl::dict::set "dict" "key" "value"
	assert_failure $HBL_ERR_UNDEFINED
}

@test ".set() with a non-dict argument exits with ERR_INVALID_DICT" {
	declare -a dict
	run hbl::dict::set "dict" "key" "value"
	assert_failure $HBL_ERR_INVALID_DICT
}

@test ".set() assigns a value to the dict (by reference)" {
	declare -A dict
	hbl::dict::set "dict" "key" "myval"
	assert_equal "${dict[key]}" "myval"
}

@test ".set() supports values with spaces" {
	declare -A dict
	hbl::dict::set "dict" "key" "myval with space"
	assert_equal "${dict[key]}" "myval with space"
}

#
# hbl::dict::has_key()
#
@test ".has_key() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::dict::has_key
	assert_failure $HBL_ERR_INVOCATION
}

@test ".has_key() with too many arguments exits with ERR_INVOCATION" {
	run hbl::dict::has_key "dict" "key" "extra"
	assert_failure $HBL_ERR_INVOCATION
}

@test ".has_key() with an empty dict variable exits with ERR_ARGUMENT" {
	run hbl::dict::has_key "" "key"
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".has_key() with an empty key exits with ERR_ARGUMENT" {
	run hbl::dict::has_key "dict" ""
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".has_key() with an undefined dict exits with ERR_UNDEFINED" {
	run hbl::dict::has_key "dict" "example"
	assert_failure $HBL_ERR_UNDEFINED
}

@test ".has_key() with a non-dict argument exits with ERR_INVALID_DICT" {
	declare -a dict
	run hbl::dict::has_key "dict" "key"
	assert_failure $HBL_ERR_INVALID_DICT
}

@test ".has_key() when the key does not exist returns ERROR" {
	declare -Ag dict
	run hbl::dict::has_key "dict" "key"
	assert_failure $HBL_ERROR
}

@test ".has_key() succeeds" {
	declare -Ag dict
	dict[key]="value"
	run hbl::dict::has_key "dict" "key"
	assert_success
}

#
# hbl::dict::get()
#
@test ".get() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::dict::get
	assert_failure $HBL_ERR_INVOCATION
}

@test ".get() with too many arguments exits with ERR_INVOCATION" {
	run hbl::dict::get "dict" "key" "value_var" "extra"
	assert_failure $HBL_ERR_INVOCATION
}

@test ".get() with an empty dict name exits with ERR_ARGUMENT" {
	run hbl::dict::get "" "key" "value_var"
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".get() with an empty key exits with ERR_ARGUMENT" {
	run hbl::dict::get "dict" "" "value_var"
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".get() with an undefined dictionary exits with ERR_UNDEFINED" {
	run hbl::dict::get "dict" "key" "value_var"
	assert_failure $HBL_ERR_UNDEFINED
}

@test ".get() with a non-dict argument exits with ERR_INVALID_DICT" {
	declare -a dict
	run hbl::dict::get "dict" "key" "value_var"
	assert_failure $HBL_ERR_INVALID_DICT
}

@test ".get() succeeds" {
	declare -Ag dict
	dict[key]="value"
	local value_var
	run hbl::dict::get "dict" "key" "value_var"
	assert_success
}

@test ".get() assigns the value by reference" {
	declare -Ag dict
	dict[key]="value"
	local value_var
	hbl::dict::get "dict" "key" "value_var"
	assert_equal "$value_var" "value"
}

#
# hbl::dict::ensure_dict()
#
@test ".ensure_dict() with no arguments exits with ERR_INVOCATION" {
	run ensure_dict
	assert_failure $HBL_ERR_INVOCATION
	assert_output "hbl::dict::ensure_dict: invalid arguments -- ''"
}

@test ".ensure_dict() with more than one argument exits with ERR_INVOCATION" {
	run ensure_dict "dict" "extra"
	assert_failure $HBL_ERR_INVOCATION
	assert_output "hbl::dict::ensure_dict: invalid arguments -- 'dict extra'"
}

@test ".ensure_dict() with an empty dict name exits with ERR_ARGUMENT" {
	run ensure_dict ""
	assert_failure $HBL_ERR_ARGUMENT
	assert_output "hbl::dict::ensure_dict: invalid argument for 'dict' -- ''"
}

@test ".ensure_dict() with an undefined dict var returns ERR_UNDEFINED" {
	run ensure_dict "dict"
	assert_failure $HBL_ERR_UNDEFINED
	assert_output "ensure_dict: variable is undefined -- 'dict'"
}

@test ".ensure_dict() with a non-dict variable returns ERR_INVALID_DICT" {
	declare -a dict
	run ensure_dict "dict"
	assert_failure $HBL_ERR_INVALID_DICT
	assert_output "ensure_dict: not a dictionary -- 'dict'"
}

@test ".ensure_dict() with a valid dict succeeds" {
	declare -A dict
	run ensure_dict "dict"
	assert_success
	refute_output
}
