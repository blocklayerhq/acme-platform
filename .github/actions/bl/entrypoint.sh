#!/bin/sh

set -ex

bl line run $BL_PIPELINE -o npm.build.web.src=@./crate/code/web/
