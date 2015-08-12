#!/bin/bash
#
# bamboo_functions.sh
#
# Description:  functions used by the bamboo_*.sh scripts.  Kept here
#               to make the scripts themselves more simple and more readable.

# make sure we have the environment variables we need
source ${script_dir}/../conf/environment_variables.sh

composer="php -d allow_url_fopen=1 /usr/local/bin/composer.phar"

# invoke composer
run_composer () {
	$composer validate && $composer install && $composer dump-autoload --optimize
}

# invoke mpm
run_mpm_migrations () {
	echo "TODO: mpm migrations"
}

# for all the DDL sql in src/sql, apply to vertica
run_ddl () {
	# future: take a param to only do a subset of src/sql
	echo "running DDL statements"
	which vsql || (echo "No vsql found!"; exit 1)
	find ${script_dir}/../src/sql -name \*.sql | while read sql_file; do
	    if grep --quiet VERTEX_NO_DEPLOY $sql_file; then
		echo "Skipping '$sql_file' with VERTEX_NO_DEPLOY tag"
	    else
		echo "Deploying file '$sql_file'"
		echo "set search_path to $vertex_vertica_vertex_schema;SET SESSION AUTOCOMMIT TO on;"|cat - $sql_file > /tmp/out.sql
		#cat /tmp/out.sql
		vsql -f /tmp/out.sql
	    fi
	done
}

run_permissions () {
	php ./bin/view_permission_updater.php
}

run_tests () {
	./vendor/bin/phpunit tests
}

exit_handler () {
  exit_code=$?
  set +xe
  echo "#################"
  echo "exiting"

  case $exit_code in
    0) echo "SUCCESSFUL $(basename $0)"
       ;;
    11) echo "ABORTED $(basename $0), LOCK IN PLACE"
       ;;
    *) echo "PROBLEMS WITH DEPLOYMENT $(basename $0), exit code $exit_code, check logs"
       ;;
  esac

  exit $exit_code
}
