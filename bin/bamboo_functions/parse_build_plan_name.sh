function parse_build_plan_name () {
  unset OPTIND
  while getopts "p:i:" opt; do
    case ${opt} in
      p  ) build_plan_name="$OPTARG" ;;
      i  ) item_to_parse="$OPTARG";;
    esac
  done
 
  # bamboo passes the project name as a string with either of the following:
  # "<project> - <plan> - <branch> - <job>"
  # "<project> - <plan> - <job>"
  better_delim=$(sed "s/ - /:/g" <<<"$build_plan_name")
  project_name=$(cut -d ":" -f 1 <<<"$better_delim")
  plan_name=$(cut -d ":" -f 2 <<<"$better_delim")
  branch_name=$(cut -d ":" -f 3 <<<"$better_delim")
  job_name=$(cut -d ":" -f 4 <<<"$better_delim")

  if [[ -z "$job_name" ]]; then
    # format is "<project> - <plan> - <job>"
    job_name="$branch_name"
    branch_name=""
  fi
  
  case $item_to_parse in
    project_name ) echo $project_name ;;
    plan_name    ) echo $plan_name ;;
    branch_name  ) echo $branch_name ;;
    job_name     ) echo $job_name ;;
    \?           ) return 1    ;;
    \*           ) return 1    ;;
  esac
}
