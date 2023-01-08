setup() {
	load 'test_helper/common'
	load 'test_helper/command'
	common_setup
	hbl::init
	hbl_test::stub_command_create
}

@test ".add_command() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::add_command
	assert_failure $HBL_ERR_INVOCATION
	assert_output "hbl::add_command: invalid arguments -- ''"
}

@test ".add_command() with too many arguments exits with ERR_INVOCATION" {
	run hbl::add_command "command" "command_run" "command_id" "extra"
	assert_failure $HBL_ERR_INVOCATION
	assert_output "hbl::add_command: invalid arguments -- 'command command_run command_id extra'"
}

@test ".add_command() with an empty command name exits with ERR_ARGUMENT" {
	run hbl::add_command "" "command_run" "command_id"
	assert_failure $HBL_ERR_ARGUMENT
	assert_output "hbl::add_command: invalid argument for 'name' -- ''"
}

@test ".add_command() with an empty entrypoint exits with ERR_ARGUMENT" {
	run hbl::add_command "command" "" "command_id"
	assert_failure $HBL_ERR_ARGUMENT
	assert_output "hbl::add_command: invalid argument for 'entrypoint' -- ''"
}

@test ".add_command() with an empty command_id_var exits with ERR_ARGUMENT" {
	run hbl::add_command "command" "command_run" ""
	assert_failure $HBL_ERR_ARGUMENT
	assert_output "hbl::add_command: invalid argument for 'command_id_var' -- ''"
}

@test ".add_command() creates the command" {
	hbl::add_command "command" command_run command_id
	assert_equal "$command_create_invoked" 1
	assert_equal ${command_create_args[0]} "command"
	assert_equal ${command_create_args[1]} "command_run"
	assert_equal ${command_create_args[2]} "command_id"
}
