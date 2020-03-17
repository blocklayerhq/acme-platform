#!/bin/bash

set \
	-o errexit \
	-o nounset

. ./creds.secret

kubeconfig=$(base64 < ../infra/eks/kube-config/kubeconfig_bl-demo-eks.secret)
accessKey=$(echo "$AWS_ACCESS_KEY_ID" | base64)
secretKey=$(echo "$AWS_SECRET_ACCESS_KEY" | base64)
dbUsername="$DB_USERNAME"
dbPassword="$DB_PASSWORD"
netlifyToken="$(echo -n "$NETLIFY_TOKEN" | base64)"

DOMAIN="${1:?undefined domain}"
MONOREPO="${2:?undefined monorepo path}"
DRAFT="$DOMAIN-$RANDOM-$RANDOM"

bl draft init "$DRAFT"

bl push "$DOMAIN" --draft "$DRAFT" -k text -t staging.frontend.netlifyAccount.token.value "$netlifyToken"
bl push "$DOMAIN" --draft "$DRAFT" -k text -t staging.api.kubeAuthConfig.value "$kubeconfig"
bl push "$DOMAIN" --draft "$DRAFT" -k text -t staging.api.awsConfig.accessKey.value "$accessKey"
bl push "$DOMAIN" --draft "$DRAFT" -k text -t staging.api.awsConfig.secretKey.value "$secretKey"
bl push "$DOMAIN" --draft "$DRAFT" -k text -t staging.api.dbConfig.adminUsername "$dbUsername"
bl push "$DOMAIN" --draft "$DRAFT" -k text -t staging.api.dbConfig.adminPassword "$dbPassword"

bl push "$DOMAIN" --draft "$DRAFT" .
bl push "$DOMAIN" --draft "$DRAFT" -t staging.monorepo "$MONOREPO"

bl draft apply "$DRAFT"
