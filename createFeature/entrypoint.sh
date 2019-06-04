#!/bin/ash
# shellcheck shell=dash
################################################################################
# Description:
#   Script Github Actions to create a new feature branch automatically
################################################################################
set -eu
set -o pipefail

echo "DEBUG: start to create new feature branch!"

issuenr=$(jq --raw-output .issue.number "$GITHUB_EVENT_PATH")
current_release_branch=$(git branch | grep "release")
echo "DEBUG: issue number: '$issuenr'"
echo "DEBUG: current release branch: '$current_release_branch'"

git checkout $current_release_branch
git checkout -b feature/$issuenr
git push origin feature/$issuenr
curl -X POST -H "Accept: application/vnd.github.squirrel-girl-preview" -H"Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$issuenr/comments -d '{"body": "https://github.com/'$GITHUB_REPOSITORY'/tree/feature/'$issuenr'"}'