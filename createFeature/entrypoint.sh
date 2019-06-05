#!/bin/ash
# shellcheck shell=dash
################################################################################
# Description:
#   Script Github Actions to create a new feature branch automatically
################################################################################
set -o pipefail

getRelease() {
    git branch -a | grep release | sort -n | tail -n 1 | cut -c 3-
}

getIssueNr() {
    jq --raw-output .issue.number "$GITHUB_EVENT_PATH"
}

echo "DEBUG: start to create new feature branch!"

issue_nr="$(getIssueNr)"
echo "DEBUG: issue number: $issue_nr"

current_release_branch="$(getRelease)"
echo "DEBUG: current release branch: $current_release_branch"

git checkout "$current_release_branch"
git checkout -b feature/"$issue_nr"
git push origin feature/"$issue_nr"

curl -X POST -H "Accept: application/vnd.github.squirrel-girl-preview" -H"Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/"$GITHUB_REPOSITORY"/issues/"$issue_nr"/comments -d '{"body": "https://github.com/'"$GITHUB_REPOSITORY"'/tree/feature/'"$issue_nr"'"}'