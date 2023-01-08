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

	function ensure_command() {
		hbl::command::ensure_command "$@"
	}
}

#
# hbl::command::add_example()
#
@test ".add_example() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::command::add_example
	assert_failure $HBL_ERR_INVOCATION
}

@test ".add_example() with too many arguments exits with ERR_INVOCATION" {
	run hbl::command::add_example "TEST_COMMAND" "example" "extra"
	assert_failure $HBL_ERR_INVOCATION
}

@test ".add_example() with an empty command id exits with ERR_ARGUMENT" {
	run hbl::command::add_example "" "example"
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".add_example() with an empty example exits with ERR_ARGUMENT" {
	run hbl::command::add_example "TEST_COMMAND" ""
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".add_example() with an undefined command exits with ERR_UNDEFINED" {
	run hbl::command::add_example "INVALID_COMMAND" "example"
	assert_failure $HBL_ERR_UNDEFINED
}

@test ".add_example() with a non-command argument exits with ERR_INVALID_COMMAND" {
	declare -a INVALID_COMMAND
	run hbl::command::add_example "INVALID_COMMAND" "example"
	assert_failure $HBL_ERR_INVALID_COMMAND
}

@test ".add_example() assigns the example to the command" {
	hbl::command::add_example "TEST_COMMAND" "example"
	hbl::array::contains "TEST_COMMAND_EXAMPLES" "example"
}

#
# hbl::command::add_option()
#
@test ".add_option() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::command::add_option
	assert_failure $HBL_ERR_INVOCATION
}

@test ".add_option() with too many arguments exits with ERR_INVOCATION" {
	run hbl::command::add_option "TEST_COMMAND" "test_option" "option_id" "extra"
	assert_failure $HBL_ERR_INVOCATION
}

@test ".add_option() with an empty command id exits with ERR_ARGUMENT" {
	run hbl::command::add_option "" "test_option" "option_id"
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".add_option() with an empty option_name exits with ERR_ARGUMENT" {
	run hbl::command::add_option "TEST_COMMAND" "" "option_id"
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".add_option() with an empty option_id_var exits with ERR_ARGUMENT" {
	run hbl::command::add_option "TEST_COMMAND" "test_option" ""
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".add_option() with an undefined command exits with ERR_UNDEFINED" {
	run hbl::command::add_option "INVALID_COMMAND" "test_option" "option_id"
	assert_failure $HBL_ERR_UNDEFINED
}

@test ".add_option() with a non-command argument exits with ERR_INVALID_COMMAND" {
	declare -a INVALID_COMMAND
	run hbl::command::add_option "INVALID_COMMAND" "test_option" "option_id"
	assert_failure $HBL_ERR_INVALID_COMMAND
}

@test ".add_option() creates the option" {
	hbl::command::add_option "TEST_COMMAND" "test_option" "option_id"
	assert_equal $option_create_invoked 1
}

@test ".add_option() passes the proper arguments to option::create()" {
	hbl::command::add_option "TEST_COMMAND" "test_option" "option_id"
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

#
# hbl::command::add_subcommand()
#
@test ".add_subcommand() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::command::add_subcommand
	assert_failure $HBL_ERR_INVOCATION
}

@test ".add_subcommand() with too many arguments exits with ERR_INVOCATION" {
	run hbl::command::add_subcommand "TEST_COMMAND" "subcommand" \
		"subcommand_run" "command_id" "extra"
	assert_failure $HBL_ERR_INVOCATION
}

@test ".add_subcommand() with an empty parent id exits with ERR_ARGUMENT" {
	run hbl::command::add_subcommand "" "subcommand" "subcommand_run" \
		"command_id"
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".add_subcommand() with an empty subcommand name exits with ERR_ARGUMENT" {
	run hbl::command::add_subcommand "TEST_COMMAND" "" "subcommand_run" \
		"command_id"
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".add_subcommand() with an empty entrypoint exits with ERR_ARGUMENT" {
	run hbl::command::add_subcommand "TEST_COMMAND" "subcommand" "" "command_id"
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".add_subcommand() with an empty subcommand_id_var exits with ERR_ARGUMENT" {
	run hbl::command::add_subcommand "TEST_COMMAND" "subcommand" \
		"subcommand_run" ""
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".add_subcommand() with an undefined command exits with ERR_UNDEFINED" {
	run hbl::command::add_subcommand "UNDEFINED_COMMAND" "subcommand" \
		"subcommand_run" "command_id"
	assert_failure $HBL_ERR_UNDEFINED
}

@test ".add_subcommand() with a non-command argument exits with ERR_INVALID_COMMAND" {
	declare -a NON_COMMAND
	run hbl::command::add_subcommand "NON_COMMAND" "subcommand" \
		"subcommand_run" "command_id"
	assert_failure $HBL_ERR_INVALID_COMMAND
}

@test ".add_subcommand() creates the command" {
	hbl::command::add_subcommand "TEST_COMMAND" "subcommand" \
		"subcommand_run" "subcommand_id"
	assert_equal "$command_create_invoked" 1
	assert_equal ${command_create_args[0]} "subcommand"
	assert_equal ${command_create_args[1]} "subcommand_run"
	assert_equal ${command_create_args[2]} "subcommand_id"
}

@test ".add_subcommand() sets the parent" {
	hbl::command::add_subcommand "TEST_COMMAND" "subcommand" \
		"subcommand_run" "subcommand_id"
	assert_equal "${STUB_COMMAND_ID[parent]}" "TEST_COMMAND"
}

@test ".add_subcommand() sets the full_name" {
	hbl::command::add_subcommand "TEST_COMMAND" "subcommand" \
		"subcommand_run" "command_id"
	assert_equal "${STUB_COMMAND_ID[full_name]}" "test-command subcommand"
}

@test ".add_subcommand() assigns the command to the parent's subcommands" {
	declare -ag TEST_COMMAND_SUBCOMMANDS
	hbl::command::add_subcommand "TEST_COMMAND" "subcommand" \
		"subcommand_run" "command_id"
	run hbl::array::contains "TEST_COMMAND_SUBCOMMANDS" "STUB_COMMAND_ID"
	assert_success
}

#
# hbl::command::set_description()
#
@test ".set_description() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::command::set_description
	assert_failure $HBL_ERR_INVOCATION
}

@test ".set_description() with too many arguments exits with ERR_INVOCATION" {
	run hbl::command::set_description "TEST_COMMAND" "test description" "extra"
	assert_failure $HBL_ERR_INVOCATION
}

@test ".set_description() with an empty command id exits with ERR_ARGUMENT" {
	run hbl::command::set_description "" "test description"
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".set_description() with an empty description exits with ERR_ARGUMENT" {
	run hbl::command::set_description "TEST_COMMAND" ""
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".set_description() with an undefined command exits with ERR_UNDEFINED" {
	run hbl::command::set_description "INVALID_COMMAND" "test description"
	assert_failure $HBL_ERR_UNDEFINED
}

@test ".set_description() with a non-command argument exits with ERR_INVALID_COMMAND" {
	declare -a INVALID_COMMAND
	run hbl::command::set_description "INVALID_COMMAND" "test description"
	assert_failure $HBL_ERR_INVALID_COMMAND
}

@test ".set_description() sets the description" {
	hbl::command::set_description "TEST_COMMAND" "test description"
	assert_equal "${TEST_COMMAND[desc]}" "test description"
}

#
# hbl::command::ensure_command()
#
@test ".ensure_command() with no arguments exits with ERR_INVOCATION" {
	run ensure_command
	assert_failure $HBL_ERR_INVOCATION
	assert_output "hbl::command::ensure_command: invalid arguments -- ''"
}

@test ".ensure_command() with more than one argument returns ERR_INVOCATION" {
	run ensure_command "command" "extra"
	assert_failure $HBL_ERR_INVOCATION
	assert_output "hbl::command::ensure_command: invalid arguments -- 'command extra'"
}

@test ".ensure_command() with an empty command id exits with ERR_ARGUMENT" {
	run ensure_command ""
	assert_failure $HBL_ERR_ARGUMENT
	assert_output "hbl::command::ensure_command: invalid argument for 'command_id' -- ''"
}

@test ".ensure_command() with an undefined command returns ERR_UNDEFINED" {
	run ensure_command "command"
	assert_failure $HBL_ERR_UNDEFINED
	assert_output "ensure_command: variable is undefined -- 'command'"
}

@test ".ensure_command() with a non-dict variable returns ERR_INVALID_COMMAND" {
	declare -a command_id
	run ensure_command "command_id"
	assert_failure $HBL_ERR_INVALID_COMMAND
	assert_output "ensure_command: invalid command id -- 'command_id'"
}

@test ".ensure_command() with a valid dict succeeds" {
	declare -A command_id
	run ensure_command "command_id"
	assert_success
	refute_output
}
