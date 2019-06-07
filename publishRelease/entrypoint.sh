#!/bin/ash
# shellcheck shell=dash
################################################################################
# Description:
#   Script Github Actions to create a new release automatically and a new
#   release branch with new version.
################################################################################

set -o pipefail

# ============================================
# Function to create a new release in Github API
# ============================================
request_create_release(){
    echo "DEBUG: create new release with tag: $git_tag"

	local json_body='{
	  "tag_name": "@tag_name@",
	  "target_commitish": "@branch@",
	  "name": "@release_name@",
	  "body": "@description@",
	  "draft": false,
	  "prerelease": false
	}'

	json_body=$(echo "$json_body" | sed "s/@tag_name@/$git_tag/")
	json_body=$(echo "$json_body" | sed "s/@branch@/master/")
	json_body=$(echo "$json_body" | sed "s/@release_name@/Release $git_tag/")
	json_body=$(echo "$json_body" | sed "s/@description@/$DESCRIPTION/")

	curl --request POST \
	  --url https://api.github.com/repos/"$GITHUB_REPOSITORY"/releases \
	  --header "Authorization: Bearer $GITHUB_TOKEN" \
	  --header 'Content-Type: application/json' \
	  --data "$json_body"
}

create_new_release_branch() {
    new_release_branch="release/$git_tag"

    echo "DEBUG: create new release branch: $new_release_branch!"

    git checkout -b release/"$new_release_branch"
    git push origin release/"$new_release_branch"
}


# ==================== MAIN ====================

# Ensure that the GITHUB_TOKEN secret is included
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

current_branch=$(git branch | grep "^*" | awk '{print $2}')
echo "DEBUG: current branch = $current_branch"

if [ "$current_branch" != "master" ]; then
    echo "This Action run only in master branch"
	exit 0
fi

if [ "$(git tag | wc -l)" = "0" ]; then
        git_tag="v1.0.0"
        request_create_release
        create_new_release_branch
else
    new_release=$(cat VERSION)
    echo "DEBUG: new release: $new_release"

    if [ -z "$new_release" ]; then
        echo "no new release found. Edit ./VERSION with v\d.\d.\d"
        exit 1
    fi

    current_release=$(git tag -l | sort -n | tail -n 1)
    echo "DEBUG: current release = $current_release"

    if [ "$current_release" = "$new_release" ]; then
        echo "Nothing to do"
        exit 0
    else
        git_tag="$new_release"
        request_create_release
        create_new_release_branch
    fi
fi