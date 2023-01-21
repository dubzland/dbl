setup() {
	load '../test_helper/common'
	common_setup
}

@test 'Command.new succeeds' {
	local cmd
	run $Command.new cmd foo bar
	assert_success
	refute_output
}

@test 'command.description= sets the description on the command' {
	local cmd actual expected
	expected='A simple command'
	$Command.new cmd foo bar
	${!cmd}.set_description "$expected"
	run ${!cmd}.get_description actual
	assert_success
	refute_output

	${!cmd}.get_description actual
	assert_equal "$actual" "$expected"
}

@test 'commands can have examples' {
	local cmd
	local -a examples_arr

	$Command.new cmd foo bar
	run ${!cmd}.add_example 'foo -h'
	assert_success
	refute_output

	${!cmd}.add_example 'foo -h'
	${!cmd}.examples.to_array examples_arr

	assert_equal ${#examples_arr[@]} 1
	assert_equal "${examples_arr[0]}" 'foo -h'
}

@test 'commands allow options to be added' {
	local cmd opt
	local -A options_dict

	$Option.new opt verbose

	$Command.new cmd foo bar
	run ${!cmd}.add_option "$opt"
	assert_success
	refute_output

	${!cmd}.add_option "$opt"
	${!cmd}.options.to_associative_array options_dict

	assert_equal ${#options_dict[@]} 1
	assert_equal "${options_dict[verbose]}" "$opt"
}

@test 'commands allow subcommands to be added' {
	local cmd sub
	local -a subcommands_arr

	$Command.new sub 'sub-command' command_exec

	$Command.new cmd foo bar
	run ${!cmd}.add_subcommand "$sub"
	assert_success
	refute_output

	${!cmd}.add_subcommand "$sub"
	${!cmd}.subcommands.to_array subcommands_arr

	assert_equal ${#subcommands_arr[@]} 1
	assert_equal "${subcommands_arr[0]}" "$sub"
}
