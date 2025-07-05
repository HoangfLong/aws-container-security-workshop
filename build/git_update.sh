VERSION=""

while getopts v: flag
do
  case "${flag}" in
    v) VERSION=${OPTARG};;
  esac
done

git fetch --tags --prune --unshallow 2>/dev/null
CURRENT_VERSION=$(git describe --abbrev=0 --tags 2>/dev/null)

if [[ "$CURRENT_VERSION" == "" ]]; then
  CURRENT_VERSION="v0.0.0"
fi

echo "Current Version: $CURRENT_VERSION"

NUM_PART=${CURRENT_VERSION#v}
CURRENT_VERSION_PARTS=(${NUM_PART//./ })

VNUM1=${CURRENT_VERSION_PARTS[0]}
VNUM2=${CURRENT_VERSION_PARTS[1]}
VNUM3=${CURRENT_VERSION_PARTS[2]}

if [[ $VERSION == 'major' ]]; then
  VNUM1=$((VNUM1+1))
  VNUM2=0
  VNUM3=0
elif [[ $VERSION == 'minor' ]]; then
  VNUM2=$((VNUM2+1))
  VNUM3=0
elif [[ $VERSION == 'patch' ]]; then
  VNUM3=$((VNUM3+1))
else
  echo "Invalid version type. Use: -v [major|minor|patch]"
  exit 1
fi

NEW_TAG="v$VNUM1.$VNUM2.$VNUM3"
echo "($VERSION) updating $CURRENT_VERSION to $NEW_TAG"

GIT_COMMIT=$(git rev-parse HEAD)
NEEDS_TAG=$(git describe --contains $GIT_COMMIT 2>/dev/null)

if [ -z "$NEEDS_TAG" ]; then
  echo "Tagged with $NEW_TAG"
  git tag $NEW_TAG
  git push origin $NEW_TAG
else
  echo "Already a tag on this commit"
fi

echo "git-tag=$NEW_TAG" >> $GITHUB_OUTPUT
exit 0
