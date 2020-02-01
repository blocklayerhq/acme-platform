package main

import (
	"bl.templates/yarn"
	"bl.templates/netlify"
)

// A single instance of an Acme Clothing application
App :: Block & {
    settings: hostname: string

	input: true

	connection: [
		// Connect my own input to "frontend"
		{
			fromDir: "crate/code/web"
			to:      "frontend"
		},
	]

	block: frontend: Block & {
		connection: [
			// Connect my own input to "build"
			{
				from: "."
				to:   "build"
			},
			// Connect "build" output to "deploy"
			{
				from: "build"
				to:   "deploy"
			},
		]
		block: {
			hostname = settings.hostname
			
            build: Block & yarn & {
				settings: {
					writeEnvFile: ".env"
					loadEnv:      false
					environment: {
						NODE_ENV: "production"
						APP_URL:  "https://\(hostname)"
					}
					buildDirectory: "public"
					buildScript:    "build:client"
				}
			}
			deploy: Block & netlify & {
				settings: {
					createSite: true
					domain:     hostname
				}
			}
		}
	}
}
