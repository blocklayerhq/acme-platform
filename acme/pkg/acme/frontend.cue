package acme

import (
	"yarnpkg.com/yarn"
	ntlfy "netlify.com/netlify"
	"strings"
)

value : string | int
message: string

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
		yarnScript: "build:client"
	}

	netlify: ntlfy.Account

    // Netlify site hosting the webapp
	site: netlify.Site & {
		contents: app.build
		create: *true | bool
		domain: hostname
	}
}

