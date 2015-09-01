#!/bin/bash
#
# bamboo_build.sh
#
# Description:  Build the vertex micro service with bamboo.

usage() {
  cat <<EOF
"$0: -p buildPlanName"
        -p      String as assigned to bamboo_buildPlanName
EOF
  exit 1
}

# defaults
build_plan_name="testproject - testplan - testbranch - testjob"
bamboo_stage="BUILD_STAGE: init"
# cli argument processing
while getopts "p:" opt; do
  case ${opt} in
    p  ) build_plan_name="$OPTARG" ;;
    \? ) usage ;;
    *  ) usage ;;
  esac
done

#source functions and change to the root of the codebase
script_dir="$(dirname $0)"
for bamboo_function in $script_dir/bamboo_functions/*.sh; do
  source $bamboo_function
done
cd $script_dir/..
base_dir="$(pwd)"

# traps, shell settings
trap exit_handler EXIT
trap "exit 12" INT
set -e

# Extract useful information from bamboo about this run
job_name=$(parse_build_plan_name -p "$build_plan_name" -i job_name)
branch_name=$(parse_build_plan_name -p "$build_plan_name" -i branch_name)
plan_name=$(parse_build_plan_name -p "$build_plan_name" -i plan_name)
project_name=$(parse_build_plan_name -p "$build_plan_name" -i project_name)
echo "job_name=\"$job_name\""
echo "branch_name=\"$branch_name\""
echo "plan_name=\"$plan_name\""
echo "project_name=\"$project_name\""

# Main
echo "For information on build stages, please see: "
echo "  https://confluence.kiva.org/display/TO/Deployment+Stages"
echo
bamboo_stage="BUILD STAGE: compile"
echo $bamboo_stage
compile

bamboo_stage="BUILD STAGE: build w/o config"
echo $bamboo_stage
build_without_config

bamboo_stage="BUILD STAGE: build w/ global config"
echo $bamboo_stage
generate_global_config
build_w_global_config

bamboo_stage="PACKAGING: generate artifacts"
echo $bamboo_stage
generate_artifacts -p "$plan_name"

exit 0
