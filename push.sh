#!/bin/bash

set \
	-o errexit \
	-o nounset

DOMAIN="${1:?undefined domain}"
MONOREPO="${2:?undefined monorepo path}"
DRAFT="$DOMAIN-$RANDOM-$RANDOM"

bl draft init "$DRAFT"

read -s -r -p "Enter netlify API token: " NETLIFY_TOKEN
bl push "$DOMAIN" --draft "$DRAFT" -k text -t staging.frontend.netlifyAccount.token.value "$NETLIFY_TOKEN"

bl push "$DOMAIN" --draft "$DRAFT" .
bl push "$DOMAIN" --draft "$DRAFT" -t staging.monorepo "$MONOREPO"


bl draft apply "$DRAFT"
