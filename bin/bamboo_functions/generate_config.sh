function generate_config () {
  unset OPTIND
  while getopts "c:t:f:e:" opt; do
    case $opt in
      c ) hiera_yaml=$OPTARG ;;
      t ) config_file_type=$OPTARG ;;
      f ) config_file=$OPTARG ;;
      e ) deployment_environment=$OPTARG ;;
    esac
  done

  # pull in factor and environmental variables with the bamboo_ prefix to be 
  # used in the hiera config
  sys_yaml=$(mktemp --tmpdir --suffix=.yaml system_XXXXXXX)
  facter -y > $sys_yaml
  export deploy_env=$deployment_environment
  env | grep -E "(build_|package_|test_|deploy_)" | sed "s/=/: /" >> $sys_yaml

  # clear the existing file
  rm -f $config_file

  # get all of the configuration keys and values
  configs=$(hiera -h -c $hiera_yaml -y $sys_yaml conf)

  # hiera operations complete
  rm -f $sys_yaml

  # collapse multi-line key/value pairs to a single line
  configs=$(sed -e ":a;/[^,}]$/{N;s/\n//;ba}" -e "s/=> \+/=>/g" <<<"$configs")

  # put the global opening and closing brackets on separate lines
  configs=$(sed -e '1 s/^{/{\n /' -e "$ s/}$/\n}/" <<<"$configs")

  # generate credentials from lastpass
  configs=$(generate_lpass_creds -c "$configs")  

  # separate out raw config lines
  # THIS IS A HACK for configs with more than key/value pairs 
  # examples: php code, php variables
  configs_raw=$(generate_raw_configs -c "$configs")
  configs=$(remove_raw_configs -c "$configs")

  # generate the config file
  write_configs -c "$configs" -r "$configs_raw" -t $config_file_type -f $config_file
}

function generate_lpass_creds () {
  unset OPTIND
  while getopts "c:" opt; do
    case $opt in
      c ) configs="$OPTARG" ;;
    esac
  done
  new_configs="$configs"
  while grep -qE "\"lpass:" <<-HERE
	$new_configs
	HERE
  do
    lpass_strings=$(echo "$configs" | sed -e "/\"lpass:/{s/^.*\"\(lpass:[^\"]\+\)\".*$/\1/;p};d")
    while read lpass_string; do
      lpass_site=$(cut -f 2 -d ":" <<<"$lpass_string")
      lpass_item=$(cut -f 3 -d ":" <<<"$lpass_string")
      lpass_result=$(lpass show --sync=now --$lpass_item "$lpass_site")
      new_configs=$(sed -e "s|$lpass_string|$lpass_result|g" <<<"$new_configs")
    done <<-HERE
	$lpass_strings
	HERE
  done
  echo "$new_configs"
}

function generate_raw_configs () {
  unset OPTIND
  while getopts "c:" opt; do
    case $opt in
      c ) configs="$OPTARG" ;;
    esac
  done
  
  sed -e "/raw:/p;d" <<-HERE
	$configs
	HERE

}

function remove_raw_configs () {
  unset OPTIND
  while getopts "c:" opt; do
    case $opt in
      c ) configs="$OPTARG" ;;
    esac
  done

  sed -e "/raw:/d" <<-HERE
	$configs
	HERE
}

function write_configs () {
  unset OPTIND
  while getopts "c:t:f:r:" opt; do
    case $opt in
      c ) configs="$OPTARG" ;;
      r ) configs_raw="$OPTARG" ;;
      t ) config_file_type=$OPTARG ;;
      f ) config_file=$OPTARG ;;
    esac
  done
  case $config_file_type in
    bash ) write_configs_bash -c "$configs" -f $config_file;;
    php  ) write_configs_php  -c "$configs" -r "$configs_raw" -f $config_file;;
    stdout ) echo "$configs"; echo "$configs_raw";;
  esac
}

function write_configs_bash () {
   unset OPTIND
   while getopts "c:f:" opt; do
     case opt in
       k ) configs="$OPTARG" ;;
       f ) config_file=$OPTARG ;;
     esac
   done

  # generate the config file

  #get rid of the leading and trailing curly braces
  configs=$(sed "/^[{}]/d"<<<"$configs")
  while read config; do
    key="$(  sed "s/^\"\([^\"]\+\)\"=>\([^,]\+\),\?$/\1/" <<<"$config")"
    value="$(sed "s/^\"\([^\"]\+\)\"=>\([^,]\+\),\?$/\2/" <<<"$config")"
    echo "export $key=$value" >> $config_file
  done <<-HERE
	$configs
	HERE
}

function write_configs_php () {
   unset OPTIND
   while getopts "c:r:f:" opt; do
     case opt in
       c ) configs="$OPTARG" ;;
       r ) configs_raw="$OPTARG" ;;
       f ) config_file=$OPTARG ;;
     esac
   done

   # deal with arrays
   # this creates nested arrays, both indexed and associative
   configs=$(sed -e "s/[[{]/array(/g" -e "s/[]}]/)/g" <<<"$configs")

   # deal with raw entries
   configs_raw=$(sed -e "s/^.*raw://" -e "s/\"$//" <<<"$configs_raw")
   
   # write the file
   echo "<?php" >$config_file
   echo -n '$config = ' >>$config_file
   cat >>$config_file <<-HERE
	$configs ;
	HERE
   cat >>$config_file <<-HERE
	$configs_raw
	HERE
}
