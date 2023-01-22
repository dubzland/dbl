#!/usr/bin/env bash

common_setup() {
	TEST_ROOT="$(realpath "$(dirname "${BASH_SOURCE%/*}")")"
	load "${TEST_ROOT}/test_helper/bats-support/load"
	load "${TEST_ROOT}/test_helper/bats-assert/load"
	load "${TEST_ROOT}/test_helper/hbl-stubs/load"
	load "${TEST_ROOT}/test_helper/assertions"
	source "${TEST_ROOT}/../lib/hbl.sh"
}

function hbl_test__noop() {
	return 0
}
