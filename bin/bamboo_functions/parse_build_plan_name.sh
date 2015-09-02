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
  project_name=$(echo $(cut -d "-" -f 1 <<<"$build_plan_name"))
  plan_name=$(echo $(cut -d "-" -f 2 <<<"$build_plan_name"))
  branch_name=$(echo $(cut -d "-" -f 3 <<<"$build_plan_name"))
  job_name=$(echo $(cut -d "-" -f 4 <<<"$build_plan_name"))

  # if the branch is missing, then the format is
  # "<project> - <plan> - <job>"
  if [[ -z "$job_name" ]]; then
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
