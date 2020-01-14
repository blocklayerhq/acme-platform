
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

	output: false

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

		block: build: {

			from: Yarn

			withSettings: {
				writeEnvFile: ".env"
				loadEnv:      false
				environment: {
					NODE_ENV: "production"
					APP_URL:  "https://\(settings.hostname)"
				}
				buildDirectory: "public"
				buildScript:    "build:client"
			}
		}

		block: deploy: {

			from: Netlify

			withSettings: {
				createSite: true
				domain:     settings.hostname
			}
		}
	}

	block: api: {
		// ...
	}
}
