#!/bin/bash

set -ex

bl line rm acme-clothing-base || true
bl line create acme-clothing-base -f ./acme-clothing.pipeline -d "Base Developer Pipeline for ACME"
./blrun acme-clothing-base
