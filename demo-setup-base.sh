#!/bin/bash

set -ex

# Create base pipeline

. overrides.base.secret

bl line rm acme-clothing-base || true
bl line create acme-clothing-base -f ./acme-clothing.pipeline
bl line run -d acme-clothing-base "${OVERRIDES[@]}"
