function exit_handler () {
  exit_code=$?
  set +xe

  if [[ -n $bamboo_stage ]]; then
    during="DURING $bamboo_stage in "
  fi
  case $exit_code in
    0) echo "SUCCESSFUL $(basename $0)"
       ;;
    11) echo "ABORTED $(basename $0), LOCK IN PLACE"
       ;;
    12) echo "ABORTED ${during}$(basename $0), INTERRUPTED"
       ;;
    *) echo "PROBLEMS ${during}$(basename $0), exit code $exit_code, check logs"
       ;;
  esac

  exit $exit_code  
}
