#!/usr/bin/env bats

setup() {
  load '../test_helper/common'
  common_setup
}

function create_basic_command() {
  local _cmd cmd_var opt
  cmd_var="$1"
  local -n cmd_var__ref="$cmd_var"

  $Command.new _cmd 'backup-client' backup_client_run

  ${!_cmd}.set_description 'Manage backup jobs.'
  ${!_cmd}.add_example     '-d /etc/jobs.d <options>'

  $Option.new opt 'job_directory'
  ${!opt}.set_type        'dir'
  ${!opt}.set_short_flag  'd'
  ${!opt}.set_long_flag   'job_directory'
  ${!opt}.set_description 'Backup job directory.'

  ${!_cmd}.add_option "$opt"
  cmd_var__ref="$_cmd"
  return 0
}

@test 'Creating a basic command' {
  local cmd
  run create_basic_command cmd
  assert_success
  refute_output
}

@test 'Showing basic command usage' {
  TRACE=1
  local cmd
  create_basic_command cmd
  run $cmd:show_usage
  assert_success
  assert_output - <<-EOF
Usage:
  backup-client -d /etc/jobs.d <options>

Description:
  Manage backup jobs.

General Options:
  -h, --help                Show help.
  -d, --job-directory <dir> Backup job directory.
EOF

}

# vim: ts=2:sw=2:expandtab
