#!/bin/sh

set -ex

find ./crate/code/web

bl line run $BL_PIPELINE -o npm.build.web.src=@./crate/code/web/ -o fs.write_text.web_api_url.text=https://localhost:4242
