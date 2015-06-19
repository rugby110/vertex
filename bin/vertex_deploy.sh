#!/usr/bin/env bash
# this script deploys all the vertex views to vertica
# before using it, make sure to create conf/environment_variables.local.sh (see conf/environment_variables.sh)

# get the directory where this script is
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# make sure we have the environment variables we need
source $DIR/../conf/environment_variables.sh

# run all the .sql files under vertex/src/sql
find $DIR/../src/sql -name \*.sql | while read sql_file; do
    echo "Processing file '$sql_file'"
    echo "set search_path to $vertex_vertica_target_schema;"|cat - $sql_file > /tmp/out.sql
    #cat /tmp/out.sql
    vsql -f /tmp/out.sql
done