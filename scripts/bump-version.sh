bump_type=$1
if [ "$bump_type" = 'alpha' ]
then
  echo "alpha bump"
  version=$(
    echo $(
      git describe --tags $(
        git rev-list --tags --max-count=1
      )
    ) | sed -e 's/^v//g'
  )

  if [[ "$version" =~ beta\.[0-9]+$ ]]
  then
    version=$(
      echo "$version" \
      | sed -r 's/-beta\.[0-9]+//g'
    )
  fi

  sed -i -e "s/<Version>[^<]*/<Version>$version/g" ./Directory.Build.props
  git add .
  git commit -m 'chore: pre-versionize'
  dotnet versionize \
    --pre-release alpha \
    --find-release-commit-via-message
elif [ "$bump_type" = "beta" ]
then
  echo "beta bump"
  dotnet versionize \
    --pre-release beta \
    --aggregate-pre-releases \
    --find-release-commit-via-message
else
  dotnet versionise --aggregate-pre-releases
fi
