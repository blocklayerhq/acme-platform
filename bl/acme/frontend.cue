package acme

import (
	"strings"

	"stackbrew.io/yarn"
	"acme.infralabs.io/netlify"
)

// Web frontend of an ACME clothing app
Frontend :: {
	// Hostname of the frontend
	hostname: string

	// Hostname of the API backend
	apiHostname: string

	// Frontend source code to deploy
	source: directory

	jsApp: yarn.App & {
		"source":     source
		writeEnvFile: ".env"
		loadEnv:      false
		environment: {
			NODE_ENV:    "production"
			APP_URL:     url
			APP_URL_API: "https://\(apiHostname)"
		}
		buildDirectory: "public"
		yarnScript:     "build:client"
	}

	netlifyAccount: netlify.Account & {
		name: "blocklayer"
	}

	// Netlify site hosting the webapp
	site: netlify.Site & {
		name:     string | *strings.Replace(hostname, ".", "-", -1)
		account:  netlifyAccount
		contents: jsApp.build
		create:   *true | bool
		domain:   hostname
	}

	url: "https://\(hostname)"
}
