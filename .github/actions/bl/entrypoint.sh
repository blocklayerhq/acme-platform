#!/bin/sh

set -ex

bl line run acme-clothing-staging -o frontend_src=@./crate/code/web/
