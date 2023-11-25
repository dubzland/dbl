#!/usr/bin/env bash

# shellcheck source=lib/dbl/commands/command.bash
source "${BASH_SOURCE%/*}/commands/command.bash" &&
# shellcheck source=lib/dbl/command/option.bash
source "${BASH_SOURCE%/*}/commands/command/option.bash"  || exit

################################################################################
# Command
################################################################################
declare -Agr __dbl__Command__prototype__methods=(
  [__init]=__dbl__Command__init
  [add_example]=__dbl__Command__add_example
  [add_option]=__dbl__Command__add_option
  [add_subcommand]=__dbl__Command__add_subcommand
  [usage]=__dbl__Command__usage
)

declare -Agr __dbl__Command__prototype__attributes=(
  [name]=$__dbl__attr__both
  [description]=$__dbl__attr__both
)

declare -Agr __dbl__Command__prototype__references=(
  [examples]="Array"
  [options]="Dict"
  [subcommands]="Array"
)

declare -Agr __dbl__Command__prototype=(
  [__methods__]=__dbl__Command__prototype__methods
  [__attributes__]=__dbl__Command__prototype__attributes
  [__references__]=__dbl__Command__prototype__references
)

declare -A __dbl__Command__classdef=(
  [prototype]=__dbl__Command__prototype
)

$Object.extend Command __dbl__Command__classdef || exit
# __dbl__Class__extend Object Command __dbl__Command__classdef || exit

unset __dbl__Command__classdef

################################################################################
# Command__Option
################################################################################
declare -Agr __dbl__Command__Option__prototype__methods=(
  [__init]=__dbl__Command__Option__init
)

declare -Agr __dbl__Command__Option__prototype__attributes=(
  [name]=$__dbl__attr__both
  [type]=$__dbl__attr__both
  [short_flag]=$__dbl__attr__both
  [long_flag]=$__dbl__attr__both
  [description]=$__dbl__attr__both
)

declare -Agr __dbl__Command__Option__prototype__references=(
  [command]=Command
)

declare -Agr __dbl__Command__Option__prototype=(
  [__methods__]=__dbl__Command__Option__prototype__methods
  [__attributes__]=__dbl__Command__Option__prototype__attributes
  [__references__]=__dbl__Command__Option__prototype__references
)

declare -A __dbl__Command__Option__classdef=(
  [prototype]=__dbl__Command__Option__prototype
)

$Object.extend Command__Option __dbl__Command__Option__classdef || exit
# __dbl__Class__extend Object Command__Option __dbl__Command__Option__classdef || exit

unset __dbl__Command__Option__classdef

# vim: ts=2:sw=2:expandtab
