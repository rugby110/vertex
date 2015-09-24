function run_permissions () {
  unset OPTIND
  while getopts "e:" opt; do
    case ${opt} in
      e  ) deployment_environment="$OPTARG" ;;
    esac
  done

  sql_permissions="admin/grants_after_every_change_${deployment_environment}.sql"
  echo "Deploying file '$sql_permissions'"
  php ${base_dir}/src/php/Admin/SqlRunner.php $sql_permissions
}
