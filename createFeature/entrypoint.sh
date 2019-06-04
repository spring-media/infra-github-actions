#!/bin/ash
set -eu
set -o pipefail

main() {
   issuenr=$(jq --raw-output .issue.number "$GITHUB_EVENT_PATH")
   current_release_branch=$(git branch | grep "release")
   echo "DEBUG: issue number: '$issuenr'"
   echo "DEBUG: current release branch: '$current_release_branch'"

   git checkout $current_release_branch
   git checkout -b feature/$issuenr
   git push origin feature/$issuenr
   curl -X POST -H "Accept: application/vnd.github.squirrel-girl-preview" -H"Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/$GITHUB_REPO/issues/$issuenr/comments -d '{"body": "https://github.com/'$GITHUB_REPO'/tree/feature/'$issuenr'"}'
}

main