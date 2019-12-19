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

// bl push dev/samalba-red-button
block: dev: block: [sandboxName=string]: {
	fromTemplate: "acme"
	settings: hostname: "\(sandboxName).dev.acme.infralabs.io"
	block: frontend: block: deploy: settings: siteName:   "acme-dev-\(sandboxName)"
	block: frontend: block: deploy: settings: createSite: true
	block: frontend: block: deploy: keychain: token:      "FIXME"
}

// on: pr-create:
// checkout
// bl push pr/pr-21
block: pr: block: [prNumber=string]: {
	fromTemplate: "acme"
	settings: hostname: "\(prNumber).pr.acme.infralabs.io"
	block: frontend: block: deploy: settings: siteName:   "acme-pr-\(prNumber)"
	block: frontend: block: deploy: settings: createSite: true
	block: frontend: block: deploy: keychain: token:      "FIXME"
}
