function run_ddl () {
  # for all the DDL sql in src/sql, apply to vertica
  # future: take a param to only do a subset of src/sql
  echo "running DDL statements"

  # insert the first command line arg into the search string after a '*' wildcard char
  # this allows you to do something like "bin/local_deploy.sh geo"
  #		which will only deploy vertex_dim_geo by matching vertex_dim_geo.sql
  file_search=$1

  # if file_search is empty then generate a dependency ordered file list
  # otherwise generate a file list based on the search result without taking dependencies into account
  if [ -z "$file_search" ]; then
	  file_list=(`php ${base_dir}/src/php/Admin/FindDeployOrder.php ${base_dir}/src/sql`)
  else
	  file_list=(`find ${base_dir}/src/sql -name \*${file_search}.sql`)
  fi

  for sql_file in "${file_list[@]}"
  do
 	   if grep --quiet VERTEX_NO_DEPLOY $sql_file; then
    	  echo "Skipping '$sql_file' with VERTEX_NO_DEPLOY tag"
       else
      	  echo "Deploying file '$sql_file'"
          php ${base_dir}/src/php/Admin/SqlRunner.php $sql_file
       fi
  done
}
