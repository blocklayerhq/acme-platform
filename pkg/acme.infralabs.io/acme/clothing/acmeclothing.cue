package clothing

clothing: {

	address: _
	slug: _
	
	settings: {
		apiAddress: *"api.\(address)"|string
	}
	
	components: {
		"api/container" address: settings.apiAddress
		"api/db" address: settings.apiAddress
		"api/kube" address: settings.apiAddress
	}

	components: {
		"monorepo": {
			blueprint: "git/repo"
			settings: {
				url: "https://github.com/atulmy/crate.gi"
			}
		}
	
		"web/app": {
			blueprint: "js/app"
			input: {
				from: components.monorepo.output
				fromDir: "code/web"
			}
			settings build: {
				tool: "npm"
				script: "build:client"
				dir: "public"
				envFile: ".env"
				env: {
					NODE_ENV: "production"
					APP_URL: "https://\(address)"
					APP_URL_API: "https://\(clothing.settings.apiAddress)"
				}
			}
		}
		"web/netlify": {
			blueprint: "netlify/site"
			input from: components["web/app"].output
		}
		"api/container": {
			blueprint: "js/container"
			input: {
				from: components.monorepo.output
				fromDir: "code/api"
			}
			settings: {
				tool: "npm"
				build: {
					script: "build:prod"
					dir: "."
				}
				run: {
					script: "start:server"
					env NODE_ENV: "production"
				}
			}
		}
	
		"api/db" blueprint: "mysql/database"
		"api/kube" blueprint: "kubernetes/gke"
	}
}
