setup() {
	load '../test_helper/common'
	load '../test_helper/command'
	common_setup
	hbl::init
	hbl::command::init

	declare -Ag TEST_COMMAND
	TEST_COMMAND=([name]='test-command' [entrypoint]='test_command::run')

	declare -Ag TEST_COMMAND_OPTION
	TEST_COMMAND_OPTION=()

	declare -a option_create_args
	option_create_args=()
	option_create_invoked=0
	function hbl::command::option::create() {
		option_create_invoked=1
		option_create_args=("$@")
		local -n option_id__ref="$3"
		option_id__ref='TEST_COMMAND_OPTION'
		return 0
	}

	HBL_COMMANDS=(TEST_COMMAND)
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
	run hbl::command::add_example 'TEST_COMMAND' 'example' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty command id
	run hbl::command::add_example '' 'example'
	assert_failure $HBL_ERR_ARGUMENT

	# empty example
	run hbl::command::add_example 'TEST_COMMAND' ''
	assert_failure $HBL_ERR_ARGUMENT

	# invalid command
	function hbl::command::ensure_command() { return 1; }
	run hbl::command::add_example 'TEST_COMMAND' 'example'
	unset hbl::command::ensure_command
	assert_failure
}

@test 'hbl::command::add_example() assigns the example to the command' {
	hbl::command::add_example 'TEST_COMMAND' 'example'
	hbl::array::contains 'TEST_COMMAND_EXAMPLES' 'example'
}

#
# hbl::command::add_option()
#
@test 'hbl::command::add_option() validates its arguments' {
	#insufficient arguments
	run hbl::command::add_option
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::command::add_option 'TEST_COMMAND' 'test_option' 'option_id' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty command id
	run hbl::command::add_option '' 'test_option' 'option_id'
	assert_failure $HBL_ERR_ARGUMENT

	# empty option name
	run hbl::command::add_option 'TEST_COMMAND' '' 'option_id'
	assert_failure $HBL_ERR_ARGUMENT

	# empty option id variable
	run hbl::command::add_option 'TEST_COMMAND' 'test_option' ''
	assert_failure $HBL_ERR_ARGUMENT

	# invaid command
	function hbl::command::ensure_command() { return 1; }
	run hbl::command::add_option 'TEST_COMMAND' 'test_option' 'option_id'
	assert_failure
	unset hbl::command::ensure_command
}

@test 'hbl::command::add_option() creates the option' {
	hbl::command::add_option 'TEST_COMMAND' 'test_option' 'option_id'
	assert_equal $option_create_invoked 1
}

@test 'hbl::command::add_option() passes the proper arguments to option::create()' {
	hbl::command::add_option 'TEST_COMMAND' 'test_option' 'option_id'
	assert_equal ${option_create_args[0]} 'TEST_COMMAND'
	assert_equal ${option_create_args[1]} 'test_option'
	assert_equal ${option_create_args[2]} 'option_id'
}

@test "hbl::command::add_option() assigns the option to the command" {
	hbl::command::add_option 'TEST_COMMAND' 'test_option' 'option_id'
	hbl::dict::get 'TEST_COMMAND_OPTIONS' 'test_option' 'opt'
	assert_equal "${opt}" 'TEST_COMMAND_OPTION'
}

@test 'hbl::command::add_option() returns the option id' {
	hbl::command::add_option 'TEST_COMMAND' 'test_option' 'option_id'
	assert_equal "$option_id" 'TEST_COMMAND_OPTION'
}

