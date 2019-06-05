#!/bin/ash
# shellcheck shell=dash
################################################################################
# Description:
#   Script Github Actions to rebase a release branch on master automatically
################################################################################
set -o pipefail

getRelease() {
    git branch -a | grep release | sort -n | tail -n 1 | cut -c 3-
}

current_release_branch="$(getRelease)"
echo "DEBUG: current release branch: $current_release_branch"

git checkout "$current_release_branch"
git rebase origin/master
git push origin HEAD:"$(echo "$current_release_branch" | cut -c 16-)"