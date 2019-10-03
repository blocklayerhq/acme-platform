package clothing

address web description: "Acme Clothing website"
address api: {
	description: "Acme Clothing API"
	host?: "api.\(address.web.host)"
}


components: {
	"monorepo": {
		blueprint: "git/repo"
		settings: {
			url: "https://github.com/atulmy/crate.gi"
		}
	}

	"web/app": {
		blueprint: "mysql/database"
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
				APP_URL: "https://\(address.web.host)"
				APP_URL_API: "https://\(address.api.host)"
			}
		}
	}
	"web/netlify": {
		blueprint: "netlify/site"
		input from: components["web/app"].output
		settings: {
			siteName: address.web.slug
			customDomain: address.web
		}
	}
	"api/container": {
		blueprint: "linux/alpine/container"
		input: {
			from: components.monorepo.output
			fromDir: "code/api"
		}
		settings: {
			registry: string
			pushTo: {
				name: "\(settings.registry)/\(address.api.slug)"
				tag: input.from
			}
			alpineVersion: [3, 10]
			packages: {
				npm: {
					nodemon: {}
					"babel-cli": {}
				}
				gcc: {}
				"g++": {}
				make: {}
				python: {}
			}
			env NODE_ENV: "production"
			appDir: "/src"
			appInstall: """
				run npm install
				run npm run build:prod
				"""
			cmd: ["npm", "run", "start:server"]
		}
	}

	"api/db": {
		blueprint: "mysql/database"
		settings dbName: address.api.slug
	}

	"api/kube": {
		blueprint: "kubernetes/gke"
		settings namespace: address.api.slug
	}
}
