#!/usr/bin/env zsh

author_default="$(git config user.name)"
format_default='%cd %H %an _repo_path_'
date_default='format:%Y-%m-%dT%H:%M:%S%z'
dirs='~'
show-help() {
  echo 'collect-commits.zsh [options]'
  echo
  echo 'options:'
  echo "  --dirs Directories containing target repositories (default: $dirs)"
  echo 'Other options is passed to git log with followings default options'
  echo "  --author='$author_default'"
  echo "  --date='$date_default'"
  echo "  --format='$format_default' (note: _repo_path_ is replaced with the repo path)"
}

local -A opts
zparseopts -D -A opts -- h -help=h -dirs:

if [ -n "${opts[(i)-h]}" ]
then
  show-help
  exit 0
fi

if [ -n "${opts[(i)--dirs]}" ]
then
  dirs="${opts[--dirs]}"
fi

cmd="git --no-pager log --no-merges --all $*"
if ! [[ $cmd =~ '--author' ]]
then
  cmd="$cmd --author='$author_default'"
fi

if ! [[ $cmd =~ '--date' ]]
then
  cmd="$cmd --date='$date_default'"
fi

if ! [[ $cmd =~ '--format' ]]
then
  cmd="$cmd --format='$format_default'"
fi


for repo in $(find $dirs -name '.git' | xargs dirname)
do
  cd $repo
  eval $cmd | sed "s%_repo_path_%$(pwd)%g"
done
