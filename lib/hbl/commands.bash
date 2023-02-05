#!/usr/bin/env bash

# shellcheck source=lib/hbl/commands/command.bash
source "${BASH_SOURCE%/*}/commands/command.bash" &&
# shellcheck source=lib/hbl/command/option.bash
source "${BASH_SOURCE%/*}/commands/command/option.bash"  || exit

################################################################################
# Command
################################################################################
declare -Agr __hbl__Command__prototype__methods=(
  [__init]=__hbl__Command__init
  [add_example]=__hbl__Command__add_example
  [add_option]=__hbl__Command__add_option
  [add_subcommand]=__hbl__Command__add_subcommand
)

declare -Agr __hbl__Command__prototype__attributes=(
  [name]=$__hbl__attr__both
  [entrypoint]=$__hbl__attr__both
  [description]=$__hbl__attr__both
)

declare -Agr __hbl__Command__prototype__references=(
  [examples]="Array"
  [options]="Dict"
  [subcommands]="Array"
)

declare -Agr __hbl__Command__prototype=(
  [__methods__]=__hbl__Command__prototype__methods
  [__attributes__]=__hbl__Command__prototype__attributes
  [__references__]=__hbl__Command__prototype__references
)

declare -A __hbl__Command__classdef=(
  [prototype]=__hbl__Command__prototype
)

$Object.extend Command __hbl__Command__classdef || exit
# __hbl__Class__extend Object Command __hbl__Command__classdef || exit

unset __hbl__Command__classdef

################################################################################
# Command__Option
################################################################################
declare -Agr __hbl__Command__Option__prototype__methods=(
  [__init]=__hbl__Command__Option__init
)

declare -Agr __hbl__Command__Option__prototype__attributes=(
  [name]=$__hbl__attr__both
  [type]=$__hbl__attr__both
  [short_flag]=$__hbl__attr__both
  [long_flag]=$__hbl__attr__both
  [description]=$__hbl__attr__both
)

declare -Agr __hbl__Command__Option__prototype__references=(
  [command]=Command
)

declare -Agr __hbl__Command__Option__prototype=(
  [__methods__]=__hbl__Command__Option__prototype__methods
  [__attributes__]=__hbl__Command__Option__prototype__attributes
  [__references__]=__hbl__Command__Option__prototype__references
)

declare -A __hbl__Command__Option__classdef=(
  [prototype]=__hbl__Command__Option__prototype
)

$Object.extend Command__Option __hbl__Command__Option__classdef || exit
# __hbl__Class__extend Object Command__Option __hbl__Command__Option__classdef || exit

unset __hbl__Command__Option__classdef

# vim: ts=2:sw=2:expandtab
