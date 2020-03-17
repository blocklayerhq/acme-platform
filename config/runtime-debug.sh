#!/bin/bash

set -eu

export BL_TARGET=bl-registry:5001/acme:test

. ./creds.secret

kubeconfig=$(base64 < ./infra/eks/kube-config/kubeconfig_bl-demo-eks.secret)
accessKey=$(echo "$AWS_ACCESS_KEY_ID" | base64)
secretKey=$(echo "$AWS_SECRET_ACCESS_KEY" | base64)
dbUsername="$DB_USERNAME"
dbPassword="$DB_PASSWORD"
netlifyToken="$(echo -n "$NETLIFY_TOKEN" | base64)"

bl-runtime run \
    -v staging.frontend.netlifyAccount.token.value="$netlifyToken" \
    -v staging.api.kubeAuthConfig.value="$kubeconfig" \
    -v staging.api.awsConfig.accessKey.value="$accessKey" \
    -v staging.api.awsConfig.secretKey.value="$secretKey" \
    -v staging.api.dbConfig.adminUsername="$dbUsername" \
    -v staging.api.dbConfig.adminPassword="$dbPassword"
