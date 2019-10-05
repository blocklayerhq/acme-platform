package clothing

// Workspace template
clothing: {
	// EXTERNAL REFERENCES
	domain: _

	// COMPONENT LAYOUT
	gates: {
		monorepo blueprint: "git/repo"
		"web/app" blueprint: "js/app"
		"web/netlify" blueprint: "netlify/site"
		"api/app" blueprint: "js/app"
		"api/container" blueprint: "linux/alpine/container"
		"api/kube" blueprint: "kubernetes/gke"
		"api/db" blueprint: "mysql/database"
	}

	// COMPONENT INTERCONNECT
	gates: {
		"web/app" input: { from: gates.monorepo.output, fromDir: "code/web" }
		"web/netlify" input from: gates["web/app"].output
		"api/app" input: { from: gates.monorepo.output, fromDir: "code/api" }
		"api/container" input from: gates["api/app"].output
	}

	// SETTINGS
	settings: {
		webAddress: *domain|string
		apiAddress: *"api.\(webAddress)"|string
	}
	// Convenience alias
	apiAddr=settings.apiAddress
	webAddr=settings.webAddress

	gates: {
		"monorepo" settings url: "https://github.com/atulmy/crate.gi"
		"web/app": {
			settings build: {
				tool: "npm"
				script: "build:client"
				dir: "public"
				envFile: ".env"
				env: {
					NODE_ENV: "production"
					APP_URL: "https://\(webAddr)"
					APP_URL_API: "https://\(apiAddr)"
				}
			}
		}
		"api/app" settings: {
			build: {
				tool: "npm"
				script: "build:prod"
				dir: "."
			}
		}
		"api/container" settings: {
			alpineVersion: [3, 10]

			systemPackages: {
				npm: true
				gcc: true
				"g++": true
				make: true
				python: true
			}
			adhocPackages: [
				["npm", "install", "-g", "nodemon"],
				["npm", "install", "-g", "babel-cli"],
			]
			env NODE_ENV: "production"
			appRun: ["npm", "run", "start:server"]
		}
	}

	// COMPONENT ADDRESS
	gates: {
		"web/app" address: webAddr
		"web/netlify" address: webAddr
		"api/app" address: apiAddr
		"api/container" address: apiAddr
		"api/db" address: apiAddr
		"api/kube" address: apiAddr
	}
}
