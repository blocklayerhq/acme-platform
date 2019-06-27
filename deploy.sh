#!/bin/bash

set -ex

if [ "$LOCAL" ]; then
	echo "---> Building from local repositories"
	./blrun -o frontend_src=@./crate/code/web/ "$@"
else
	echo "---> Building from upstream repositories"
	./blrun "$@"
fi
