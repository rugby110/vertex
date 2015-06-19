#!/bin/bash
#
# bamboo_functions.sh
#
# Description:  functions used by the bamboo_*.sh scripts.  Kept here
#               to make the scripts themselves more simple and more readable.

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

	echo "TODO: run DDL statements"
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
