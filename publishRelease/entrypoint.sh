#!/bin/bash
################################################################################
# Description:
#   Script Github Actions to create a new release automatically
################################################################################

set -o pipefail

# ============================================
# Function to create a new release in Github API
# ============================================
request_create_feature_release(){
    echo "DEBUG: create new release with tag = $git_tag"

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

request_create_bugfix_release() {
      # Ensure that the REPO_WRITE_TOKEN secret is included
    if [ -z "$REPO_WRITE_TOKEN" ]; then
      echo "Set the REPO_WRITE_TOKEN env variable with write credential for this repository."
      exit 1
    fi

    echo "DEBUG: create bugfix tag = $git_tag"

    git remote set-url origin https://$REPO_WRITE_TOKEN:x-oauth-basic@github.com/${GITHUB_REPOSITORY}.git
    git config --global user.email "action@github.com"
    git config --global user.name "GitHub Action"

    git tag "$git_tag"
    git push origin "$git_tag"
}

testvercomp () {
    vercomp $1 $2
    case $? in
        0) echo "Nothing to do."
           exit 0;;
        1) echo "Pass: '$1 > $2'";;
        2) echo "new version is older than last version."
           exit 1;;
    esac
}

vercomp () {
    if [ "$1" == "$2" ]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}


# ==================== MAIN ====================

# Ensure that the GITHUB_TOKEN secret is included
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

echo "DEBUG: current branch = $GITHUB_REF"

master_branch=$(echo "$GITHUB_REF" | grep "master")
if [ -z "$master_branch" ]; then
    echo "This Action run only in master branch."
	exit 0
fi

echo "DEBUG: list tags"
git tag -l

if [ "$(git tag -l | wc -l)" = "0" ]; then
        git_tag="v1.0.0"
        request_create_feature_release
else
    new_release=$(cat VERSION)
    echo "DEBUG: new release = $new_release"

    if [ -z "$new_release" ]; then
        echo "no release found. Edit ./VERSION with v\d.\d.\d"
        exit 1
    fi

    last_release=$(git tag -l | sort -n | tail -n 1)
    echo "DEBUG: last release = $last_release"

    testvercomp "$(echo "$new_release" | sort -n | tail -n 1 | cut -c 2-) $(echo "$last_release" | sort -n | tail -n 1 | cut -c 2-)"

    git_tag="$new_release"

    new_release_minor_number=$(echo "$new_release" | sort -n | tail -n 1 | cut -c 2- | cut -d '.' -f3)
    last_release_minor_number=$(echo "$last_release" | sort -n | tail -n 1 | cut -c 2- | cut -d '.' -f3)

    if [ "$new_release_minor_number" -gt "$last_release_minor_number" ]; then
        request_create_bugfix_release
    else
        request_create_feature_release
    fi
fi