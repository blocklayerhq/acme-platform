
// A single instance of an Acme Clothing application
App :: {
	// Monorepo to deploy
	Input: {
		optional: false
		pipeline: [
			{
				action: "copy"
				to: frontend
				sourcePath: "crate/code/web"
			}
		]
	}

	hostname: string

	frontend: {
		Input: {
			optional: false
			pipeline: [build, deploy]
		}

		build: Yarn & {
			writeEnvFile: ".env"
			loadEnv:      false
			environment: {
				NODE_ENV: "production"
				APP_URL:  "https://\(hostname)"
			}
			buildDirectory: "public"
			buildScript:    "build:client"
			
		}

		deploy: Netlify & {
			createSite: true
			domain:     hostname
		}
	}
}
