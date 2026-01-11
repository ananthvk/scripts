#!/bin/bash

# Usage: ./merge_repo.sh <remote-url> <subdir-name>

set -e  # Exit on error

# Check arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <remote-url> <subdir-name>"
    exit 1
fi

REMOTE_URL=$1
SUBDIR=$2
REMOTE_NAME="tempremote"
BRANCH_NAME="tempbranch"

# Add second repo as a remote
echo "Adding remote $REMOTE_NAME -> $REMOTE_URL"
git remote add $REMOTE_NAME $REMOTE_URL

# Fetch all branches from the second repo
echo "Fetching commits from $REMOTE_NAME"
git fetch $REMOTE_NAME

# Create a local branch from the remote's master
echo "Creating local branch $BRANCH_NAME from $REMOTE_NAME"
git branch $BRANCH_NAME $REMOTE_NAME

# Checkout the new branch
git checkout $BRANCH_NAME

# Create subdirectory and move files into it
echo "Moving files into subdirectory $SUBDIR"
mkdir -p $SUBDIR
git ls-tree -z --name-only HEAD | xargs -0 -I {} git mv {} $SUBDIR/ || true

# Commit the move
git commit -m "Moved files from $REMOTE_NAME into $SUBDIR"

# Merge into current repo's master
echo "Checking out master and merging $BRANCH_NAME"
git checkout master
git merge --allow-unrelated-histories $BRANCH_NAME -m "Merged $REMOTE_NAME into $SUBDIR"

# Optional: remove temporary remote and branch
echo "Cleaning up temporary remote and branch"
git remote remove $REMOTE_NAME
git branch -d $BRANCH_NAME

echo "Merge complete! Files from $REMOTE_URL are now in $SUBDIR"

