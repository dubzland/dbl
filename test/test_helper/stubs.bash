stub_setup() {
	declare -Ag __stubbed_functions
	__stubbed_functions=()
	declare -Ag __stubbed_methods
	__stubbed_methods=()
}

stub_teardown() {
	for stub in "${!__stubbed_functions[@]}"; do
		unset "__stub_${stub}__invoked"
		unset "__stub_${stub}__args"
		unset "$stub"
		eval "${__stubs[$stub]}"
	done
	__stubbed_functions=()
	for stub in "${!__stubbed_methods[@]}"; do
	done
}

stub_invoked() {
	local function_name
	function_name="$1"

	local -n function_invoked="__stub_${function_name}__invoked"
	local -n function_args="__stub_${function_name}__args"

	function_invoked=1
	function_args=("${@:2}")
}

stub_was_invoked() {
	local function_name
	function_name=$1
	local -n stub_invoked="__stub_${function_name}__invoked"
	[[ $stub_invoked -eq 1 ]]
}

stub_function() {
	local function_name
	function_name=$1
	local -n function_invoked="__stub_${function_name}__invoked"
	function_invoked=0
	declare -ag "__stub_${function_name}__args"
	local -n function_args="__stub_${function_name}__args"
	function_args=()
	local orig
	orig="$(declare -f $function_name)"

	__stubs[$function_name]="$orig"

	if [[ $# -gt 1 ]]; then
		source /dev/stdin <<-EOF
			function ${function_name}() {
				hbl_test__stub_invoked "$function_name" "\$@";
				$2 "\$@";
			};
		EOF
	else
		source /dev/stdin <<-EOF
			function ${function_name}() {
				hbl_test__stub_invoked "$function_name" "\$@";
			};
		EOF
	fi
}

function assert_stub_invoked() {
	local function_name
	function_name="$1"
	if ! hbl_test__stub_was_invoked $function_name; then
		fail "stub not invoked: ${function_name}"
		# batslib_print_kv_single 10 'function' "${function_name}" \
		# | batslib_decorate 'stub not invoked' \
		# | fail
	fi

	local -n actual_args="__stub_${function_name}__args"
	local -a expected_args
	expected_args=("${@:2}")

	[[ ${#expected_args[@]} -gt 0 ]] || return 0

	if [[ ${#expected_args[@]} -ne ${#actual_args[@]} ]]; then
		local expected_string actual_string
		expected_string='' actual_string=''
		[[ ${#expected_args[@]} -gt 0 ]] && printf -v expected_string "'%s'," "${expected_args[@]}"
		[[ ${#actual_args[@]} -gt 0 ]] && printf -v actual_string "'%s'," "${actual_args[@]}"

		batslib_print_kv_single_or_multi 8 \
		'expected' "[${expected_string%,}]" \
		'actual'   "[${actual_string%,}]" \
		| batslib_decorate 'stub invoked with unexpected args' \
		| fail
	fi
}

