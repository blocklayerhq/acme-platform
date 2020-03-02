#!/bin/bash

# Update vendored dependencies

set \
	-o nounset \
	-o errexit

function main() {
	[ -d cue.mod ] || fatal "No cue.mod/ in current directory"

	if [ -d cue.mod/pkg/stackbrew.io ]; then
		rm -fr cue.mod/pkg/stackbrew.io/*
	else
		mkdir -p cue.mod/pkg/stackbrew.io
	fi

	curl \
		-L \
		https://github.com/stackbrew/stackbrew/archive/master.tar.gz \
	| tar \
		-C cue.mod/pkg/stackbrew.io \
		--strip-components=2 \
		-zxv
}

function fatal() {
	echo >&2 "$@"
	exit 1
}

main "$@"
