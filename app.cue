package main

import (
	"b.l/bl"
)

// A single instance of an Acme Clothing application
AcmeApp :: {
	// Source checkout of acme monorepo (frontend & api)
	monorepo: bl.Directory

	url: frontend.url

	// FIXME: API temporarily disabled until frontend is solid on alpha-3
	// api: AcmeApi & {
	// 	container: source: bl.Directory & { from: monorepo, path: "crate/code/api" }
	// }

	frontend: AcmeFrontend & {
		app: source: bl.Directory & { from: monorepo, path: "crate/code/web" }
	}
}
