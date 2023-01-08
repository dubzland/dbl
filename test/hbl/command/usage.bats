setup() {
	load '../../test_helper/common'
	common_setup

	declare -Ag TEST_COMMAND
	TEST_COMMAND=([name]="test-command" [entrypoint]="test_command::run")

	declare -a usage_examples_args
	usage_examples_args=()
	usage_examples_invoked=0
	function hbl::command::usage::examples() {
		usage_examples_invoked=1
		usage_examples_args=("$@")
		echo "Examples"
		return 0
	}

	declare -a usage_description_args
	usage_description_args=()
	usage_description_invoked=0
	function hbl::command::usage::description() {
		usage_description_invoked=1
		usage_description_args=("$@")
		echo "Description"
		return 0
	}

	declare -a usage_subcommands_args
	usage_subcommands_args=()
	usage_subcommands_invoked=0
	function hbl::command::usage::subcommands() {
		usage_subcommands_invoked=1
		usage_subcommands_args=("$@")
		echo "Subcommands"
		return 0
	}
}

#
# hbl::command::usage::show()
#
@test ".show() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::command::usage::show
	assert_failure $HBL_ERR_INVOCATION
}

@test ".show() with too many arguments exits with ERR_INVOCATION" {
	run hbl::command::usage::show "TEST_COMMAND" "extra"
	assert_failure $HBL_ERR_INVOCATION
}

@test ".show() with an empty command id exits with ERR_ARGUMENT" {
	run hbl::command::usage::show ""
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".show() with an undefined command exits with ERR_UNDEFINED" {
	run hbl::command::usage::show "INVALID_COMMAND"
	assert_failure $HBL_ERR_UNDEFINED
}

@test ".show() with a non-command argument exits with ERR_INVALID_COMMAND" {
	declare -a INVALID_COMMAND
	run hbl::command::usage::show "INVALID_COMMAND"
	assert_failure $HBL_ERR_INVALID_COMMAND
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

@test ".show() displays the subcommands" {
	hbl::command::usage::show "TEST_COMMAND"
	assert_equal $usage_subcommands_invoked 1
	assert_equal ${#usage_subcommands_args[@]} 1
	assert_equal ${usage_subcommands_args[0]} "TEST_COMMAND"
}
