#!/bin/bash

set -ex

if [ -z "$1" ]; then
	echo >&2 Unspecified pipeline name
	exit 1
fi

. overrides.microstaging.secret

if [ "$LOCAL" ]; then
	echo "---> Building from local repositories"
	OVERRIDES+=(
		-o fs.write_text.web_node_env.src=@./crate/code/web/
	)
else
	echo "---> Building from upstream repositories"
fi

pipeline="$1"
shift

bl line run -d "$pipeline" "${OVERRIDES[@]}" "$@"
