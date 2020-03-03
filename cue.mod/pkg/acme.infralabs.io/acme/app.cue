package acme

import (
	"b.l/bl"
)

// A single instance of an Acme Clothing application
App :: {
	// Source checkout of acme monorepo (frontend & api)
	monorepo: bl.Directory

	url: frontend.url

	api: Api & {
		container: source: bl.Directory & { from: monorepo, path: "crate/code/api" }
	}

	frontend: Frontend & {
		app: source: bl.Directory & { from: monorepo, path: "crate/code/web" }
	}
}
