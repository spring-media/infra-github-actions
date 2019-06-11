#!/bin/ash
# shellcheck shell=dash
################################################################################
# Description:
#   Script Github Actions to create a new feature branch automatically
################################################################################
set -o pipefail

getIssueNr() {
    jq --raw-output .issue.number "$GITHUB_EVENT_PATH"
}

echo "DEBUG: start to create new feature branch!"

issue_nr="$(getIssueNr)"
echo "DEBUG: issue number: $issue_nr"

git checkout -b feature/"$issue_nr"
git push origin feature/"$issue_nr"

echo "DEBUG: post comment on issue with branch path"
curl -X POST -H "Accept: application/vnd.github.squirrel-girl-preview" -H"Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/"$GITHUB_REPOSITORY"/issues/"$issue_nr"/comments -d '{"body": "https://github.com/'"$GITHUB_REPOSITORY"'/tree/feature/'"$issue_nr"'"}'