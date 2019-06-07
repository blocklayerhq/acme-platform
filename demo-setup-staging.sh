#!/bin/bash

set -ex

bl line rm acme-clothing-staging || true
bl line create acme-clothing-staging -f ./acme-clothing.pipeline -d "ACME Staging Pipeline"
./blrun acme-clothing-staging
