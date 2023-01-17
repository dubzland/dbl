setup() {
	load '../test_helper/common'
	# load '../test_helper/command'
	common_setup
	# hbl__init

	# declare -a option_create_args
	# option_create_args=()
	# option_create_invoked=0
	# function hbl__command__option__create() {
	# 	option_create_invoked=1
	# 	option_create_args=("$@")
	# 	local -n option_id__ref="$3"
	# 	option_id__ref="${1}_option"
	# 	return 0
	# }

# 	hbl_test__stub_command_create

# 	function ensure_command() {
# 		hbl__command__ensure_command "$@"
# 	}

# 	function stub_private() {
# 		function hbl__command__add_example_() { printf "add_example_: [$*]\n"; }
# 		function hbl__command__add_option_() { printf "add_option_: [$*]\n"; }
# 		function hbl__command__add_subcommand_() { printf "add_subcommand_: [$*]\n"; }
# 		function hbl__command__get_description_() { printf "get_description_: [$*]\n"; }
# 		function hbl__command__set_description_() { printf "set_description_: [$*]\n"; }
# 	}
}

@test 'Command:new succeeds' {
	local cmd
	run $Command:new cmd foo bar
	assert_success
	refute_output
}

@test 'commands can have descriptions' {
	local cmd actual expected
	expected='A simple command'
	$Command:new cmd foo bar
	$cmd.description= "$expected"
	run $cmd.description actual
	assert_success
	refute_output

	$cmd.description actual
	assert_equal "$actual" "$expected"
}

@test 'commands can have examples' {
	local cmd examples
	local -a examples_arr

	$Command:new cmd foo bar
	run $cmd:add_example 'foo -h'
	assert_success
	refute_output

	$cmd:add_example 'foo -h'
	$cmd.examples examples
	$examples:to_array examples_arr
	assert_equal ${#examples_arr[@]} 1
	assert_equal "${examples_arr[0]}" 'foo -h'
}

@test 'commands allow options to be added' {
	local cmd opt options
	local -A options_dict

	$Option:new opt verbose

	$Command:new cmd foo bar
	run $cmd:add_option "$opt"
	assert_success
	refute_output

	$cmd:add_option "$opt"
	$cmd.options options
	$options:to_dict options_dict

	assert_equal ${#options_dict[@]} 1
	assert_equal "${options_dict[verbose]}" "$opt"
}

@test 'commands allow subcommands to be added' {
	local cmd sub subcommands
	local -a subcommands_arr

	$Command:new sub 'sub-command' command_exec

	$Command:new cmd foo bar
	run $cmd:add_subcommand "$sub"
	assert_success
	refute_output

	$cmd:add_subcommand "$sub"
	$cmd.subcommands subcommands
	$subcommands:to_array subcommands_arr

	assert_equal ${#subcommands_arr[@]} 1
	assert_equal "${subcommands_arr[0]}" "$sub"
}