#
# hbl::command::add_subcommand()
#
@test 'hbl::command::add_subcommand() validates its arguments' {
	# insufficient arguments
	run hbl::command::add_subcommand
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::command::add_subcommand 'TEST_COMMAND' 'subcommand' \
		'subcommand_run' 'subcommand_id' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty parent id
	run hbl::command::add_subcommand '' 'subcommand' 'subcommand_run' \
		'subcommand_id'
	assert_failure $HBL_ERR_ARGUMENT

	# empty subcommand name
	run hbl::command::add_subcommand 'TEST_COMMAND' '' 'subcommand_run' \
		'subcommand_id'
	assert_failure $HBL_ERR_ARGUMENT

	# empty entrypoint
	run hbl::command::add_subcommand 'TEST_COMMAND' 'subcommand' '' \
		'sucommand_id'
	assert_failure $HBL_ERR_ARGUMENT

	# empty subcommand id var
	run hbl::command::add_subcommand 'TEST_COMMAND' 'subcommand' \
		'subcommand_run' ''
	assert_failure $HBL_ERR_ARGUMENT

	# invalid parent
	function hbl::command::ensure_command() { return 1; }
	run hbl::command::add_subcommand 'UNDEFINED_COMMAND' 'subcommand' \
		'subcommand_run' 'command_id'
	assert_failure
	unset hbl::command::ensure_command
}

@test 'hbl::command::add_subcommand() creates the command' {
	hbl::command::add_subcommand 'TEST_COMMAND' 'subcommand' \
		'subcommand_run' 'subcommand_id'
	assert_equal "$command_create_invoked" 1
	assert_equal ${command_create_args[0]} 'subcommand'
	assert_equal ${command_create_args[1]} 'subcommand_run'
	assert_equal ${command_create_args[2]} 'subcommand_id'
}

@test 'hbl::command::add_subcommand() sets the parent' {
	hbl::command::add_subcommand 'TEST_COMMAND' 'subcommand' \
		'subcommand_run' 'subcommand_id'
	assert_equal "${STUB_COMMAND_ID[parent]}" 'TEST_COMMAND'
}

@test "hbl::command::add_subcommand() sets the full_name" {
	hbl::command::add_subcommand 'TEST_COMMAND' 'subcommand' \
		'subcommand_run' 'command_id'
	assert_equal "${STUB_COMMAND_ID[full_name]}" 'test-command subcommand'
}

@test 'hbl::command::add_subcommand() assigns the command to the parent' {
	declare -ag TEST_COMMAND_SUBCOMMANDS
	hbl::command::add_subcommand 'TEST_COMMAND' 'subcommand' \
		'subcommand_run' 'command_id'
	run hbl::array::contains 'TEST_COMMAND_SUBCOMMANDS' 'STUB_COMMAND_ID'
	assert_success
}

#
# hbl::command::set_description()
#
@test 'hbl::command::set_description() validates its arguments' {
	# insufficient arguments
	run hbl::command::set_description
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::command::set_description 'TEST_COMMAND' 'test description' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty command id
	run hbl::command::set_description '' 'test description'
	assert_failure $HBL_ERR_ARGUMENT

	# empty description
	run hbl::command::set_description 'TEST_COMMAND' ''
	assert_failure $HBL_ERR_ARGUMENT

	# invalid command
	function hbl::command::ensure_command() { return 1; }
	run hbl::command::set_description 'TEST_COMMAND' 'test description'
	assert_failure
	unset hbl::command::ensure_command
}

@test 'hbl::command::set_description() sets the description' {
	hbl::command::set_description 'TEST_COMMAND' 'test description'
	assert_equal "${TEST_COMMAND[desc]}" 'test description'
}

#
# hbl::command::ensure_command()
#
@test 'hbl::command::ensure_command() validates its arguments' {
	# insufficient arguments
	run ensure_command
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run ensure_command 'command' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty command id
	run ensure_command ''
	assert_failure $HBL_ERR_ARGUMENT
}

@test 'hbl::command::ensure_command() with an undefined variable returns HBL_ERR_UNDEFINED' {
	run hbl::command::ensure_command 'INVALID_COMMAND'
	assert_failure $HBL_ERR_UNDEFINED
}

@test 'hbl::command::ensure_command() with a non-dict returns HBL_ERR_UNDEFINED' {
	declare -a __command
	run ensure_command '__command'
	assert_failure $HBL_ERR_INVALID_COMMAND
}

@test 'hbl::command::ensure_command() with a valid dict succeeds' {
	declare -A __command
	run ensure_command '__command'
	assert_success
	refute_output
}
