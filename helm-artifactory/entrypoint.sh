#!/usr/bin/env bash

set -o errexit
set -o pipefail

package() {
  helm init --client-only
  helm lint ${CHART}
  helm package ${CHART}
}

AF_API_USER=$1
AF_URL=$2
AF_REPOSITORY=$3
CHART=$4

REPOSITORY="https://${AF_API_USER}:${AF_API_TOKEN}@${AF_URL}/${AF_REPOSITORY}"

if [[ -z $1 ]]; then
  echo "No Artifactory API user specified!" && exit 1
fi

if [[ -z $2 ]]; then
  echo "Artifactory URL parameter needed!" && exit 1
fi

if [[ -z $3 ]]; then
  echo "Helm chart repository not specified!" && exit 1
fi

if [[ -z $4 ]]; then
  echo "Chart path parameter needed!" && exit 1
fi

exit 0
