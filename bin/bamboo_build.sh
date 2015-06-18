#!/bin/bash
#
# bamboo_build.sh
#
# Description:  Build the vertex app from bamboo.

script_dir=$(dirname $0)
source $script_dir/bamboo_functions.sh

# traps, shell settings
trap exit_handler EXIT
set -xe


# Main
begin ": vertex build"

# Run composer
run_composer

exit 0
