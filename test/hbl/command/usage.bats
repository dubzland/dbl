setup() {
	load '../../test_helper/common'
	load '../../test_helper/command'
	common_setup
}

#
# hbl::command::usage::description()
#
@test 'hbl::command::usage::description() validates its arguments' {
	# insufficient arguments
	run hbl::command::usage::description
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::command::usage::description '__test_command' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty command id
	run hbl::command::usage::description ''
	assert_failure $HBL_ERR_ARGUMENT

	# invalid command
	function hbl::command::ensure_command() { return 1; }
	run hbl::command::usage::description '__test_command'
	unset hbl::command::ensure_command
	assert_failure
}

@test 'hbl::command::usage::description() with an empty description succeeds' {
	hbl_test::mock_command '__test_command'
	__test_command[desc]=''
	run hbl::command::usage::description '__test_command'
	assert_success
}

@test 'hbl::command::usage::description() with an empty description displays nothing' {
	hbl_test::mock_command '__test_command'
	__test_command[desc]=''
	run hbl::command::usage::description '__test_command'
	assert_output ''
}

@test 'hbl::command::usage::description() with a description succeeds' {
	hbl_test::mock_command '__test_command'
	__test_command[desc]='Test Description'
	run hbl::command::usage::description '__test_command'
	assert_success
}

@test 'hbl::command::usage::description() with a description displays it with a header' {
	hbl_test::mock_command '__test_command'
	__test_command[desc]='Test Description'
	run hbl::command::usage::description '__test_command'
	assert_output - <<-EOF
	Description
	  Test Description

	EOF
}

#
# hbl::command::usage::examples()
#
@test 'hbl::command::usage::examples() validates its arguments' {
	# insufficient arguments
	run hbl::command::usage::examples
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::command::usage::examples '__test_command' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty command id
	run hbl::command::usage::examples ''
	assert_failure $HBL_ERR_ARGUMENT

	# invalid command
	function hbl::command::ensure_command() { return 1; }
	run hbl::command::usage::examples '__test_command'
	assert_failure
	unset hbl::command::ensure_command
}

@test 'hbl::command::usage::examples() with no examples succeeds' {
	hbl_test::mock_command '__test_command'
	__test_command['name']="test-command"
	declare -a __test_command__examples
	__test_command__examples=()
	run hbl::command::usage::examples '__test_command'
	assert_success
}

@test 'hbl::command::usage::examples() with no examples displays a default' {
	hbl_test::mock_command '__test_command'
	__test_command['name']="test-command"
	declare -a __test_command__examples
	__test_command__examples=()
	run hbl::command::usage::examples '__test_command'
	assert_output - <<-EOF
		Usage:
		  test-command <options>

	EOF
}

@test 'hbl::command::usage::examples() with examples succeeds' {
	hbl_test::mock_command '__test_command'
	__test_command['name']="test-command"
	declare -a __test_command__examples
	__test_command__examples=("-a <options>")
	run hbl::command::usage::examples '__test_command'
	assert_success
}

@test 'hbl::command::usage::examples() with examples displays them with a header' {
	hbl_test::mock_command '__test_command'
	__test_command['name']="test-command"
	declare -a __test_command__examples
	__test_command__examples=("-a <options>")
	run hbl::command::usage::examples '__test_command'
	assert_output - <<-EOF
		Usage:
		  test-command -a <options>

	EOF
}

#
# hbl::command::usage::subcommands()
#
@test 'hbl::command::usage::subcommands() validates its arguments' {
	# insufficient arguments
	run hbl::command::usage::subcommands
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::command::usage::subcommands '__test_command' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty command id
	run hbl::command::usage::subcommands ''
	assert_failure $HBL_ERR_ARGUMENT

	# invalid command
	function hbl::command::ensure_command() { return 1; }
	run hbl::command::usage::subcommands '__test_command'
	assert_failure
	unset hbl::command::ensure_command
}

@test 'hbl::command::usage::subcommands() with no subcommands succeeds' {
	hbl_test::mock_command '__test_command'
	declare -A __test_command__subcommands
	run hbl::command::usage::subcommands '__test_command'
	assert_success
}

@test 'hbl::command::usage::subcommands() with no subcommands displays nothing' {
	hbl_test::mock_command '__test_command'
	declare -A __test_command__subcommands
	run hbl::command::usage::subcommands '__test_command'
	assert_output ""
}

@test 'hbl::command::usage::subcommands() with subcommands succeeds' {
	hbl_test::mock_command '__test_command'
	declare -A __test_command__subcommands

	declare -A __test_subcommand_1
	__test_subcommand_1[name]='run'
	__test_subcommand_1[desc]='A test subcommand.'
	declare -A __test_subcommand_2
	__test_subcommand_2[name]='execute'
	__test_subcommand_2[desc]='Another test subcommand.'
	__test_command__subcommands=('__test_subcommand_1' '__test_subcommand_2')
	run hbl::command::usage::subcommands '__test_command'
	assert_success
}

@test 'hbl::command::usage::subcommands() with subcommands displays them with a header' {
	hbl_test::mock_command '__test_command'
	declare -a __test_command__subcommands

	declare -A __test_subcommand_1
	__test_subcommand_1[name]='run'
	__test_subcommand_1[desc]='A test subcommand.'
	declare -A __test_subcommand_2
	__test_subcommand_2[name]='execute'
	__test_subcommand_2[desc]='Another test subcommand.'

	__test_command__subcommands=('__test_subcommand_1' '__test_subcommand_2')

	run hbl::command::usage::subcommands '__test_command'
	assert_success
	assert_output - <<-EOF
		Subcommands:
		  execute                   Another test subcommand.
		  run                       A test subcommand.

	EOF
}
