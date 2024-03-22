version=$(
  echo $(
    git describe --tags $(
      git rev-list --tags --max-count=1
    )
  ) | sed -e 's/^v//g'
)
sed -i -e "s/<Version>[^<]*/<Version>$version/g" ./Directory.Build.props 
git add .
git commit -m "chore: sync version to tag"
