#!/usr/bin/env bash
# default environment variables go here
# local environment variable overrides go in conf/environment_variables.local.sh
# see https://confluence.kiva.org/display/BRAIN/Vertex+Developer+Setup for details on setting up a tunnel
#  from a dev vm to Vertica

vertex_vertica_database=verse
vertex_vertica_host=localhost
vertex_vertica_port=3322
vertex_vertica_user=override_me
vertex_vertica_password=override_me
# the target schema will be '<username>_sandbox' for developers and 'vertex' for dev and production
vertex_vertica_target_schema=override_me

# get the directory where this script and the override script are
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# use the environment_variables.local.sh file to override vertex_vertica_user, password and any other variables above
source $DIR/environment_variables.local.sh

# the VSQL variable should not need overrides since they are defined in terms of vertex_vertica variables
export VSQL_DATABASE=$vertex_vertica_database
export VSQL_HOST=$vertex_vertica_host
export VSQL_PORT=$vertex_vertica_port
export VSQL_USER=$vertex_vertica_user
export VSQL_PASSWORD=$vertex_vertica_password


