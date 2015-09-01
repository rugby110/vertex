function generate_artifacts () {
  unset OPTIND
  while getopts "p:" opt; do
    case ${opt} in
      p ) project_name="$OPTARG" ;;
    esac
  done

  echo "Creating tarball"
  dir_name="${PWD##*/}"
  pushd ..
  tar -I lbzip2 --exclude-vcs -cf "$project_name".tar.bz2 "$dir_name"
  popd
}
