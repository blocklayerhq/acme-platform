package main

import (
	"b.l/bl"
)

// A single instance of an Acme Clothing application
AcmeApp :: {
	// Source checkout of acme monorepo (frontend & api)
	monorepo: bl.Directory

	url: frontend.url

	api: AcmeAPI

	frontend: AcmeFrontend & {
		app: source: bl.Directory & { from: monorepo, path: "crate/code/web" }
	}
}
