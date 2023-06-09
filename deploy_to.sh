#!/usr/bin/env bash

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
  deploy:
    success: available
containers:
  frontend:
    image: $ECR/$IMAGE:$TAG
    variables:
      GITHUB_SHA: $GITHUB_SHA
EOF

echo Deploying ginger to $TARGET_ENV
./score-humanitec delta --env $TARGET_ENV --overrides ./humanitec.score.yaml --app ginger --org="$HUMANITEC_ORG" --token "$HUMANITEC_SECRET" --deploy
