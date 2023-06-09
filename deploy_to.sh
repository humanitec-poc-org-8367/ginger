#!/usr/bin/env bash

set -e

fail_with_message() {
  echo $*
  exit 1
}

HUMANITEC_ORG=$1
[[ -n $HUMANITEC_ORG ]] || fail_with_message "deploy_to: Must provide Humanitec Org as parameter 1"

HUMANITEC_SECRET=$2
[[ -n $HUMANITEC_SECRET ]] || fail_with_message "deploy_to: Must provide Humanitec Token as parameter 2"

TARGET_ENV=$3
[[ -n $TARGET_ENV ]] || fail_with_message "deploy_to: Must provide target deployment environemnt as parameter 3"

wget https://github.com/score-spec/score-humanitec/releases/download/0.4.0/score-humanitec_0.4.0_linux_amd64.tar.gz
tar -xvzf ./score-humanitec_0.4.0_linux_amd64.tar.gz

cat <<EOF > humanitec.score.yaml
apiVersion: humanitec.org/v1b1
spec:
  ingress:
    rules:
      "\${resources.dns}": # This is the DNS record that we defined in the resources section
        http:
          "/":
            type: prefix
            port: 80
containers:
  frontend:
    image: $ECR/$IMAGE:$TAG
    variables:
      GITHUB_SHA: $GITHUB_SHA
EOF


echo Create delta for deployment
DELTA_ID=$(./score-humanitec delta --env $TARGET_ENV --overrides ./humanitec.score.yaml --app ginger --org="$HUMANITEC_ORG" --token "$HUMANITEC_SECRET" | jq -r '.id')
curl  -f -X PATCH --header "Authorization: Bearer $HUMANITEC_SECRET" https://api.humanitec.io/orgs/htc-demo-04/apps/ginger/deltas/$DELTA_ID \
  --header 'Content-Type: application/json' \
  --data-raw '[{
                "modules": {
                  "update": {
                    "ginger": [{
                      "op": "add",
                      "path": "/deploy",
                      "value": {
                        "success": "available",
                        "timeout": 300
                      }
                    }]
                  }
                }
              }]'

DEPLOY_ID=$(curl -f -X POST --header "Authorization: Bearer $HUMANITEC_SECRET" https://api.humanitec.io/orgs/htc-demo-04/apps/ginger/envs/$TARGET_ENV/deploys \
  --header 'Content-Type: application/json' \
  --data-raw '{ "comment": "Deploy delta from score", "delta_id": "'$DELTA_ID'" }')

echo Awaiting deployment completion
while [ $ATTEMPTS -lt 160 ] ; do
  DEPLOY_STATUS=$(curl -f -X POST --header "Authorization: Bearer $HUMANITEC_SECRET" https://api.humanitec.io/orgs/htc-demo-04/apps/ginger/envs/$TARGET_ENV/deploys/$DEPLOY_ID | jq -r '.status')
  [[ $DEPLOY_STATUS == "succeeded" ]] && break
  [[ $DEPLOY_STATUS == "failed" ]] && break
  echo $DEPLOY_STATUS
  sleep 2
done
