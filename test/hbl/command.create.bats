setup() {
	load '../test_helper/common'
	load '../test_helper/command'
	common_setup
	hbl::init
	hbl::command::init
}

#
# hbl::command::create()
#
@test ".create() with insufficient arguments exits with ERR_INVOCATION" {
	run hbl::command::create
	assert_failure $HBL_ERR_INVOCATION
}

@test ".create() with too many arguments exits with ERR_INVOCATION" {
	run hbl::command::create "test-command" "test_command_run" "command_id" "extra"
	assert_failure $HBL_ERR_INVOCATION
}

@test ".create() with an empty command name exits with ERR_ARGUMENT" {
	run hbl::command::create "" "test_command_run" "command_id"
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".create() with an empty entrypoint exits with ERR_ARGUMENT" {
	run hbl::command::create "test-command" "" "command_id"
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".create() with an empty subcommand_id_var exits with ERR_ARGUMENT" {
	run hbl::command::create "test-command" "test_command_run" ""
	assert_failure $HBL_ERR_ARGUMENT
}

@test ".create() creates the global command dict" {
	hbl::command::create "test-command" "test_command_run" "command_id"
	hbl::util::is_dict HBL_COMMAND_0
}

@test ".create() returns the id to caller" {
	hbl::command::create "test-command" "test_command_run" "command_id"
	assert_equal "${command_id}" "HBL_COMMAND_0"
}

@test ".create() sets the proper id" {
	hbl::command::create "test-command" "test_command_run" "command_id"
	assert_equal "${HBL_COMMAND_0[id]}" "HBL_COMMAND_0"
}

@test ".create() sets an empty parent" {
	hbl::command::create "test-command" "test_command_run" "command_id"
	run hbl::dict::has_key "HBL_COMMAND_0" "parent"
	assert_success
	assert_equal "${HBL_COMMAND_0[parent]}" ""
}

@test ".create() sets the name" {
	hbl::command::create "test-command" "test_command_run" "command_id"
	run hbl::dict::has_key "HBL_COMMAND_0" "name"
	assert_success
	assert_equal "${HBL_COMMAND_0[name]}" "test-command"
}

@test ".create() sets the entrypoint" {
	hbl::command::create "test-command" "test_command_run" "command_id"
	run hbl::dict::has_key "HBL_COMMAND_0" "entrypoint"
	assert_success
	assert_equal "${HBL_COMMAND_0[entrypoint]}" "test_command_run"
}

@test ".create() assigns to the global HBL_COMMANDS array" {
	declare -ag HBL_COMMANDS
	hbl::command::create "test-command" "test_command_run" "command_id"
	run hbl::array::contains HBL_COMMANDS "HBL_COMMAND_0"
	assert_success
}

@test ".create() with an existing command sets the proper id" {
	HBL_COMMANDS+=("HBL_COMMAND_0")
	hbl::command::create "test-command" "test_command_run" "command_id"
	assert_equal "$command_id" "HBL_COMMAND_1"
}
