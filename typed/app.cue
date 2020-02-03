import (
	"yarnpkg.com/yarn"
	"netlify.com/netlify"
	"b.l/bl"
)

// A single instance of an Acme Clothing application
App :: {
	monorepo: bl.Directory | *bl.EmptyDirectory
	hostname: string
	api: {
		container: {}
		registry: {}
		kub: {}
		db: {}
	}
	frontend: {
		app: yarn.App & {
			// source: monorepo.subdirectory & { path: "crate/code/web" }
			source: monorepo
			writeEnvFile: ".env"
			loadEnv:      false
			environment: {
				NODE_ENV: "production"
				APP_URL:  "https://\(hostname)"
			}
			buildDirectory: "public"
			buildScript:    "build:client"
		}

		deploy: netlify.Site & {
			artifact: app.build
			createSite: true
			domain:     hostname
		}
	}
}
