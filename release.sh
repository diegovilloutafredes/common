#!/bin/bash
set -e

BUMP_TYPE=$1

if [[ "$BUMP_TYPE" != "patch" && "$BUMP_TYPE" != "minor" && "$BUMP_TYPE" != "major" ]]; then
    echo "Error: Bump type must be patch, minor, or major."
    exit 1
fi

CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "main" ]]; then
    echo "Error: Must be on main branch to release. Currently on '$CURRENT_BRANCH'."
    exit 1
fi

if [[ -n $(git status --porcelain) ]]; then
    echo "Error: Working directory is not clean. Commit or stash changes first."
    git status -s
    exit 1
fi

LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
VERSION=${LATEST_TAG#v}

IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"

case "$BUMP_TYPE" in
    major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
    minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
    patch) PATCH=$((PATCH + 1)) ;;
esac

NEW_VERSION="v${MAJOR}.${MINOR}.${PATCH}"

echo "Current version: $LATEST_TAG"
echo "Next version:    $NEW_VERSION ($BUMP_TYPE bump)"
echo ""
read -p "Tag and push $NEW_VERSION? [y/N] " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Aborted."
    exit 0
fi

git tag -a "$NEW_VERSION" -m "$NEW_VERSION"
git push origin "$NEW_VERSION"
echo "Done! GitHub Actions will now build the XCFramework and create the release for $NEW_VERSION."
