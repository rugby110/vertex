#!/bin/bash
#
# local_deploy.sh
#
# Description:  Deploy the vertex app from a local checkout.

script_dir=$(dirname $0)
source $script_dir/bamboo_functions.sh

# Main
begin ": vertex deployment"

# Run composer
run_composer

# Run migrations
run_mpm_migrations

# Apply all the Views from src/sql
run_ddl

exit 0