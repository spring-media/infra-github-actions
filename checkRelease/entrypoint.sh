#!/bin/ash
# shellcheck shell=dash
################################################################################
# Description:
#   Script Github Actions to check is relaese branch up to date with master
################################################################################

set -o pipefail


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
    echo "release branch is up to date"
else
	echo "release branch is behind master. please rebase it"
	echo "git checkout release/v***"
	echo "git rebase master"
	echo "git push"
	exit 0
fi
