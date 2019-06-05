#!/bin/ash
# shellcheck shell=dash
################################################################################
# Description:
#   Script Github Actions to create a new release automatically
################################################################################

set -o pipefail

# ============================================
# Function to create a new release in Github API
# ============================================
request_create_release(){

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
    echo "DEBUG: start to create new release branch!"

    new_release_branch_version="v${first_tag_number}."$(echo "$new_tag + 1" | bc)".0"

    git checkout -b release/"$new_release_branch_version"
    git push origin release/"$new_release_branch_version"
}

# ============================================
# Function to get last release branch name
# ============================================
getRelease() {
    git branch -a | grep release | sort -n | tail -n 1 | cut -c 3-
}

# ============================================
# Function to get the head of the given git branch
# ============================================
getHead() {
    git rev-parse "$1"
}

# ==================== MAIN ====================

# Ensure that the GITHUB_TOKEN secret is included
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

current_branch=$(git branch | grep "^*" | awk '{print $2}')
echo "DEBUG: current branch = $current_branch"

master_head=$(getHead master)
echo "DEBUG: master head: $master_head"
current_release_branch=$(getRelease)
echo "DEBUG: current release branch: $current_release_branch"
release_head=$(getHead "$current_release_branch")
echo "DEBUG: release head: $release_head"

if [ "$current_branch" = "master" ] && [ "$master_head" = "$release_head" ] ;then

	# if not exist env var $VERSION
	# get tag by 'git tag' command
	if [ -z "$VERSION" ]; then
		# If null, is the first release
		if [ "$(git tag | wc -l)" = "0" ];then
			git_tag="v1.0.0"
			request_create_release
			create_new_release_branch
		else
            first_tag_number=$(git tag -l | sort -n | tail -n 1 | cut -c 2- | cut -d '.' -f1)
            last_tag_number=$(git tag -l | sort -n | tail -n 1 | cut -c 2- | cut -d '.' -f2)
			new_tag=$(echo "$last_tag_number + 1" | bc)
			# git_tag="v${new_tag}.0"
			git_tag="v${first_tag_number}.${new_tag}.0"
			request_create_release
			create_new_release_branch
		fi
	# if env var $VERSION exist, use it
	else
		echo "DEBUG: env VERSION = $VERSION"
		# if en var $VERSION don't start with 'v', add 'v' in
		# start of string
		if [ "$(echo "$VERSION" | cut -c 1)" != 'v' ];then
			VERSION="v$VERSION"
		fi

		# verify if $VERSION already exist in git tag list
		if git tag -l | grep -q "$VERSION";then
			echo "tag $VERSION already exist"
			exit 1
		fi

		first_number_version=$(echo "$VERSION" | cut -c 2)
		if [ "$first_number_version" -lt "$last_tag_number" ];then
			echo "the env var $VERSION is less than last tag: $last_tag_number"
			exit 1
		fi

		# if everything ok, the new version is env $VERSION
		git_tag="$VERSION"
		request_create_release
		create_new_release_branch
	fi

else
	echo "This Action run only in master branch if release branches was merged"
	exit 0
fi
