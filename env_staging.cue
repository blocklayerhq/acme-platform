package main

env: staging: {

	input: {
		// Source code to deploy
		// NOTE: must be an entire monorepo
		source: directory
	}

	output: {
		"Staging URL":     config.deploy.web.url
		"Staging API URL": config.deploy.api.url
	}

	config: deploy: env.devInfra.Deployment & {
		source: input.source
		web: hostname: "staging.acme.infralabs.io"
		api: hostname: "staging.acme-api.infralabs.io"
		web: site: name: "acme-staging"
	}
}
