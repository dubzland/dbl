setup() {
	load '../test_helper/common'
	load '../test_helper/command'
	common_setup
	hbl::init
	hbl::command::init

	declare -a option_create_args
	option_create_args=()
	option_create_invoked=0
	function hbl::command::option::create() {
		option_create_invoked=1
		option_create_args=("$@")
		local -n option_id__ref="$3"
		option_id__ref='__test_command_option'
		return 0
	}

	hbl_test::stub_command_create

	function ensure_command() {
		hbl::command::ensure_command "$@"
	}
}

#
# hbl::command::add_example()
#
@test 'hbl::command::add_example() validates its arguments' {
	# insufficient arguments
	run hbl::command::add_example
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::command::add_example '__test_command' 'example' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty command id
	run hbl::command::add_example '' 'example'
	assert_failure $HBL_ERR_ARGUMENT

	# empty example
	run hbl::command::add_example '__test_command' ''
	assert_failure $HBL_ERR_ARGUMENT

	# invalid command
	function hbl::command::ensure_command() { return 1; }
	run hbl::command::add_example '__test_command' 'example'
	unset hbl::command::ensure_command
	assert_failure
}

@test 'hbl::command::add_example() assigns the example to the command' {
	hbl_test::mock_command '__test_command'
	hbl::command::add_example '__test_command' 'example'
	hbl::array::contains '__test_command__examples' 'example'
}

#
# hbl::command::add_option()
#
@test 'hbl::command::add_option() validates its arguments' {
	#insufficient arguments
	run hbl::command::add_option
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::command::add_option '__test_command' 'test_option' 'option_id' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty command id
	run hbl::command::add_option '' 'test_option' 'option_id'
	assert_failure $HBL_ERR_ARGUMENT

	# empty option name
	run hbl::command::add_option '__test_command' '' 'option_id'
	assert_failure $HBL_ERR_ARGUMENT

	# empty option id variable
	run hbl::command::add_option '__test_command' 'test_option' ''
	assert_failure $HBL_ERR_ARGUMENT

	# invaid command
	function hbl::command::ensure_command() { return 1; }
	run hbl::command::add_option '__test_command' 'test_option' 'option_id'
	assert_failure
	unset hbl::command::ensure_command
}

@test 'hbl::command::add_option() creates the option' {
	hbl_test::mock_command '__test_command'
	hbl::command::add_option '__test_command' 'test_option' 'option_id'
	assert_equal $option_create_invoked 1
}

@test 'hbl::command::add_option() passes the proper arguments to option::create()' {
	hbl_test::mock_command '__test_command'
	hbl::command::add_option '__test_command' 'test_option' 'option_id'
	assert_equal ${option_create_args[0]} '__test_command'
	assert_equal ${option_create_args[1]} 'test_option'
	assert_equal ${option_create_args[2]} 'option_id'
}

@test "hbl::command::add_option() assigns the option to the command" {
	hbl_test::mock_command '__test_command'
	hbl::command::add_option '__test_command' 'test_option' 'option_id'
	hbl::dict::get '__test_command__options' 'test_option' 'opt'
	assert_equal "${opt}" '__test_command_option'
}

@test 'hbl::command::add_option() returns the option id' {
	hbl_test::mock_command '__test_command'
	hbl::command::add_option '__test_command' 'test_option' 'option_id'
	assert_equal "$option_id" '__test_command_option'
}

