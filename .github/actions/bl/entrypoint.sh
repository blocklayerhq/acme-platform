#!/bin/sh

set -ex

bl line run $BL_PIPELINE -o fs.write_text.web_node_env.src=@./crate/code/web/
