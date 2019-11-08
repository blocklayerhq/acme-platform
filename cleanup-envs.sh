#!/bin/sh

set -exu

protected=acme-clothing-staging

cleanup_gke() {
    kubectl get ns | \
        awk -v "p=$protected" '$1 ~ /^bl-/ && $1 != "bl-"p { system("kubectl delete ns " $1); }'
}

cleanup_sql() {
    gcloud sql databases list --instance acme-clothing-store | \
        awk -v "p=$protected" '$1 ~ /^bl-/ && $1 != "bl-"p { system("gcloud -q sql databases delete --instance acme-clothing-store " $1); }'
}

cleanup_netlify() {
    sites=$( \
        curl -s -f -H Authorization:\ Bearer\ $NETLIFY_AUTH_TOKEN 'https://api.netlify.com/api/v1/sites?filter=all' | \
        jq -r '.[] | select(.name | startswith("bl-acme")) | select(.name != "bl-acme-clothing-staging") | .site_id' \
    )

    for site in $sites; do
        curl -i -X DELETE -H Authorization:\ Bearer\ $NETLIFY_AUTH_TOKEN "https://api.netlify.com/api/v1/sites/$site"
    done
}

cleanup_gke
cleanup_sql
cleanup_netlify
