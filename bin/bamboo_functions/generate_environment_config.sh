function generate_environment_config () {
  unset OPTIND
  while getopts "e:" opt; do
    case ${opt} in
      e  ) deployment_environment="$OPTARG" ;;
    esac
  done

  hiera_config="conf/hiera.yaml"
  generate_config -c "$hiera_config" -t bash -f conf/environment_variables.local.sh -e "$deployment_environment"
}
