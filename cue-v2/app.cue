package acme

import (
	"b.l/bl"
)

// A single instance of an Acme Clothing application
App :: {
	monorepo: bl.Directory

	url: frontend.url

	api: Api & {
		container: source: bl.Directory & { root: monorepo, path: "crate/code/api" }
	}

	frontend: Frontend & {
		app: source: bl.Directory & { root: monorepo, path: "crate/code/web" }
	}
}
