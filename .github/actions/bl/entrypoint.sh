#!/bin/sh

set -ex

bl line run $BL_PIPELINE -o $BL_INPUT_OVERRIDE=$GITHUB_SHA
