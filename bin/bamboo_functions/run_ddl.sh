function run_ddl () {
  # for all the DDL sql in src/sql, apply to vertica
  # future: take a param to only do a subset of src/sql
  echo "running DDL statements"
  which vsql || (echo "No vsql found!"; exit 1)
  find ${script_dir}/../src/sql -name \*.sql | while read sql_file; do
    if grep --quiet VERTEX_NO_DEPLOY $sql_file; then
      echo "Skipping '$sql_file' with VERTEX_NO_DEPLOY tag"
    else
      echo "Deploying file '$sql_file'"
      echo "set search_path to $vertex_vertica_vertex_schema;SET SESSION AUTOCOMMIT TO on;"|cat - $sql_file > /tmp/out.sql
      #cat /tmp/out.sql
      vsql -f /tmp/out.sql
    fi
  done
}
