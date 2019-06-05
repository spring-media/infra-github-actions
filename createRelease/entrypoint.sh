#!/bin/ash
# shellcheck shell=dash
################################################################################
# Description:
#   Script Github Actions to create a new release branch automatically
################################################################################
set -o pipefail

echo "DEBUG: start to create new release branch!"

first_tag_number=$(git tag -l | sort -n | tail -n 1 | cut -c 2- | cut -d '.' -f1)
last_tag_number=$(git tag -l | sort -n | tail -n 1 | cut -c 2- | cut -d '.' -f2)
new_tag=$(echo "$last_tag_number + 1" | bc)
git_tag="v${first_tag_number}.${new_tag}.0"

git checkout -b release/"$git_tag"
git push origin release/"$git_tag"