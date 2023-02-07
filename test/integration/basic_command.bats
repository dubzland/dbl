#!/usr/bin/env bats

setup() {
  load '../test_helper/common'
  common_setup

  $Command.extend BackupCommand
  $BackupCommand.prototype_method __init BackupCommand__init
}

function BackupCommand__init() {
  $this.super           'backup-client' || return

  $this.set_description 'Manage backup jobs.'      || return
  $this.examples.push   '-d /etc/jobs.d <options>' || return

  $Command__Option.new opt 'job_directory'     || return
  $opt.set_type        'dir'                   || return
  $opt.set_short_flag  'd'                     || return
  $opt.set_long_flag   'job_directory'         || return
  $opt.set_description 'Backup job directory.' || return
  $opt.assign_reference command "$this"        || return

  $this.options.set 'job_directory' "$opt"
}

function create_basic_command() {
  $BackupCommand.new $1
}

@test 'Creating a basic command' {
  local cmd
  run create_basic_command cmd
  assert_success
  refute_output
}

@test 'Showing basic command usage' {
  local cmd
  create_basic_command cmd
  run $cmd.usage
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
