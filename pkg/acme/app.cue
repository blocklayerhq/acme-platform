package acme

// A single instance of an Acme Clothing application
App :: {
	// Source checkout of acme monorepo (frontend & api)
	monorepo: Directory

	url: frontend.url

	api: Api & {
		container: source: Directory & { root: monorepo, path: "crate/code/api" }
	}

	frontend: Frontend & {
		app: source: Directory & { root: monorepo, path: "crate/code/web" }
	}
}
