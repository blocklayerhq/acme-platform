#!/bin/bash

set -ex

# Create base pipeline

OVERRIDES=()

. overrides.base.secret
. overrides.staging.secret

bl line rm acme-clothing-staging || true
bl line create acme-clothing-staging -f ./acme-clothing.pipeline
bl line run -d acme-clothing-staging "${OVERRIDES[@]}"
