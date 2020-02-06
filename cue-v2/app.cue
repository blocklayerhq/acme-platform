package acme

import (
	"b.l/bl"
)

// A single instance of an Acme Clothing application
App :: {
	monorepo: bl.Directory | *bl.EmptyDirectory

	url: frontend.url

	api: Api & {
		container: source: (bl.Subdirectory & {input: monorepo, path: "crate/code/api"}).output
	}

	frontend: Frontend & {
		app: source: (bl.Subdirectory & {input: monorepo, path: "crate/code/web"}).output
	}
}
