import (
	"b.l/bl"
)

// A single instance of an Acme Clothing application
App :: {
	monorepo: bl.Directory | *bl.EmptyDirectory

	url: frontend.url

	api: Api & {
		container: source: bl.Subdirectory & {
			root: monorepo
			path: "crate/code/api"
		}
	}

	frontend: Frontend & {
		app: source: bl.Subdirectory & {
			root: monorepo
			path: "crate/code/web"
		}
	}
}
