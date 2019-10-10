#!/bin/bash

set -eu

blx() {
	# bash -x ./blx "$@"
	./blx "$@"
}

blx island destroy || true
blx island install
blx env create acme
blx component install acme monorepo git/repo
