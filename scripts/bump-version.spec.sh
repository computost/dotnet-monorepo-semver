function main() {
  rm --force --recursive $test_artifacts_dir

  simple_alpha
  simple_beta
  simple_general

  abort_alpha_new_alpha
  abort_beta_new_alpha

  abort_alpha_commit_feat_new_alpha
  commit_feat_abort_alpha_commit_feat_new_alpha
  commit_feat_abort_beta_commit_feat_new_alpha
  commit_breaking_abort_beta_commit_breaking_new_alpha
  commit_breaking_abort_beta_commit_feat_new_alpha

  cleanup_tests
}

function simple_alpha() {
  setup_test
  commit 'fix: bump'
  bump_version 'alpha'
  expect_version '0.0.1-alpha.0'
}

function simple_beta() {
  setup_test '0.0.1-alpha.0'
  bump_version 'beta'
  expect_version '0.0.1-beta.0'
}

function simple_general {
  setup_test '0.0.1-beta.0'
  bump_version
  expect_version '0.0.1'
}

function abort_alpha_new_alpha {
  setup_test
  commit 'fix: bump'
  bump_version 'alpha' # 0.0.1-alpha.0
  git checkout main
  bump_version 'alpha'
  expect_version '0.0.1-alpha.1'
}

function abort_beta_new_alpha {
  setup_test
  commit 'fix: bump'
  bump_version 'alpha' # 0.0.1-alpha.0
  bump_version 'beta' # 0.0.1-beta.0
  git checkout main
  bump_version 'alpha'
  expect_version '0.0.2-alpha.0'
}

function abort_alpha_commit_feat_new_alpha {
  setup_test
  commit 'fix: bump'
  bump_version 'alpha' # 0.0.1-alpha.0
  git checkout main
  commit 'feat: bump'
  bump_version 'alpha'
  expect_version '0.1.0-alpha.0'
}

function commit_feat_abort_alpha_commit_feat_new_alpha {
  setup_test
  commit 'feat: bump'
  bump_version 'alpha' # 0.1.0-alpha.0
  git checkout main
  commit 'feat: bump'
  bump_version 'alpha'
  expect_version '0.1.0-alpha.1'
}

function commit_feat_abort_beta_commit_feat_new_alpha {
  setup_test
  commit 'fix: bump'
  bump_version 'alpha' # 0.0.1-alpha.0
  git checkout main
  commit 'feat: bump'
  bump_version 'alpha' # 0.1.0-alpha.0
  bump_version 'beta' # 0.1.0-beta.0
  git checkout main
  commit 'feat: bump'
  bump_version 'alpha'
  expect_version '0.1.1-alpha.0'
}

function commit_breaking_abort_beta_commit_breaking_new_alpha {
  setup_test
  commit 'feat!: bump'
  bump_version 'alpha' # 1.0.0-alpha.0
  bump_version 'beta' # 1.0.0-beta.0
  git checkout main
  commit 'feat!: bump'
  bump_version 'alpha' # 1.0.1-alpha.0
  expect_version '1.0.1-alpha.0'
}

function commit_breaking_abort_beta_commit_feat_new_alpha {
  setup_test
  commit 'feat!: bump'
  bump_version 'alpha' # 1.0.0-alpha.0
  bump_version 'beta' # 1.0.0-beta.0
  git checkout main
  commit 'feat: bump'
  bump_version 'alpha' # 1.0.1-alpha.0
  expect_version '1.0.1-alpha.0'
}

BOLD_BLUE='\033[1;34m'
BOLD_RED='\033[1;31m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NO_COLOR='\033[0m'

script_path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
test_artifacts_dir="$script_path/../test-artifacts"
current_test_id=0
declare -A test_id_to_name_map
failed_tests=()

function setup_test {
  start_version=${1:-'0.0.0'}
  # use the name of the function calling `setup_test` as the name of the test
  name=${FUNCNAME[1]}

  printf "Running test: ${BBLUE}$name${NO_COLOR}\n\n"
  
  test_id_to_name_map[$current_test_id]=$name
  test_dir="$test_artifacts_dir/$name"
  mkdir --parents $test_dir
  current_test_id=$((current_test_id + 1))
  cd $test_dir

  git init -b main --quiet
  git config user.name 'Test'
  git config user.email 'test@example.com'
  echo "<Project><PropertyGroup><Version>$start_version</Version></PropertyGroup></Project>" \
    >> "$test_dir/Directory.Build.props"
  mkdir "$test_dir/scripts"
  cp "$script_path/bump-version.sh" "$test_dir/scripts"
  git add .
  git commit --message "chore(release): $start_version" --quiet
  git tag "v$start_version"
}

function commit {
  git commit --allow-empty --message "$1" --quiet
}

function bump_version {
  bump_type=$1

  source './scripts/bump-version.sh' $bump_type
}

function expect_version {
  expected=$1
  received=$(dotnet versionize inspect)

  if [[ $received != $expected ]]
  then
    printf "\n${RED}Version mis-match!${NO_COLOR}\n"
    printf "Expected: ${GREEN}$expected${NO_COLOR}\n"
    printf "Received: ${RED}$received${NO_COLOR}\n\n"
    failed_tests+=("$((current_test_id - 1))")
  fi

  printf '\n'
}

function cleanup_tests {
  any_failed=false
  failures=()

  for i in $(seq 0 $((current_test_id - 1)))
  do
    if [[ ${failed_tests[@]} =~ $(echo "\<${i}\>") ]]
    then
      any_failed=true
      failures+=(${test_id_to_name_map[$i]})
    fi
  done
  
  if [ "$any_failed" = true ]
  then
    echo 'There were failures. Please inspect the following folders:'
    for test in ${failures[@]}
    do
      printf "${BOLD_RED}$test${NO_COLOR}\n"
    done
  else
    echo 'All tests passed!'
  fi
}

main
