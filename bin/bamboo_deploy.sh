#!/bin/bash
#
# bamboo_deploy.sh
#
# Description:  Deploy with bamboo.

usage() {
  cat <<EOF
"$0: [-e deploy_environment] [-p planName]"
        -e      String as assigned to bamboo_deploy_environment ie:dev
        -p      String as assigned to bamboo_planName
EOF
  exit 1
}

# defaults
deployment_environment="dev-vm"
build_plan_name="testproject - testplan - testbranch"
bamboo_stage="DEPLOYMENT STAGE: init"
# cli argument processing
while getopts "e:p:" opt; do
  case ${opt} in
    e  ) deployment_environment="$OPTARG" ;;
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
echo "deployment_environment=\"$deployment_environment\""

# Main
echo "For information on deployment stages, please see: "
echo "  https://confluence.kiva.org/display/TO/Deployment+Stages"
echo
bamboo_stage="DEPLOYMENT STAGE: build w/ environment config"
echo $bamboo_stage
generate_environment_config -e "$deployment_environment"
build_w_environment_config -e "$deployment_environment"

bamboo_stage="DEPOLYMENT STAGE: build w/ run-time services"
echo $bamboo_stage
build_w_runtime_services

bamboo_stage="DEPLOYMENT STAGE: copy code/packages to nodes"
echo $bamboo_stage
copy_code_to_nodes

bamboo_stage="DEPLOYMENT STAGE: pre-deploy"
echo $bamboo_stage
pre_deploy

bamboo_stage="DEPLOYMENT STAGE: deploy"
echo $bamboo_stage
deploy

bamboo_stage="DEPLOYMENT STAGE: post-deploy"
echo $bamboo_stage
post_deploy

exit 0
