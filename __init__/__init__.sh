#!/bin/bash

# Script can be ONLY included by "source" command.
[[ -n "$BASH" && (-z "$BASH_LINENO" || BASH_LINENO[0] -gt 0) && (-z "$CONTOOLS_PROJECT_ROOT_INIT0_DIR" || "$CONTOOLS_PROJECT_ROOT_INIT0_DIR" != "$CONTOOLS_PROJECT_ROOT") ]] || return 0 || exit 0 # exit to avoid continue if the return can not be called

if [[ -z "$SOURCE_TACKLELIB_BASH_TACKLELIB_SH" || SOURCE_TACKLELIB_BASH_TACKLELIB_SH -eq 0 ]]; then
  # builtin search
  for BASH_SOURCE_DIR in '/usr/local/bin' '/usr/bin' '/bin'; do
    if [[ -f "$BASH_SOURCE_DIR/bash_tacklelib" ]]; then
      source "$BASH_SOURCE_DIR/bash_tacklelib" || exit $?
      break
    fi
  done
fi

tkl_cast_to_int NEST_LVL

[[ -z "${NO_GEN+x}" ]] || tkl_cast_to_int NO_GEN
[[ -z "${NO_LOG+x}" ]] || tkl_cast_to_int NO_LOG
[[ -z "${NO_LOG_OUTPUT+x}" ]] || tkl_cast_to_int NO_OUTPUT

[[ -n "$CONTOOLS_PROJECT_ROOT" ]] ||                tkl_export_path -a -s CONTOOLS_OLD_PROJECT_ROOT               "$BASH_SOURCE_DIR/.."
[[ -n "$CONTOOLS_PROJECT_EXTERNALS_ROOT" ]] ||      tkl_export_path -a -s CONTOOLS_OLD_PROJECT_EXTERNALS_ROOT     "$CONTOOLS_OLD_PROJECT_ROOT/_externals"

if [[ ! -d "$CONTOOLS_OLD_PROJECT_EXTERNALS_ROOT" ]]; then
  echo "$0: error: CONTOOLS_OLD_PROJECT_EXTERNALS_ROOT directory does not exist: \`$CONTOOLS_OLD_PROJECT_EXTERNALS_ROOT\`." >&2
  tkl_abort
fi

[[ -n "$PROJECT_OUTPUT_ROOT" ]] ||                  tkl_export_path -a -s PROJECT_OUTPUT_ROOT                 "$CONTOOLS_OLD_PROJECT_ROOT/_out"
[[ -n "$PROJECT_LOG_ROOT" ]] ||                     tkl_export_path -a -s PROJECT_LOG_ROOT                    "$CONTOOLS_OLD_PROJECT_ROOT/.log"

[[ -n "$CONTOOLS_OLD_PROJECT_INPUT_CONFIG_ROOT" ]] ||   tkl_export_path -a -s CONTOOLS_OLD_PROJECT_INPUT_CONFIG_ROOT  "$CONTOOLS_OLD_PROJECT_ROOT/_config"
[[ -n "$CONTOOLS_OLD_PROJECT_OUTPUT_CONFIG_ROOT" ]] ||  tkl_export_path -a -s CONTOOLS_OLD_PROJECT_OUTPUT_CONFIG_ROOT "$PROJECT_OUTPUT_ROOT/config/contools.old"

# retarget externals of an external project

[[ -n "$CONTOOLS_PROJECT_EXTERNALS_ROOT" ]] ||      tkl_export_path -a -s CONTOOLS_PROJECT_EXTERNALS_ROOT     "$CONTOOLS_OLD_PROJECT_EXTERNALS_ROOT"
[[ -n "$TACKLELIB_PROJECT_EXTERNALS_ROOT" ]] ||     tkl_export_path -a -s TACKLELIB_PROJECT_EXTERNALS_ROOT    "$CONTOOLS_OLD_PROJECT_EXTERNALS_ROOT"

# config loader must be included before any external project init and using init variables (declared here and not by the config)

if [[ -z "$SOURCE_TACKLELIB_TOOLS_LOAD_CONFIG_SH" || SOURCE_TACKLELIB_TOOLS_LOAD_CONFIG_SH -eq 0 ]]; then # check inclusion guard
  tkl_include_or_abort "$CONTOOLS_OLD_PROJECT_EXTERNALS_ROOT/tacklelib/bash/tacklelib/tools/load_config.sh"
fi

if (( ! NO_GEN )); then
  [[ -e "$CONTOOLS_OLD_PROJECT_OUTPUT_CONFIG_ROOT" ]] || mkdir -p "$CONTOOLS_OLD_PROJECT_OUTPUT_CONFIG_ROOT" || tkl_abort
fi

[[ -n "$LOAD_CONFIG_VERBOSE" ]] || (( ! INIT_VERBOSE )) || tkl_export_path LOAD_CONFIG_VERBOSE 1

if (( ! NO_GEN )); then
  tkl_load_config_dir --gen-user-config --expand-all-configs-bat-vars -- "$CONTOOLS_OLD_PROJECT_INPUT_CONFIG_ROOT" "$CONTOOLS_OLD_PROJECT_OUTPUT_CONFIG_ROOT" || tkl_abort
else
  tkl_load_config_dir --expand-all-configs-bat-vars -- "$CONTOOLS_OLD_PROJECT_INPUT_CONFIG_ROOT" "$CONTOOLS_OLD_PROJECT_OUTPUT_CONFIG_ROOT" || tkl_abort
fi

# init external projects

if [[ -f "$CONTOOLS_OLD_PROJECT_EXTERNALS_ROOT/contools/__init__/__init__.sh" ]]; then
  tkl_include_or_abort "$CONTOOLS_OLD_PROJECT_EXTERNALS_ROOT/contools/__init__/__init__.sh"
fi

if [[ -f "$CONTOOLS_OLD_PROJECT_EXTERNALS_ROOT/tacklelib/__init__/__init__.sh" ]]; then
  tkl_include_or_abort "$CONTOOLS_OLD_PROJECT_EXTERNALS_ROOT/tacklelib/__init__/__init__.sh"
fi

tkl_include_or_abort "$TACKLELIB_BASH_ROOT/tacklelib/buildlib.sh"

if (( ! NO_GEN )); then
  [[ -e "$PROJECT_OUTPUT_ROOT" ]] || mkdir -p "$PROJECT_OUTPUT_ROOT" || tkl_abort
  [[ -e "$PROJECT_LOG_ROOT" ]] || mkdir -p "$PROJECT_LOG_ROOT" || tkl_abort
fi

tkl_export_path CONTOOLS_OLD_PROJECT_ROOT_INIT0_DIR "$CONTOOLS_OLD_PROJECT_ROOT" # including guard

: # resets exit code to 0
