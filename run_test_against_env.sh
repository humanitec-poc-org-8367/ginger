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
[[ $CI_ENV_ID == "${CI_ENV_ID:0:20}" ]] || fail_with_message "CI_ENV_ID must be no more than 20 characters"


echo -n "Retrieve the DNS name of $CI_ENV_ID "
ATTEMPTS=0
while [ $ATTEMPTS -lt 90 ] ; do
  sleep 2
  echo -n .
  APP_URL=$(curl -fSs https://api.humanitec.io/orgs/htc-demo-04/apps/ginger/envs/$CI_ENV_ID/resources \
    --header "Authorization: Bearer $HUMANITEC_TOKEN" | \
    jq -r --arg id "modules.ginger.externals.dns" '.[] | select(.res_id == $id and .type == "dns").resource.host')
  ATTEMPTS=ATTEMPTS+1
  [[ -n "$APP_URL" ]] && break
done
echo " done"
export APP_URL


if [[ -n "$APP_URL" ]]; then
  echo Running tests against URL $APP_URL
  # presumably there is a race condition here, as we need to wait for Humanitec to finish deploying our app
  npm run test
else
  echo failed to fetch APP_URL after $ATTEMPTS attempts
  exit 1
fi