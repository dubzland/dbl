setup() {
	load '../test_helper/common'
	load '../test_helper/command'
	common_setup
	hbl::init
	hbl::command::init
}

@test ".create() creates the global command dict" {
	hbl::command::create "test-command" test_command_run command_id
	run hbl::util::is_dict? HBL_COMMAND_0
	assert_success
}

@test ".create() returns the id to caller" {
	hbl::command::create "test-command" test_command_run command_id
	assert_equal "${command_id}" "HBL_COMMAND_0"
}

@test ".create() sets the proper id" {
	hbl::command::create "test-command" test_command_run command_id
	assert_equal "${HBL_COMMAND_0[id]}" "HBL_COMMAND_0"
}

@test ".create() sets an empty parent" {
	hbl::command::create "test-command" test_command_run command_id
	run hbl::dict::has_key? "HBL_COMMAND_0" "parent"
	assert_success
	assert_equal "${HBL_COMMAND_0[parent]}" ""
}

@test ".create() sets the name" {
	hbl::command::create "test-command" test_command_run command_id
	run hbl::dict::has_key? "HBL_COMMAND_0" "name"
	assert_success
	assert_equal "${HBL_COMMAND_0[name]}" "test-command"
}

@test ".create() sets the entrypoint" {
	hbl::command::create "test-command" test_command_run command_id
	run hbl::dict::has_key? "HBL_COMMAND_0" "entrypoint"
	assert_success
	assert_equal "${HBL_COMMAND_0[entrypoint]}" "test_command_run"
}

@test ".create() assigns to the global HBL_COMMANDS array" {
	declare -ag HBL_COMMANDS
	hbl::command::create "test-command" test_command_run command_id
	run hbl::array::contains? HBL_COMMANDS "HBL_COMMAND_0"
	assert_success
}

@test ".create() with an existing command sets the proper id" {
	HBL_COMMANDS+=("HBL_COMMAND_0")
	hbl::command::create "test-command" test_command_run command_id
	assert_equal "$command_id" "HBL_COMMAND_1"
}

