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

	tmp="$(mktemp -d)"
	curl \
		-L \
		https://github.com/stackbrew/stackbrew/archive/master.tar.gz \
	| tar \
		-C "$tmp" \
		--strip-components=1 \
		-zx

	rsync --delete -aH "$tmp/pkg/" cue.mod/pkg/stackbrew.io/
	git add cue.mod/pkg/stackbrew.io/
	rm -fr "$tmp"
}

function fatal() {
	echo >&2 "$@"
	exit 1
}

main "$@"
