#!/bin/bash
#
# bamboo_deploy.sh
#
# Description:  Deploy the vertex app from bamboo.

usage() {
  cat <<EOF
"$0: "
EOF
  exit 1
}

# defaults
# cli argument processing
#while getopts "" opt; do
#  case ${opt} in
#    \? ) usage ;;
#    *  ) usage ;;
#  esac
#done

script_dir=$(dirname $0)
source $script_dir/bamboo_functions.sh

# traps, shell settings
trap exit_handler EXIT
set -xe


# Main

begin ": vertex deployment"

# Grab any variables from environment, including secrets

# any other prep of local working dir?

# Copy code to nodes -- no-op for Vertex

# Run migrations
run_mpm_migrations

# Apply all the new Views from src/sql
run_ddl

exit 0
