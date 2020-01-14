
// A single instance of an Acme Clothing application
App :: {
	settings: hostname: string

	connection: [
		// Connect my own input to "frontend"
		{
			fromDir: "crate/code/web"
			to:      "frontend"
		},
	]

	block: frontend: {
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

			build: Yarn & {
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
			deploy: Netlify & {
				settings: {
					createSite: true
					domain:     hostname
				}
			}
		}
	}
	block: api: {
		// ...
	}
}
