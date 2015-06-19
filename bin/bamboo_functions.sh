#!/bin/bash
#
# bamboo_functions.sh
#
# Description:  functions used by the bamboo_*.sh scripts.  Kept here
#               to make the scripts themselves more simple and more readable.

# invoke composer
run_composer () {
	/usr/local/bin/composer.phar install
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