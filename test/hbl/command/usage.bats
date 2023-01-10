setup() {
	load '../../test_helper/common'
	load '../../test_helper/command'
	common_setup
}

teardown() {
	__hbl_commands=()
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
	__test_command[_description]=''
	run hbl::command::usage::description '__test_command'
	assert_success
}

@test 'hbl::command::usage::description() with an empty description displays nothing' {
	hbl_test::mock_command '__test_command'
	__test_command[_description]=''
	run hbl::command::usage::description '__test_command'
	assert_output ''
}

@test 'hbl::command::usage::description() with a description succeeds' {
	hbl_test::mock_command '__test_command'
	__test_command[_description]='Test Description'
	run hbl::command::usage::description '__test_command'
	assert_success
}

@test 'hbl::command::usage::description() with a description displays it with a header' {
	hbl_test::mock_command '__test_command'
	__test_command[_description]='Test Description'
	run hbl::command::usage::description '__test_command'
	assert_output - <<-EOF
	Description:
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
	TRACE=1
	local command_id
	hbl_test::generate_command 'test-command' 'command_id'
	run hbl::command::usage::examples "$command_id"
	assert_success
}

@test 'hbl::command::usage::examples() with no examples displays a default' {
	local command_id
	hbl_test::generate_command 'test-command' 'command_id'
	run hbl::command::usage::examples "$command_id"
	assert_output - <<-EOF
		Usage:
		  test-command <options>

	EOF
}

@test 'hbl::command::usage::examples() with examples succeeds' {
	local command_id
	hbl_test::generate_command 'test-command' 'command_id'
	local -n command="$command_id"
	${command[add_example]} "-a <options>"
	run hbl::command::usage::examples "$command_id"
	assert_success
}

@test 'hbl::command::usage::examples() with examples displays them with a header' {
	hbl_test::mock_command '__test_command'
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
	__test_subcommand_1[_name]='run'
	__test_subcommand_1[_description]='A test subcommand.'
	declare -A __test_subcommand_2
	__test_subcommand_2[_name]='execute'
	__test_subcommand_2[_description]='Another test subcommand.'
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

# function description_loop_function() {
# 	for i in {1..100}; do
# 		hbl::command::set_description "$1" "Direct description"
# 	done
# }

# function description_loop_class() {
# 	local -n command__ref="$1"
# 	for i in {1..100}; do
# 		${command__ref[set_description]} "Direct description"
# 	done
# }

# function create_basic_command_test() {
# 	local -n command_id__var="command_id"

# 	hbl::add_command 'backup-client' backup_client::run "${!command_id__var}"
# 	local -n command=${command_id__var}
# 	${command[set_description]} 'Manage backup jobs.'
# 	${command[add_example]}     '-d /etc/jobs.d <options>'

# 	${command[add_option]}     'job_directory' 'option_id'
# 	local -n option=$option_id
# 	${option[set_type]}        'dir'
# 	${option[set_short_flag]}  'd'
# 	${option[set_long_flag]}   'job_directory'
# 	${option[set_description]} 'Backup job directory.'
# }

# function create_basic_command_loop() {

# 	run hbl_test::create_basic_command 'command_id'
# }

# @test 'hbl::command::usage::description() with a description performs' {
# 	local command_id
# 	hbl_test::generate_command 'test-command' command_id
# 	time description_loop_direct "$command_id" >&3
# 	time description_loop_function "$command_id" >&3
# 	time description_loop_class "$command_id" >&3
# 	printf "create_basic_command_test\n" >&3
# 	time create_basic_command_test >&3
# 	[ $? -eq 1 ]
# }
