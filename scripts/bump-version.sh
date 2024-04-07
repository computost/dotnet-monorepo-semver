set_build_props_version() {
  version=$1

  sed -i "s/<Version>[^<]*/<Version>$(
      echo $version |
        sed 's/^v//' |
        sed -r 's/-beta\.[0-9]+$//'
    )/g" \
    ./Directory.Build.props
}

get_last_general_release() {
  for tag in $(git tag --sort=-refname)
  do
    if [[ $tag =~ ^v([0-9]+\.){2}[0-9]+$ ]]
    then
      echo $tag
      return 0
    fi
  done
}

get_version_part() {
  version="$1"
  part="$2"

  case $part in
    major)
      echo $version |
        sed -rn 's/^v?([[:digit:]]+).*$/\1/p'
      ;;

    minor)
      echo $version |
        sed -rn 's/^v?[[:digit:]]+\.([[:digit:]]+).*$/\1/p'
      ;;

    patch)
      echo $version |
        sed -rn 's/^v?([[:digit:]]+\.){2}([[:digit:]]+).*$/\2/p'
      ;;

    prerelease)
      echo $version |
        sed -rn 's/^v?([[:digit:]]+\.){2}[[:digit:]]+-(.+)$/\2/p'
      ;;

    *)
      echo "unrecognized part: $part" 1>&2
      return 1
  esac
}

get_version_part_diff() {
  version_1=$1
  version_2=$2
  part=$3
  
  echo "$((
    $(get_version_part $version_1 $part)
    - $(get_version_part $version_2 $part)))"
}

get_next_patch_version() {
  version=$1

  current_directory=$(pwd)
  temp_repo="${RUNNER_TEMP:-.}/temp_repo"
  mkdir $temp_repo
  cp ./Directory.Build.props $temp_repo
  cd $temp_repo
  git init --quiet
  git config user.name temp
  git config user.email temp
  set_build_props_version $version
  git add .
  git commit -m 'chore: init' --quiet
  dotnet versionize --silent --skip-tag
  git commit --allow-empty -m 'fix: bump' --quiet
  dotnet versionize \
    --find-release-commit-via-message \
    --pre-release alpha \
    --silent \
    --skip-tag
  echo $(dotnet versionize inspect)
  cd $current_directory
  rm -rf $temp_repo
}

remove_pre_release() {
  version=$1
  echo $version | sed -rn 's/-[a-z]+\.[0-9]+//p'
}

checkout_temp_branch() {
  temp_index=0
  while git rev-parse --verify "temp_$temp_index" >/dev/null 2>&1
  do
    temp_index=$((temp_index + 1))
  done
  git checkout -b "temp_$temp_index" --quiet
}

checkout_temp_branch

bump_type=$1
if [ "$bump_type" = 'alpha' ]
then
  current_version=$(
    git describe --tags $(
      git rev-list --tags --max-count=1
    )
  )

  set_build_props_version $current_version
  git add .
  git commit --allow-empty --message 'chore: pre-versionize' --quiet

  dotnet versionize \
    --find-release-commit-via-message \
    --pre-release alpha \
    --silent \
    --skip-tag
  tentative_version=$(dotnet versionize inspect)
  git reset --hard HEAD~2 --quiet

  last_general_release=$(get_last_general_release)
  if [ $(get_version_part_diff $tentative_version $last_general_release major) -gt 1 ] \
    || ([ $(get_version_part_diff $tentative_version $last_general_release major) -eq 1 ] \
      && [ $(get_version_part $tentative_version minor) -gt 0 ]) \
    || ([ $(get_version_part_diff $tentative_version $last_general_release major) -eq 0 ] \
      && [ $(get_version_part_diff $tentative_version $last_general_release minor) -gt 1 ])
  then
    new_version=$(get_next_patch_version $current_version)
  else
    new_version=$tentative_version
  fi

  dotnet versionize \
    --exit-insignificant-commits \
    --release-as $new_version
elif [ "$bump_type" = "beta" ]
then
  current_version=$(dotnet versionize inspect)
  dotnet versionize \
    --release-as "$(remove_pre_release $current_version)-beta.0" \
    --aggregate-pre-releases
else
  current_version=$(dotnet versionize inspect)
  dotnet versionize \
    --release-as $(remove_pre_release $current_version) \
    --aggregate-pre-releases
fi

git branch -m "release/v$(dotnet versionize inspect)"
