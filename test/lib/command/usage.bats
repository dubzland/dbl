#setup() {
#	load '../../test_helper/common'
#	load '../../test_helper/command'
#	common_setup
#}

#teardown() {
#	__hbl_commands=()
#}

##
## hbl__command__usage__description()
##
#@test 'hbl__command__usage__description() validates its arguments' {
#	# insufficient arguments
#	run hbl__command__usage__description
#	assert_failure $__hbl__rc__argument_error

#	# too many arguments
#	run hbl__command__usage__description '__test_command' 'extra'
#	assert_failure $__hbl__rc__argument_error

#	# empty command id
#	run hbl__command__usage__description ''
#	assert_failure $__hbl__rc__argument_error

#	# invalid command
#	function hbl__command__ensure_command() { return 1; }
#	run hbl__command__usage__description '__test_command'
#	unset hbl__command__ensure_command
#	assert_failure
#}

#@test 'hbl__command__usage__description() with an empty description succeeds' {
#	hbl_test__mock_command '__test_command'
#	__test_command[_description]=''
#	run hbl__command__usage__description '__test_command'
#	assert_success
#}

#@test 'hbl__command__usage__description() with an empty description displays nothing' {
#	hbl_test__mock_command '__test_command'
#	__test_command[_description]=''
#	run hbl__command__usage__description '__test_command'
#	assert_output ''
#}

#@test 'hbl__command__usage__description() with a description succeeds' {
#	hbl_test__mock_command '__test_command'
#	__test_command[_description]='Test Description'
#	run hbl__command__usage__description '__test_command'
#	assert_success
#}

#@test 'hbl__command__usage__description() with a description displays it with a header' {
#	hbl_test__mock_command '__test_command'
#	__test_command[_description]='Test Description'
#	run hbl__command__usage__description '__test_command'
#	assert_output - <<-EOF
#	Description:
#	  Test Description

#	EOF
#}

##
## hbl__command__usage__examples()
##
#@test 'hbl__command__usage__examples() validates its arguments' {
#	# insufficient arguments
#	run hbl__command__usage__examples
#	assert_failure $__hbl__rc__argument_error

#	# too many arguments
#	run hbl__command__usage__examples '__test_command' 'extra'
#	assert_failure $__hbl__rc__argument_error

#	# empty command id
#	run hbl__command__usage__examples ''
#	assert_failure $__hbl__rc__argument_error

#	# invalid command
#	function hbl__command__ensure_command() { return 1; }
#	run hbl__command__usage__examples '__test_command'
#	assert_failure
#	unset hbl__command__ensure_command
#}

#@test 'hbl__command__usage__examples() with no examples succeeds' {
#	TRACE=1
#	local command_id
#	hbl_test__generate_command 'test-command' 'command_id'
#	run hbl__command__usage__examples "$command_id"
#	assert_success
#}

#@test 'hbl__command__usage__examples() with no examples displays a default' {
#	local command_id
#	hbl_test__generate_command 'test-command' 'command_id'
#	run hbl__command__usage__examples "$command_id"
#	assert_output - <<-EOF
#		Usage:
#		  test-command <options>

#	EOF
#}

#@test 'hbl__command__usage__examples() with examples succeeds' {
#	local command_id
#	hbl_test__generate_command 'test-command' 'command_id'
#	local -n command="$command_id"
#	${command[add_example]} "-a <options>"
#	run hbl__command__usage__examples "$command_id"
#	assert_success
#}

#@test 'hbl__command__usage__examples() with examples displays them with a header' {
#	hbl_test__mock_command '__test_command'
#	declare -a __test_command__examples
#	__test_command__examples=("-a <options>")
#	run hbl__command__usage__examples '__test_command'
#	assert_output - <<-EOF
#		Usage:
#		  test-command -a <options>

#	EOF
#}

##
## hbl__command__usage__subcommands()
##
#@test 'hbl__command__usage__subcommands() validates its arguments' {
#	# insufficient arguments
#	run hbl__command__usage__subcommands
#	assert_failure $__hbl__rc__argument_error

