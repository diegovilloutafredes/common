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

echo "Preparing a $BUMP_TYPE release..."

# Check if there are changes to commit
if [[ -z $(git status -s) ]]; then
    echo "No changes to commit. Make sure you have modified some files."
    exit 1
fi

echo "Files that will be staged:"
git status -s

# Prompt for a commit message
read -p "Enter a brief commit message for this $BUMP_TYPE release: " COMMIT_MSG

if [[ -z "$COMMIT_MSG" ]]; then
    echo "Commit message cannot be empty. Aborting."
    exit 1
fi

FINAL_MSG="$COMMIT_MSG #$BUMP_TYPE"

git add .

echo "Committing with message: '$FINAL_MSG'"
git commit -m "$FINAL_MSG"

read -p "Push to origin/main and trigger release? [y/N] " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Aborted. Commit was made locally but not pushed."
    exit 0
fi

git push origin main
echo "Done! GitHub Actions will now build the XCFramework, tag the new $BUMP_TYPE version, and create the release."
