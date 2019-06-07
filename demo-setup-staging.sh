#!/bin/bash

set -ex

# Create base pipeline

. .overrides.base.secret
. .overrides.staging.secret

bl line rm acme-clothing-staging || true
bl line create acme-clothing-staging -f ./acme-clothing.pipeline -d "ACME Staging Pipeline"
bl line run -d acme-clothing-staging "${OVERRIDES[@]}"