#	# too many arguments
#	run hbl__command__usage__subcommands '__test_command' 'extra'
#	assert_failure $__hbl__rc__argument_error

#	# empty command id
#	run hbl__command__usage__subcommands ''
#	assert_failure $__hbl__rc__argument_error

#	# invalid command
#	function hbl__command__ensure_command() { return 1; }
#	run hbl__command__usage__subcommands '__test_command'
#	assert_failure
#	unset hbl__command__ensure_command
#}

#@test 'hbl__command__usage__subcommands() with no subcommands succeeds' {
#	hbl_test__mock_command '__test_command'
#	declare -A __test_command__subcommands
#	run hbl__command__usage__subcommands '__test_command'
#	assert_success
#}

#@test 'hbl__command__usage__subcommands() with no subcommands displays nothing' {
#	hbl_test__mock_command '__test_command'
#	declare -A __test_command__subcommands
#	run hbl__command__usage__subcommands '__test_command'
#	assert_output ""
#}

#@test 'hbl__command__usage__subcommands() with subcommands succeeds' {
#	hbl_test__mock_command '__test_command'
#	declare -A __test_command__subcommands

#	declare -A __test_subcommand_1
#	__test_subcommand_1[_name]='run'
#	__test_subcommand_1[_description]='A test subcommand.'
#	declare -A __test_subcommand_2
#	__test_subcommand_2[_name]='execute'
#	__test_subcommand_2[_description]='Another test subcommand.'
#	__test_command__subcommands=('__test_subcommand_1' '__test_subcommand_2')
#	run hbl__command__usage__subcommands '__test_command'
#	assert_success
#}

#@test 'hbl__command__usage__subcommands() with subcommands displays them with a header' {
#	hbl_test__mock_command '__test_command'
#	declare -a __test_command__subcommands

#	declare -A __test_subcommand_1
#	__test_subcommand_1[name]='run'
#	__test_subcommand_1[desc]='A test subcommand.'
#	declare -A __test_subcommand_2
#	__test_subcommand_2[name]='execute'
#	__test_subcommand_2[desc]='Another test subcommand.'

#	__test_command__subcommands=('__test_subcommand_1' '__test_subcommand_2')

#	run hbl__command__usage__subcommands '__test_command'
#	assert_success
#	assert_output - <<-EOF
#		Subcommands:
#		  execute                   Another test subcommand.
#		  run                       A test subcommand.

#	EOF
#}

## function description_loop_function() {
## 	for i in {1..100}; do
## 		hbl__command__set_description "$1" "Direct description"
## 	done
## }

## function description_loop_class() {
## 	local -n command__ref="$1"
## 	for i in {1..100}; do
## 		${command__ref[set_description]} "Direct description"
## 	done
## }

## function create_basic_command_test() {
## 	local -n command_id__var="command_id"

## 	hbl__add_command 'backup-client' backup_client__run "${!command_id__var}"
## 	local -n command=${command_id__var}
## 	${command[set_description]} 'Manage backup jobs.'
## 	${command[add_example]}     '-d /etc/jobs.d <options>'

## 	${command[add_option]}     'job_directory' 'option_id'
## 	local -n option=$option_id
## 	${option[set_type]}        'dir'
## 	${option[set_short_flag]}  'd'
## 	${option[set_long_flag]}   'job_directory'
## 	${option[set_description]} 'Backup job directory.'
## }

## function create_basic_command_loop() {

## 	run hbl_test__create_basic_command 'command_id'
## }

## @test 'hbl__command__usage__description() with a description performs' {
## 	local command_id
## 	hbl_test__generate_command 'test-command' command_id
## 	time description_loop_direct "$command_id" >&3
## 	time description_loop_function "$command_id" >&3
## 	time description_loop_class "$command_id" >&3
## 	printf "create_basic_command_test\n" >&3
## 	time create_basic_command_test >&3
## 	[ $? -eq 1 ]
## }
