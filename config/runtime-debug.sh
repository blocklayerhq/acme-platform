#!/bin/bash

set -eu

export BL_TARGET=bl-registry:5001/acme:test

. ./creds.secret

monorepoPath="../../acme-clothing"
kubeconfig=$(base64 < ../infra/eks/kube-config/kubeconfig_bl-demo-eks.secret)
accessKey=$(echo "$AWS_ACCESS_KEY_ID" | base64)
secretKey=$(echo "$AWS_SECRET_ACCESS_KEY" | base64)
dbUsername="$(echo $DB_USERNAME | base64)"
dbPassword="$(echo $DB_PASSWORD | base64)"
netlifyToken="$(echo -n "$NETLIFY_TOKEN" | base64)"

bl-runtime run \
    -v env.staging.input.monorepo.local="$monorepoPath" \
    -v env.staging.input.netlifyToken.value="$netlifyToken" \
    -v env.staging.input.kubeAuthConfig.value="$kubeconfig" \
    -v env.staging.input.awsAccessKey.value="$accessKey" \
    -v env.staging.input.awsSecretKey.value="$secretKey" \
    -v env.staging.input.dbAdminUser.value="$dbUsername" \
    -v env.staging.input.dbAdminPassword.value="$dbPassword" \
    -v env.staging.input.netlifyTeam=""
