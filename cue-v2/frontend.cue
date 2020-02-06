package acme

import (
	"yarnpkg.com/yarn"
	ntlfy "netlify.com/netlify"
)

Frontend :: {
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
		buildScript:    "build:client"
	}

	netlify: ntlfy.Account

	site: netlify.Site & {
		contents: app.build
		create: *true | bool
		domain: hostname
	}
}
