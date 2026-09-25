#!/bin/bash
#
# Usage: ./release.sh patch|minor|major   (make patch|minor|major)
#
# Releases the next version from main and fails closed: nothing is published
# unless every step succeeds, and a failure leaves the repository as it was.
#
# Before the confirmation prompt (no side effect beyond `git fetch --tags`):
#   - the branch is main and the working tree is clean
#   - the active Xcode matches .xcode-version exactly
#   - origin/main is an ancestor of HEAD (HEAD may be ahead: merge, then release)
#   - the latest tag exists on origin (else the next run would skip a version)
#   - the new tag does not exist yet
# After confirmation, in order:
#   1. scripts/ci_local.sh — the full local pipeline, on the commit being released
#   2. COMMON_VERSION=<x.y.z> make build_xcframework — the binary reports the release version
#   3. scripts/verify_xcframework.sh — both slices, the version, a consumer import
#   4. stamp the plugin manifests and the README skill snippet
#   5. commit and tag
#   6. git push --atomic origin main <tag> — both refs land, or neither does
# From step 2 on, an EXIT trap rolls back unless the push succeeded: it deletes
# the new tag and resets main to the pre-release commit, so a rerun proposes the
# same version. Untracked and ignored files are left alone.
set -euo pipefail
cd "$(dirname "$0")"

BUMP_TYPE=${1:-}

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

PINNED_XCODE="Xcode $(cat .xcode-version)"
ACTIVE_XCODE=$(xcodebuild -version | sed -n 1p)
if [[ "$ACTIVE_XCODE" != "$PINNED_XCODE" ]]; then
    echo "Error: Releases are built with $PINNED_XCODE (.xcode-version), but the active Xcode is $ACTIVE_XCODE."
    exit 1
fi

git fetch --tags origin

if ! git merge-base --is-ancestor origin/main HEAD; then
    echo "Error: origin/main has commits that HEAD does not. Pull them first."
    exit 1
fi

LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
if ! git ls-remote --exit-code --tags origin "refs/tags/$LATEST_TAG" >/dev/null; then
    echo "Error: The latest tag $LATEST_TAG is not on origin. Push it (git push origin $LATEST_TAG) or delete it (git tag -d $LATEST_TAG)."
    exit 1
fi
VERSION=${LATEST_TAG#v}

IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"

case "$BUMP_TYPE" in
    major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
    minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
    patch) PATCH=$((PATCH + 1)) ;;
esac

NEW_VERSION="v${MAJOR}.${MINOR}.${PATCH}"

if git rev-parse -q --verify "refs/tags/$NEW_VERSION" >/dev/null; then
    echo "Error: Tag $NEW_VERSION already exists."
    exit 1
fi

echo "Current version: $LATEST_TAG"
echo "Next version:    $NEW_VERSION ($BUMP_TYPE bump)"
echo ""
echo "Runs the local CI (about 10 minutes), builds and verifies the binary, then commits, tags and pushes."
read -r -p "Release $NEW_VERSION? [y/N] " CONFIRM || CONFIRM=""
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Aborted."
    exit 0
fi

echo "Running the local CI pipeline..."
scripts/ci_local.sh

# The next steps write tracked files: roll back unless the push succeeds.
PRE_RELEASE_HEAD=$(git rev-parse HEAD)
rollback() {
    echo "Release failed: deleting tag $NEW_VERSION and resetting main to $PRE_RELEASE_HEAD." >&2
    git tag -d "$NEW_VERSION" >/dev/null 2>&1 || true
    git reset --hard -q "$PRE_RELEASE_HEAD"
}
trap rollback EXIT

echo "Building XCFramework..."
COMMON_VERSION=${NEW_VERSION#v} make build_xcframework

echo "Verifying XCFramework..."
scripts/verify_xcframework.sh XCFramework/Common.xcframework "${NEW_VERSION#v}"

echo "Stamping the plugin manifests with ${NEW_VERSION#v}..."
sed -i '' "s/\"version\": \"[^\"]*\"/\"version\": \"${NEW_VERSION#v}\"/" .claude-plugin/plugin.json .claude-plugin/marketplace.json

echo "Stamping the README skill snippet with $NEW_VERSION..."
sed -i '' "s/^V=v[0-9.]*; D=/V=$NEW_VERSION; D=/" README.md

echo "Committing XCFramework, plugin manifests and README..."
git add -f XCFramework/Common.xcframework .claude-plugin README.md
git commit -m "Add xcframework for $NEW_VERSION"

git tag -a "$NEW_VERSION" -m "$NEW_VERSION"
git push --atomic origin main "$NEW_VERSION"
trap - EXIT
echo "Done! Released $NEW_VERSION."
