function generate_global_config () {
   hiera_config="conf/hiera_global.yaml"
   generate_config -c "$hiera_config" -t bash -f conf/environment_variables.local.sh
}
