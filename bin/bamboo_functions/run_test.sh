function run_test () {
  unset OPTIND
  while getopts "j:" opt; do
    case ${opt} in
      j  ) job_name="$OPTARG" ;;
    esac
  done
  source conf/environment_variables.sh
  echo "running phpunit <bamboo_job_name> # where bamboo_job_name is $job_name"
  ./vendor/bin/phpunit "$job_name"
}
