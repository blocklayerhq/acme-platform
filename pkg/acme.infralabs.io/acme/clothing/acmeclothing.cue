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
			components app: {
				settings build: {
					tool: "npm"
					script: "build:prod"
					dir: "."
					env NODE_ENV: "production"
				}
			}
			

env NODE_ENV: "production"
				appInstall: [
					["npm", "install"],
					["npm", "run", "build:prod"]
				]
				appRun: ["npm", "run", "start:server"]
			}
		}
	
		"api/db" blueprint: "mysql/database"
		"api/kube": blueprint: "kubernetes/gke"
	}
