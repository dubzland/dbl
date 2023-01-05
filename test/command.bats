setup() {
	load 'test_helper/common'
	load 'test_helper/command'
	common_setup
	hbl::init

	# Mock the options init
	local -i options_args_count
	local -a options_args
	function hbl::command::options::init() { options_args_count="$#"; options_args=("$@"); }
	export -f hbl::command::options::init

	# Mock the examples init
	local -i examples_args_count
	local -a examples_args
	function hbl::command::examples::init() { examples_args_count="$#"; examples_args=("$@"); }
	export -f hbl::command::examples::init

	# Mock the subcommands init
	local -i subcommands_args_count
	local -a subcommands_args
	function hbl::command::subcommands::init() { subcommands_args_count="$#"; subcommands_args=("$@"); }
	export -f hbl::command::subcommands::init

	# Mock adding a subcommand
	local -i subcommands_add_args_count
	local -a subcommands_add_args
	function hbl::command::subcommands::add() { subcommands_add_args_count="$#"; subcommands_add_args=("$@"); }
	export -f hbl::command::subcommands::add
}

command_setup() {
	declare -g command_id
	hbl::command::init
	make_command command_id
}

subcommand_setup() {
	declare -g command_id
	declare -g subcommand_id
	hbl::command::init
	make_subcommand command_id subcommand_id
}

@test "init() creates the HBL_COMMAND associative array" {
	hbl::command::init
	run is_defined HBL_COMMAND
	assert_success
}

@test "init() assigns an empty command name" {
	hbl::command::init
	assert_equal "${HBL_COMMAND[name]}" ""
}

@test "init() creates the HBL_PARAMS associative array" {
	hbl::command::init
	run is_defined HBL_PARAMS
	assert_success
}

@test "init() sets verbose to 0" {
	hbl::command::init
	assert_equal ${HBL_PARAMS[verbose]} 0
}

@test "init() sets showhelp to 0" {
	hbl::command::init
	assert_equal ${HBL_PARAMS[showhelp]} 0
}

@test "init() creates the HBL_COMMANDS associative array" {
	hbl::command::init
	run is_associative_array HBL_COMMANDS
	assert_success
}

##
## Normal command registration
##

@test "create() for a normal command creates the global command module" {
	command_setup
	run is_associative_array HBL_TEST_COMMAND
	assert_success
}

@test "create() for a normal command returns the id to caller" {
	command_setup
	assert_equal "${command_id}" "test-command"
}

@test "create() for a normal command sets the proper id" {
	command_setup
	assert_equal "${HBL_TEST_COMMAND[id]}" "test-command"
}

@test "create() for a normal command sets an empty parent" {
	command_setup
	assert_equal "${HBL_TEST_COMMAND[parent]}" ""
}

@test "create() for a normal command sets the proper name" {
	command_setup
	assert_equal "${HBL_TEST_COMMAND[name]}" "test-command"
}

@test "create() for a normal command sets the proper fullname" {
	command_setup
	assert_equal "${HBL_TEST_COMMAND[fullname]}" "test-command"
}

@test "create() for a normal command sets the proper namespace" {
	command_setup
	assert_equal "${HBL_TEST_COMMAND[namespace]}" "test_command"
}

@test "create() for a normal command sets the proper module" {
	command_setup
	assert_equal "${HBL_TEST_COMMAND[module]}" "HBL_TEST_COMMAND"
}

@test "create() for a normal command sets the proper description" {
	command_setup
	assert_equal "${HBL_TEST_COMMAND[desc]}" "Test command."
}

@test "create() for a normal command stores the module in HBL_COMMANDS" {
	command_setup
	assert_equal "${HBL_COMMANDS[test-command]}" "HBL_TEST_COMMAND"
}

@test "create() for a normal command initializes the options" {
	command_setup
	assert_equal $options_args_count 1
	assert_equal "${options_args[0]}" "test-command"
}

@test "create() for a normal command initializes the examples" {
	command_setup
	assert_equal $examples_args_count 1
	assert_equal "${examples_args[0]}" "test-command"
}

@test "create() for a normal command initializes the subcommands" {
	command_setup
	assert_equal $subcommands_args_count 1
	assert_equal "${subcommands_args[0]}" "test-command"
}

#
# Subcommand registration
#

@test "create() for a subcommand creates the global command module" {
	subcommand_setup
	run is_associative_array HBL_TEST_COMMAND_TEST_SUBCOMMAND
	assert_success
}

@test "create() for a subcommand returns the id to caller" {
	subcommand_setup
	assert_equal "${subcommand_id}" "test-command::test-subcommand"
}

@test "create() for a subcommand sets the parent" {
	subcommand_setup
	assert_equal "${HBL_TEST_COMMAND_TEST_SUBCOMMAND[parent]}" \
		"${command_id}"
}

@test "create() for a subcommand sets the proper name" {
	subcommand_setup
	assert_equal "${HBL_TEST_COMMAND_TEST_SUBCOMMAND[name]}" \
		"test-subcommand"
}

@test "create() for a subcommand sets the proper full name" {
	subcommand_setup
	assert_equal "${HBL_TEST_COMMAND_TEST_SUBCOMMAND[fullname]}" \
		"test-command test-subcommand"
}

@test "create() for a subcommand sets the proper namespace" {
	subcommand_setup
	assert_equal "${HBL_TEST_COMMAND_TEST_SUBCOMMAND[namespace]}" \
		"test_command::test_subcommand"
}

@test "create() for a subcommand sets the proper module" {
	subcommand_setup
	assert_equal "${HBL_TEST_COMMAND_TEST_SUBCOMMAND[module]}" \
		"HBL_TEST_COMMAND_TEST_SUBCOMMAND"
}

@test "create() for a subcommand sets the proper description" {
	subcommand_setup
	assert_equal "${HBL_TEST_COMMAND_TEST_SUBCOMMAND[desc]}" \
		"Test subcommand."
}

@test "create() for a subcommand stores the module in HBL_COMMANDS" {
	subcommand_setup
	assert_equal "${HBL_COMMANDS["${subcommand_id}"]}" \
		"HBL_TEST_COMMAND_TEST_SUBCOMMAND"
}

@test "create() for a subcommand appends to the parent's subcommands" {
	subcommand_setup
	assert_equal $subcommands_add_args_count 2
	assert_equal "${subcommands_add_args[0]}" "test-command"
	assert_equal "${subcommands_add_args[1]}" "test-command::test-subcommand"
}

@test "create() for a subcommand initializes the options" {
	subcommand_setup
	assert_equal $options_args_count 1
	assert_equal "${options_args[0]}" "${subcommand_id}"
}

@test "create() for a subcommand initializes the examples" {
	subcommand_setup
	assert_equal $examples_args_count 1
	assert_equal "${examples_args[0]}" "${subcommand_id}"
}

@test "create() for a subcommand initializes the subcommands" {
	subcommand_setup
	assert_equal $subcommands_args_count 1
	assert_equal "${subcommands_args[0]}" "${subcommand_id}"
}
