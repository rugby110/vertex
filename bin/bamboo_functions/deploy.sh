function deploy () {
  unset OPTIND
  while getopts "e:" opt; do
    case ${opt} in
      e  ) deployment_environment="$OPTARG" ;;
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
  run_permissions -e "$deployment_environment"
}
