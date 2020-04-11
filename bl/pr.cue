package main

// Environment to deploy a full review environment for each pull request on the monorepo,
// then post its URL as a comment on the pull request.

env: prReview: {

	monorepo=env.devInfra.config.monorepo
	lastPRnumber: monorepo.lastPRnumber

	deployLast: env.devInfra.Deployment & {
		name: "pr-\(lastPRnumber)"
		source: env.staging.input.source
	}

	output: {
		"\(lastPRnumber)": {
			url: deployLast.web.url
			api_url: deployLast.api.url
		}
	}
}
