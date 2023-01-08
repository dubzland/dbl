setup() {
	load '../../test_helper/common'
	common_setup

	declare -Ag TEST_COMMAND
	TEST_COMMAND[name]="test-command"

	declare -ag TEST_COMMAND_SUBCOMMANDS
	TEST_COMMAND_SUBCOMMANDS=()

	declare -Ag TEST_SUBCOMMAND1
	TEST_SUBCOMMAND1[name]="run"
	TEST_SUBCOMMAND1[desc]="A test subcommand."

	declare -Ag TEST_SUBCOMMAND2
	TEST_SUBCOMMAND2[name]="execute"
	TEST_SUBCOMMAND2[desc]="Another test subcommand."
}

#
# hbl::command::usage::description()
#
@test 'hbl::command::usage::description() validates its arguments' {
	# insufficient arguments
	run hbl::command::usage::description
	assert_failure $HBL_ERR_INVOCATION

	# too many arguments
	run hbl::command::usage::description 'TEST_COMMAND' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty command id
	run hbl::command::usage::description ''
	assert_failure $HBL_ERR_ARGUMENT

	# invalid command
	function hbl::command::ensure_command() { return 1; }
	run hbl::command::usage::description "INVALID_COMMAND"
	unset hbl::command::ensure_command
	assert_failure
}

@test 'hbl::command::usage::description() with an empty description succeeds' {
	TEST_COMMAND[desc]=''
	run hbl::command::usage::description 'TEST_COMMAND'
	assert_success
}

@test 'hbl::command::usage::description() with an empty description displays nothing' {
	TEST_COMMAND[desc]=''
	run hbl::command::usage::description 'TEST_COMMAND'
	assert_output ''
}

@test 'hbl::command::usage::description() with a description succeeds' {
	TEST_COMMAND[desc]='Test Description'
	run hbl::command::usage::description 'TEST_COMMAND'
	assert_success
}

@test 'hbl::command::usage::description() with a description displays it with a header' {
	TEST_COMMAND[desc]='Test Description'
	run hbl::command::usage::description 'TEST_COMMAND'
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
	run hbl::command::usage::examples 'TEST_COMMAND' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty command id
	run hbl::command::usage::examples ''
	assert_failure $HBL_ERR_ARGUMENT

	# invalid command
	function hbl::command::ensure_command() { return 1; }
	run hbl::command::usage::examples "INVALID_COMMAND"
	assert_failure
	unset hbl::command::ensure_command
}

@test 'hbl::command::usage::examples() with no examples succeeds' {
	TEST_COMMAND['name']="test-command"
	TEST_COMMAND_EXAMPLES=()
	run hbl::command::usage::examples TEST_COMMAND
	assert_success
}

@test 'hbl::command::usage::examples() with no examples displays a default' {
	TEST_COMMAND['name']="test-command"
	TEST_COMMAND_EXAMPLES=()
	run hbl::command::usage::examples TEST_COMMAND
	assert_output - <<-EOF
		Usage:
		  test-command <options>

	EOF
}

@test 'hbl::command::usage::examples() with examples succeeds' {
	TEST_COMMAND[name]="test-command"
	TEST_COMMAND_EXAMPLES=("-a <options>")
	run hbl::command::usage::examples TEST_COMMAND
	assert_success
}

@test 'hbl::command::usage::examples() with examples displays them with a header' {
	TEST_COMMAND[name]="test-command"
	TEST_COMMAND_EXAMPLES=("-a <options>")
	run hbl::command::usage::examples TEST_COMMAND
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
	run hbl::command::usage::subcommands 'TEST_COMMAND' 'extra'
	assert_failure $HBL_ERR_INVOCATION

	# empty command id
	run hbl::command::usage::subcommands ''
	assert_failure $HBL_ERR_ARGUMENT

	# invalid command
	function hbl::command::ensure_command() { return 1; }
	run hbl::command::usage::subcommands 'TEST_COMMAND'
	assert_failure
	unset hbl::command::ensure_command
}

@test 'hbl::command::usage::subcommands() with no subcommands succeeds' {
	TEST_COMMAND_SUBCOMMANDS=()
	run hbl::command::usage::subcommands 'TEST_COMMAND'
	assert_success
}

@test 'hbl::command::usage::subcommands() with no subcommands displays nothing' {
	TEST_COMMAND_SUBCOMMANDS=()
	run hbl::command::usage::subcommands 'TEST_COMMAND'
	assert_output ""
}

@test 'hbl::command::usage::subcommands() with subcommands succeeds' {
	TEST_COMMAND_SUBCOMMANDS=('TEST_SUBCOMMAND1' 'TEST_SUBCOMMAND2')
	run hbl::command::usage::subcommands 'TEST_COMMAND'
	assert_success
}
@test 'hbl::command::usage::subcommands() with subcommands displays them with a header' {
	TEST_COMMAND_SUBCOMMANDS=('TEST_SUBCOMMAND1' 'TEST_SUBCOMMAND2')
	run hbl::command::usage::subcommands TEST_COMMAND
	assert_success
	assert_output - <<-EOF
		Subcommands:
		  execute                   Another test subcommand.
		  run                       A test subcommand.

	EOF
}
