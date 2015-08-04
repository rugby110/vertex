#!/usr/bin/env bash
# default environment variables go here
# local environment variable overrides go in conf/environment_variables.local.sh
# see https://confluence.kiva.org/display/BRAIN/Vertex+Developer+Setup for details on setting up a tunnel
#  from a dev vm to Vertica

export vertex_vertica_database=verse
export vertex_vertica_reference_schema=verse
export vertex_vertica_vertex_schema=vertex
export vertex_vertica_odbc_dsn=vertex_dev
export vertex_vertica_host=localhost
export vertex_vertica_port=3322
export vertex_vertica_user=override_me
export vertex_vertica_password=override_me
# the target schema will be '<username>_sandbox' for developers and 'vertex' for dev and production
export vertex_vertica_target_schema=override_me

# get the directory where this script and the override script are
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# use the environment_variables.local.sh file to override vertex_vertica_user, password and any other variables above
if [[ -f $DIR/environment_variables.local.sh ]]; then
	source $DIR/environment_variables.local.sh
else
	echo "You probably want to set some variables in ${DIR}/environment_variables.local.sh"
fi

# the VSQL variable should not need overrides since they are defined in terms of vertex_vertica variables
export VSQL_DATABASE=$vertex_vertica_database
export VSQL_HOST=$vertex_vertica_host
export VSQL_PORT=$vertex_vertica_port
export VSQL_USER=$vertex_vertica_user
export VSQL_PASSWORD=$vertex_vertica_password

# make sure a directory containing vsql is in the path
# /opt/vertica/bin is the standard location
# /usr/local/bin is the existing location used at Kiva so far
export PATH=$PATH:/opt/vertica/bin:/usr/local/bin
