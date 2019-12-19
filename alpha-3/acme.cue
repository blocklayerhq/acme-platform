package acme

// cd monorepo && bl push staging
// (either manually or from github action)
block: staging: {
	input: description: "acme staging config"
	output: false

	acmeSettings=settings: {
		hostname: "staging.acme.infralabs.io"
	}

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
				siteName: 		"acme-staging"
			}

			keychain: token: "FIXME"
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
