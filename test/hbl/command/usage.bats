setup() {
	load '../../test_helper/common'
	common_setup

	declare -a usage_examples_args
	usage_examples_args=()
	usage_examples_invoked=0
	function hbl::command::usage::examples() {
		usage_examples_invoked=1
		usage_examples_args=("$@")
		echo "Examples"
		return 0
	}

	declare -a usage_show_args
	usage_description_args=()
	usage_description_invoked=0
	function hbl::command::usage::description() {
		usage_description_invoked=1
		usage_description_args=("$@")
		local -n command_id__ref="$1"
		echo "Description"
		return 0
	}
}

@test ".show() when insufficient arguments are passed returns INVALID_ARGS" {
	run hbl::command::usage::show
	assert_failure $HBL_INVALID_ARGS
}

@test ".show() displays the examples" {
	hbl::command::usage::show "TEST_COMMAND"
	assert_equal $usage_examples_invoked 1
	assert_equal ${#usage_examples_args[@]} 1
	assert_equal ${usage_examples_args[0]} "TEST_COMMAND"
}

@test ".show() displays the description" {
	hbl::command::usage::show "TEST_COMMAND"
	assert_equal $usage_description_invoked 1
	assert_equal ${#usage_description_args[@]} 1
	assert_equal ${usage_description_args[0]} "TEST_COMMAND"
}
