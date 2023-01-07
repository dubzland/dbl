setup() {
	load '../test_helper/common'
	load '../test_helper/command'
	common_setup
	hbl::init
	hbl::command::init

	HBL_COMMANDS+=("HBL_COMMAND_0")
	declare -Ag HBL_COMMAND_0
	HBL_COMMAND_0[name]="test-command"
	hbl_test::stub_command_create

	declare -a option_create_args
	option_create_args=()
	option_create_invoked=0
	function hbl::command::option::create() {
		option_create_invoked=1
		option_create_args=("$@")
		local -n option_id__ref="$3"
		option_id__ref="${1}_TEST_OPTION_ID"
		return 0
	}
}

@test ".add_example() when insufficient arguments are passed returns INVALID_ARGS" {
	run hbl::command::add_example
	assert_failure $HBL_INVALID_ARGS
}

@test ".add_example() when too many arguments are passed returns INVALID_ARGS" {
	run hbl::command::add_example "TEST_COMMAND_ID" "example" extra
	assert_failure $HBL_INVALID_ARGS
}

@test ".add_example() assigns the example to the command" {
	hbl::command::add_example "TEST_COMMAND_ID" "example"
	hbl::array::contains "TEST_COMMAND_ID_EXAMPLES" "example"
}

@test ".add_option() when insufficient arguments are passed returns INVALID_ARGS" {
	run hbl::command::add_option
	assert_failure $HBL_INVALID_ARGS
}

@test ".add_option() when too many arguments are passed returns INVALID_ARGS" {
	run hbl::command::add_option "TEST_COMMAND_ID" "test_option" option_id extra
	assert_failure $HBL_INVALID_ARGS
}

@test ".add_option() creates the option" {
	hbl::command::add_option "TEST_COMMAND_ID" "test_option" option_id
	assert_equal $option_create_invoked 1
}

@test ".add_option() passes the proper arguments to option::create()" {
	hbl::command::add_option "TEST_COMMAND_ID" "test_option" option_id
	assert_equal ${option_create_args[0]} "TEST_COMMAND_ID"
	assert_equal ${option_create_args[1]} "test_option"
	assert_equal ${option_create_args[2]} "option_id"
}

@test ".add_option() assigns the option to the command" {
	hbl::command::add_option "TEST_COMMAND_ID" "test_option" option_id
	hbl::dict::get "TEST_COMMAND_ID_OPTIONS" "test_option" opt
	assert_equal "${opt}" "TEST_COMMAND_ID_TEST_OPTION_ID"
}

@test ".add_option() returns the option id" {
	hbl::command::add_option "TEST_COMMAND_ID" "test_option" option_id
	assert_equal "$option_id" "TEST_COMMAND_ID_TEST_OPTION_ID"
}

@test ".add_subcommand() when insufficient arguments are passed returns INVALID_ARGS" {
	run hbl::command::add_subcommand
	assert_failure $HBL_INVALID_ARGS
}

@test ".add_subcommand() when too many arguments are passed returns INVALID_ARGS" {
	run hbl::command::add_subcommand HBL_COMMAND_0 "subcommand" subcommand_run command_id extra
	assert_failure $HBL_INVALID_ARGS
}

@test ".add_subcommand() creates the command" {
	hbl::command::add_subcommand HBL_COMMAND_0 "subcommand" subcommand_run command_id
	assert_equal "$command_create_invoked" 1
	assert_equal ${command_create_args[0]} "subcommand"
	assert_equal ${command_create_args[1]} "subcommand_run"
	assert_equal ${command_create_args[2]} "command_id"
}

@test ".add_subcommand() sets the parent" {
	hbl::command::add_subcommand HBL_COMMAND_0 "subcommand" subcommand_run command_id
	assert_equal "${STUB_COMMAND_ID[parent]}" "HBL_COMMAND_0"
}

@test ".add_subcommand() sets the full_name" {
	hbl::command::add_subcommand HBL_COMMAND_0 "subcommand" subcommand_run command_id
	assert_equal "${STUB_COMMAND_ID[full_name]}" "test-command subcommand"
}

@test ".add_subcommand() assigns the command to the parent's subcommands" {
	declare -ag HBL_COMMAND_0_SUBCOMMANDS
	hbl::command::add_subcommand HBL_COMMAND_0 "subcommand" subcommand_run command_id
	run hbl::array::contains "HBL_COMMAND_0_SUBCOMMANDS" "STUB_COMMAND_ID"
	assert_success
}
