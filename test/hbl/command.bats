setup() {
	load '../test_helper/common'
	load '../test_helper/command'
	common_setup
	hbl::init
	hbl::command::init

	declare -Ag TEST_COMMAND
	TEST_COMMAND=([name]="test-command" [entrypoint]="test_command::run")

	declare -Ag TEST_COMMAND_OPTION
	TEST_COMMAND_OPTION=()

	declare -a option_create_args
	option_create_args=()
	option_create_invoked=0
	function hbl::command::option::create() {
		option_create_invoked=1
		option_create_args=("$@")
		local -n option_id__ref="$3"
		option_id__ref="TEST_COMMAND_OPTION"
		return 0
	}

	HBL_COMMANDS=(TEST_COMMAND)
	hbl_test::stub_command_create
}

@test ".add_example() when insufficient arguments are passed returns INVALID_ARGS" {
	run hbl::command::add_example
	assert_failure $HBL_INVALID_ARGS
}

@test ".add_example() when too many arguments are passed returns INVALID_ARGS" {
	run hbl::command::add_example "TEST_COMMAND" "example" extra
	assert_failure $HBL_INVALID_ARGS
}

@test ".add_example() when the command does not exist returns INVALID_ARGS" {
	run hbl::command::add_example "INVALID_COMMAND" "example"
	assert_failure $HBL_INVALID_ARGS
}

@test ".add_example() assigns the example to the command" {
	hbl::command::add_example "TEST_COMMAND" "example"
	hbl::array::contains "TEST_COMMAND_EXAMPLES" "example"
}

@test ".add_option() when insufficient arguments are passed returns INVALID_ARGS" {
	run hbl::command::add_option
	assert_failure $HBL_INVALID_ARGS
}

@test ".add_option() when too many arguments are passed returns INVALID_ARGS" {
	run hbl::command::add_option "TEST_COMMAND" "test_option" option_id extra
	assert_failure $HBL_INVALID_ARGS
}

@test ".add_option() when the command does not exist returns INVALID_ARGS" {
	run hbl::command::add_option "INVALID_COMMAND" "test_option" option_id
	assert_failure $HBL_INVALID_ARGS
}

@test ".add_option() creates the option" {
	hbl::command::add_option "TEST_COMMAND" "test_option" option_id
	assert_equal $option_create_invoked 1
}

@test ".add_option() passes the proper arguments to option::create()" {
	hbl::command::add_option "TEST_COMMAND" "test_option" option_id
	assert_equal ${option_create_args[0]} "TEST_COMMAND"
	assert_equal ${option_create_args[1]} "test_option"
	assert_equal ${option_create_args[2]} "option_id"
}

@test ".add_option() assigns the option to the command" {
	hbl::command::add_option "TEST_COMMAND" "test_option" option_id
	hbl::dict::get "TEST_COMMAND_OPTIONS" "test_option" opt
	assert_equal "${opt}" "TEST_COMMAND_OPTION"
}

@test ".add_option() returns the option id" {
	hbl::command::add_option "TEST_COMMAND" "test_option" option_id
	assert_equal "$option_id" "TEST_COMMAND_OPTION"
}

@test ".add_subcommand() when insufficient arguments are passed returns INVALID_ARGS" {
	run hbl::command::add_subcommand
	assert_failure $HBL_INVALID_ARGS
}

@test ".add_subcommand() when too many arguments are passed returns INVALID_ARGS" {
	run hbl::command::add_subcommand "TEST_COMMAND" "subcommand" subcommand_run command_id extra
	assert_failure $HBL_INVALID_ARGS
}

@test ".add_subcommand() when the command does not exist returns INVALID_ARGS" {
	run hbl::command::add_subcommand "INVALID_COMMAND" "subcommand" subcommand_run command_id
	assert_failure $HBL_INVALID_ARGS
}

@test ".add_subcommand() creates the command" {
	hbl::command::add_subcommand TEST_COMMAND "subcommand" subcommand_run command_id
	assert_equal "$command_create_invoked" 1
	assert_equal ${command_create_args[0]} "subcommand"
	assert_equal ${command_create_args[1]} "subcommand_run"
	assert_equal ${command_create_args[2]} "command_id"
}

@test ".add_subcommand() sets the parent" {
	hbl::command::add_subcommand TEST_COMMAND "subcommand" subcommand_run command_id
	assert_equal "${STUB_COMMAND_ID[parent]}" "TEST_COMMAND"
}

@test ".add_subcommand() sets the full_name" {
	hbl::command::add_subcommand TEST_COMMAND "subcommand" subcommand_run command_id
	assert_equal "${STUB_COMMAND_ID[full_name]}" "test-command subcommand"
}

@test ".add_subcommand() assigns the command to the parent's subcommands" {
	declare -ag TEST_COMMAND_SUBCOMMANDS
	hbl::command::add_subcommand TEST_COMMAND "subcommand" subcommand_run command_id
	run hbl::array::contains "TEST_COMMAND_SUBCOMMANDS" "STUB_COMMAND_ID"
	assert_success
}

@test ".set_description() when insufficient arguments are passed returns INVALID_ARGS" {
	run hbl::command::set_description
	assert_failure $HBL_INVALID_ARGS
}

@test ".set_description() when too many arguments are passed returns INVALID_ARGS" {
	run hbl::command::set_description "TEST_COMMAND" "description" extra
	assert_failure $HBL_INVALID_ARGS
}

@test ".set_description() when the command does not exist returns INVALID_ARGS" {
	run hbl::command::set_description "INVALID_COMMAND" "description"
	assert_failure $HBL_INVALID_ARGS
}

@test ".set_description() sets the description" {
	hbl::command::set_description TEST_COMMAND "command description"
	assert_equal "${TEST_COMMAND[desc]}" "command description"
}
