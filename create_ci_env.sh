#!/usr/bin/env bash

set -e

fail_with_message() {
  echo "$*"
  exit 1
}

HUMANITEC_TOKEN=$1
[[ -n $HUMANITEC_TOKEN ]] || fail_with_message "Humanitec token required as arg 1"

CI_ENV_ID=$2
[[ -n $CI_ENV_ID ]] || fail_with_message "CI_ENV_ID required as arg 2"


# fetch last deployment id
BASE_ENV=uat
LAST_DEPLOY_ID=$(curl -fSs --header "Authorization: Bearer $HUMANITEC_TOKEN" https://api.humanitec.io/orgs/htc-demo-04/apps/ginger/envs/$BASE_ENV | jq -r '.last_deploy.id')

export LAST_DEPLOY_ID BASE_ENV CI_ENV_ID

curl -fSs -X POST --data @- --header "Authorization: Bearer $HUMANITEC_TOKEN" https://api.humanitec.io/orgs/htc-demo-04/apps/ginger/envs << EOF
{
  "from_deploy_id": "$LAST_DEPLOY_ID",
  "id": "$CI_ENV_ID",
  "type": "development",
  "name": "Ephemeral CI env for application ginger"
}
EOF