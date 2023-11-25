#!/usr/bin/env bash

# HBL_INDENT=${HBL_INDENT:-"  "}
# readonly HBL_INDENT

# function dbl__command__usage__show() {
#   [[ $# -eq 1 ]] || dbl__error__invocation "$@" || exit
#   [[ -n "$1" ]] || dbl__error__argument 'command_id' "$1" || exit

#   dbl__command__ensure_command "$1" || exit

#   dbl__command__usage__examples "$1"
#   dbl__command__usage__description "$1"
#   dbl__command__usage__subcommands "$1"

#   return 0
# }

# function dbl__command__usage__examples() {
#   [[ $# -eq 1 ]] || dbl__error__invocation "$@" || exit
#   [[ -n "$1" ]]  || dbl__error__argument "command_id" "$1" || exit

#   dbl__command__ensure_command "$1" || exit

#   local command_name
#   local -a command_examples
#   command_name="" command_examples=()

#   dbl__dict__get "$1" '_fullname' command_name
#   [[ -z "$command_name" ]] && dbl__dict__get "$1" '_name' command_name

#   printf "Usage:\n"

#   if dbl__util__is_array "${1}__examples"; then
#     local -n command_examples__ref="${1}__examples"
#     if [[ ${#command_examples__ref[@]} -gt 0 ]]; then
#       for ex in "${command_examples__ref[@]}"; do
#         local example
#         printf -v example "%s %s" "$command_name" "$ex"
#         command_examples+=("$example")
#       done
#     fi
#   fi

#   if [[ ${#command_examples[@]} -gt 0 ]]; then
#     for ex in "${command_examples[@]}"; do
#       printf "%s%s\n" "$HBL_INDENT" "$ex"
#     done
#   else
#     printf "%s%s <options>\n" "$HBL_INDENT" "$command_name"
#   fi

#   printf "\n"

#   return 0
# }

# function dbl__command__usage__description() {
#   [[ $# -eq 1 ]] || dbl__error__invocation "$@" || exit
#   [[ -n "$1" ]]  || dbl__error__argument "command_id" "$1" || exit

#   dbl__command__ensure_command "$1" || exit

#   local desc

#   dbl__command__get_description "$1" 'desc'

#   if [[ -n "${desc}" ]]; then
#     printf "Description:\n"
#     printf "%s%s\n" "${HBL_INDENT}" "${desc}"
#     printf "\n"
#   fi

#   return 0
# }

# function dbl__command__usage__subcommands() {
#   [[ $# -eq 1 ]] || dbl__error__invocation "$@" || exit
#   [[ -n "$1" ]]  || dbl__error__argument "command_id" "$1" || exit

#   dbl__command__ensure_command "$1" || exit

#   local command_id command_subcommands subcommand_id subcommand_name
#   local subcommand_desc
#   local -A subcommand_dict
#   local -a subcommand_names
#   command_id="$1" subcommand_dict=() subcommand_names=()

#   command_subcommands="${command_id}__subcommands"

#   if dbl__util__is_array "$command_subcommands"; then
#     local -n command_subcommands__ref="$command_subcommands"

#     if [[ ${#command_subcommands__ref[@]} -gt 0 ]]; then
#       printf "Subcommands:\n"
#       for subcommand_id in "${command_subcommands__ref[@]}"; do
#         if dbl__util__is_dict "$subcommand_id"; then
#           dbl__dict__get "$subcommand_id" 'name' subcommand_name
#           dbl__dict__set subcommand_dict "$subcommand_name" "$subcommand_id"
#         else
#           dbl__error__undefined "${FUNCNAME[0]}" "$subcommand_id"
#           return
#         fi
#       done

#       subcommand_names=("${!subcommand_dict[@]}")
#       dbl__array__bubble_sort subcommand_names
#       for sub in "${subcommand_names[@]}"; do
#         dbl__dict__get subcommand_dict "$sub" subcommand_id
#         dbl__dict__get "$subcommand_id" 'desc' subcommand_desc
#         printf "%s%-26s%s\n" "${HBL_INDENT}" "$sub" "$subcommand_desc"
#       done
#       printf "\n"
#     fi
#   fi

#   return 0
# }

# vim: ts=2:sw=2:expandtab
