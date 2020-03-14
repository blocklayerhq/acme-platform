#!/bin/bash

set -eu

. ./creds.secret

kubeconfig=$(base64 < ./infra/eks/kube-config/kubeconfig_bl-demo-eks.secret)
accessKey=$(echo "$AWS_ACCESS_KEY_ID" | base64)
secretKey=$(echo "$AWS_SECRET_ACCESS_KEY" | base64)
dbUsername=$(echo "$DB_USERNAME" | base64)
dbPassword=$(echo "$DB_PASSWORD" | base64)

bl-runtime run \
    -v staging.api.kubeAuthConfig.value="$kubeconfig" \
    -v staging.api.awsConfig.accessKey.value="$accessKey" \
    -v staging.api.awsConfig.secretKey.value="$secretKey" \
    -v staging.api.dbConfig.adminUsername.value="$dbUsername" \
    -v staging.api.dbConfig.adminPassword.value="$dbPassword"
