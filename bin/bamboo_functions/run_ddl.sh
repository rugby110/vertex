function run_ddl () {
  # for all the DDL sql in src/sql, apply to vertica
  # future: take a param to only do a subset of src/sql
  echo "running DDL statements"

  find ${base_dir}/src/sql -name \*.sql | while read sql_file; do
    if grep --quiet VERTEX_NO_DEPLOY $sql_file; then
      echo "Skipping '$sql_file' with VERTEX_NO_DEPLOY tag"
    else
      echo "Deploying file '$sql_file'"
      php ${base_dir}/src/php/admin/SqlRunner.php $sql_file
    fi
  done
}
