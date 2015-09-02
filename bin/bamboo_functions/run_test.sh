function run_test () {
  unset OPTIND
  while getopts "j:" opt; do
    case ${opt} in
      j  ) job_name="$OPTARG" ;;
    esac
  done
  source conf/environment_variables.sh
  echo "running mpm_migrations"
  run_mpm_migrations
  # VER-337 - need to run ddl 4 times as a workaround
  for count in $(seq 4); do
    echo "running ddl"
    run_ddl
  done
  echo "running permissions"
  run_permissions
  echo "running phpunit <bamboo_job_name> # where bamboo_job_name is $job_name"
  ./vendor/bin/phpunit "$job_name"
}
