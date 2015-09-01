function parse_build_plan_name () {
  unset OPTIND
  while getopts "p:i:" opt; do
    case ${opt} in
      p  ) build_plan_name="$OPTARG" ;;
      i  ) item_to_parse="$OPTARG";;
    esac
  done
 
  # bamboo can only pass the project name as a string with:
  # "<project> - <plan> - <branch> - <job>"
  
  case $item_to_parse in
    project_name ) bpn_index=1 ;;
    plan_name    ) bpn_index=2 ;;
    branch_name  ) bpn_index=3 ;;
    job_name     ) bpn_index=4 ;;
    \?           ) return 1    ;;
    \*           ) return 1    ;;
  esac
  echo $(cut -d "-" -f $bpn_index <<<"$build_plan_name")
}