#
# hbl::command::add_subcommand()
#
@test 'hbl::command::add_subcommand() validates its arguments' {
	# insufficient arguments
	run hbl::command::add_subcommand
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::command::add_subcommand '__test_command' 'subcommand' \
		'subcommand_run' 'subcommand_id' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty parent id
	run hbl::command::add_subcommand '' 'subcommand' 'subcommand_run' \
		'subcommand_id'
	assert_failure $HBL_ERR_ARGUMENT

	# empty subcommand name
	run hbl::command::add_subcommand '__test_command' '' 'subcommand_run' \
		'subcommand_id'
	assert_failure $HBL_ERR_ARGUMENT

	# empty entrypoint
	run hbl::command::add_subcommand '__test_command' 'subcommand' '' \
		'sucommand_id'
	assert_failure $HBL_ERR_ARGUMENT

	# empty subcommand id var
	run hbl::command::add_subcommand '__test_command' 'subcommand' \
		'subcommand_run' ''
	assert_failure $HBL_ERR_ARGUMENT

	# invalid parent
	function hbl::command::ensure_command() { return 1; }
	run hbl::command::add_subcommand '__test_command' 'subcommand' \
		'subcommand_run' 'command_id'
	assert_failure
	unset hbl::command::ensure_command
}

@test 'hbl::command::add_subcommand() creates the command' {
	hbl_test::mock_command '__test_command'
	hbl::command::add_subcommand '__test_command' 'subcommand' \
		'subcommand_run' 'subcommand_id'
	assert_equal "$command_create_invoked" 1
	assert_equal ${command_create_args[0]} 'subcommand'
	assert_equal ${command_create_args[1]} 'subcommand_run'
	assert_equal ${command_create_args[2]} 'subcommand_id'
}

@test 'hbl::command::add_subcommand() sets the parent' {
	hbl_test::mock_command '__test_command'
	hbl::command::add_subcommand '__test_command' 'subcommand' \
		'subcommand_run' 'subcommand_id'
	assert_equal "${__stubbed_command[parent]}" '__test_command'
}

@test "hbl::command::add_subcommand() sets the full_name" {
	hbl_test::mock_command '__test_command'
	hbl::command::add_subcommand '__test_command' 'subcommand' \
		'subcommand_run' 'command_id'
	assert_equal "${__stubbed_command[full_name]}" 'test-command subcommand'
}

@test 'hbl::command::add_subcommand() assigns the command to the parent' {
	hbl_test::mock_command '__test_command'
	hbl::command::add_subcommand '__test_command' 'subcommand' \
		'subcommand_run' 'command_id'
	assert_array_contains '__test_command__subcommands' '__stubbed_command'
}

#
# hbl::command::set_description()
#
@test 'hbl::command::set_description() validates its arguments' {
	# insufficient arguments
	run hbl::command::set_description
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::command::set_description '__test_command' 'test description' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty command id
	run hbl::command::set_description '' 'test description'
	assert_failure $HBL_ERR_ARGUMENT

	# empty description
	run hbl::command::set_description '__test_command' ''
	assert_failure $HBL_ERR_ARGUMENT

	# invalid command
	function hbl::command::ensure_command() { return 1; }
	run hbl::command::set_description '__test_command' 'test description'
	assert_failure
	unset hbl::command::ensure_command
}

@test 'hbl::command::set_description() sets the description' {
	hbl_test::mock_command '__test_command'
	hbl::command::set_description '__test_command' 'test description'
	assert_equal "${__test_command[desc]}" 'test description'
}

#
# hbl::command::ensure_command()
#
@test 'hbl::command::ensure_command() validates its arguments' {
	# insufficient arguments
	run ensure_command
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run ensure_command '__test_command' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty command id
	run ensure_command ''
	assert_failure $HBL_ERR_ARGUMENT
}

@test 'hbl::command::ensure_command() with an undefined variable returns HBL_ERR_UNDEFINED' {
	run hbl::command::ensure_command '__test_command'
	assert_failure $HBL_ERR_UNDEFINED
}

@test 'hbl::command::ensure_command() with a non-dict returns HBL_ERR_UNDEFINED' {
	declare -a __test_command
	run ensure_command '__test_command'
	assert_failure $HBL_ERR_INVALID_COMMAND
}

@test 'hbl::command::ensure_command() with a valid dict succeeds' {
	hbl_test::mock_command '__test_command'
	run ensure_command '__test_command'
	assert_success
	refute_output
}
