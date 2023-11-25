function mock_setup() {
	declare -ag __mocks
	__mocks=()
}

function mock_teardown() {
	for mock in "${__mocks[@]}"; do
		unset $mock
	done
	__mocks=()
}

function mock_object() {
	local object_id
	object_id="$1"
	local -n object_methods__ref=$2

	declare -Ag $object_id
	local -n object__ref=$object_id

	for method in "${object_methods__ref[@]}"; do
		object__ref[$method]="dbl_test__noop"
	done
	__mocks+=($object_id)
}

declare -ag MOCK_DICT_METHODS
MOCK_DICT_METHODS=(
	set
	has_key
	get
)
readonly MOCK_DICT_METHODS

function mock_dict() {
	local dict_name
	dict_name="$1"

	mock_object $dict_name MOCK_DICT_METHODS
}

declare -ag MOCK_COMMAND_METHODS
MOCK_COMMAND_METHODS=(
	get_id
	get_parent
	get_name
	get_entrypoint
	get_description
	get_examples
	get_options
	get_subcommands
	set_id
	set_parent
	set_name
	set_entrypoint
	set_description
	add_example
	add_option
	add_subcommand
)
MOCK_COMMAND_METHODS+=("${MOCK_DICT_METHODS[@]}")
readonly MOCK_COMMAND_METHODS

function mock_command() {
	local command_name command_entrypoint command_id_var
	command_name="$1" command_entrypoint="$2" command_id_var="$3"

	local -n command_id__ref="$command_id_var"

	command_index="${#__mocks[@]}"
	command_id__ref="__dbl_command_${command_index}"
}

function dbl_test__mock_option() {
	local option_id
	option_id="$1"
	declare -Ag "$option_id"
	local -n option__ref="$option_id"
	option__ref[id]="$option_id"
	option__ref[name]='test_option'
}
