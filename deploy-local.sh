#!/bin/bash

OVERRIDES=() && . _runtime_overrides.microstaging.secret && bl-runtime run --no-versioning --workdir=/tmp/bl -f ./acme-clothing.pipeline "${OVERRIDES[@]}" -o npm.build.web.src=FSTREE:./crate/code/web -t npm.build.web 2>&1 | jq -r 'select(.level == "error" or .log_output == "stdout" or .log_output == "stderr" or .level == "fatal") | .level + " " + .bot_id + ": " + .message + .error'

