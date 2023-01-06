function hbl::array::contains?() {
	if [[ $# -gt 2 ]]; then
		echo "Too many arguments to hbl::array::contains? -- $#" >&2
		return 102
	fi

	if [[ $# -lt 2 ]]; then
		echo "Not enough arguments to hbl::array::contains -- $#" >&2
		return 101
	fi

	if hbl::util::is_array? $1; then
		local -n __ref=$1
		for key in "${__ref[@]}"; do
			[[ "${key}" == "$2" ]] && return 0
		done
	else
		return 2
	fi

	return 1
}

function hbl::dict::has_key?() {
	if [[ $# -gt 2 ]]; then
		echo "Too many arguments to hbl::dict::has_key? -- $#" >&2
		return 4
	fi

	if [[ $# -lt 2 ]]; then
		echo "Not enough arguments to hbl::dict::has_key? -- $#" >&2
		return 3
	fi

	if hbl::util::is_dict? $1; then
		local -n __ref=$1
		for key in "${!__ref[@]}"; do
			[[ "${key}" == "$2" ]] && return 0
		done
	else
		return 2
	fi

	return 1
}

function hbl::dict::get() {
	if [[ $# -gt 3 ]]; then
		echo "Too many arguments to hbl::dict::get -- $#" >&2
		return 4
	fi

	if [[ $# -lt 3 ]]; then
		echo "Not enough arguments to hbl::dict::get -- $#" >&2
		return 3
	fi

	local -n __ret=$3

	if hbl::util::is_dict? $1; then
		local -n __ref=$1
		if hbl::dict::has_key? $1 $2; then
			__ret="${__ref[$2]}"
			return 0
		fi
	else
		return 2
	fi

	return 1
}
