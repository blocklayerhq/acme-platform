package main

env: staging: {

	input: {
		// Source code to deploy
		// NOTE: must be an entire monorepo
		source: directory
	}

	output: {
		"Staging URL":     block.deploy.web.url
		"Staging API URL": block.deploy.api.url
	}

	block: deploy: env.devInfra.Deployment & {
		source: input.source
		web: hostname: "staging.acme.infralabs.io"
		api: hostname: "staging.acme-api.infralabs.io"
		web: site: name: "acme-staging"
	}
}
