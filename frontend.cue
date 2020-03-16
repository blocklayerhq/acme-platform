package main

import (
	"stackbrew.io/yarn"
	"stackbrew.io/netlify"
)

AcmeFrontend :: {
	hostname: string
	url: "https://\(hostname)"

	app: yarn.App & {
		writeEnvFile: ".env"
		loadEnv:      false
		environment: {
			NODE_ENV: "production"
			APP_URL:  "https://\(hostname)"
		}
		buildDirectory: "public"
		yarnScript: "build:client"
	}

	netlifyAccount: netlify.Account

    // Netlify site hosting the webapp
	site: netlify.Site & {
		account: netlifyAccount
		contents: app.build
		create: *true | bool
		domain: hostname
	}
}
