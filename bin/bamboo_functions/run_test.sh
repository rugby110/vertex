function run_test () {
  unset OPTIND
  while getopts "j:" opt; do
    case ${opt} in
      j  ) job_name="$OPTARG" ;;
    esac
  done
  source conf/environmment_variables.sh
  ./vendor/bin/phpunit "$job_name"
}
