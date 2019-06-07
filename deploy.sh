#!/bin/bash

set -ex

if [ "$LOCAL" ]; then
	echo "---> Building from local repositories"
	./blrun -o fs.write_text.web_node_env.src=@./crate/code/web/ "$@"
else
	echo "---> Building from upstream repositories"
	./blrun "$@"
fi
