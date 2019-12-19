package acme

template: acme: {
	input: description: "source monorepo to deploy"
	output: false

	acmeSettings=settings: hostname: string

	block: frontend: {

		block: build: {
			fromTemplate: "yarn/build"
			input: {
				from:          "../.."
				fromDirectory: "crate/code/web"
			}

			settings: {
				writeEnvFile: ".env"
				loadEnv:      false
				environment: {
					NODE_ENV: "production"
					APP_URL:  "https://\(acmeSettings.hostname)"
				}
				buildDirectory: "public"
				buildScript:    "build:client"
			}
		}

		block: deploy: {
			fromTemplate: "netlify/site"
			settings: createSite: true
			settings: domain:     acmeSettings.hostname
			input: from:          "../build"
		}
	}
	block: api: {
		// ...
	}
}

// BLOCKS:

// cd monorepo && bl push staging
// (either manually or from github action)
block: staging: {
	fromTemplate: "acme"
	settings: hostname: "staging.acme.infralabs.io"
	block: frontend: block: deploy: settings: siteName: "acme-staging"
	block: frontend: block: deploy: keychain: token:    "FIXME"
}
