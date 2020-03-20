package main

import (
	"stackbrew.io/github"
)


// Integrate with Github to get PR information
env: devtools: {

	input: {
		// Github API token
		githubToken: secret

		// Owner of the github repo
		githubRepoOwner: string | *"blocklayerhq"

		// Name of the github repo
		githubRepoName: string | *"acme-clothing"

		// Top-level domain for all web endpoints
		devDomain: string | *"dev.acme.infralabs.io"

		// Top-level domain for all api endpoints
		devApiDomain: string | *"dev.acme-api.infralabs.io"
	}

	config: {
		monorepo: github.Repository & {
			token: input.githubToken
			owner: input.githubRepoOwner
			name: input.githubRepoName
		}
	}
}


// Dynamically create an environment for each PR
for prID, pr in env.devtools.config.monorepo.pr {

	env: "pr-\(prID)": {

		config: {
			domain: env.devtools.input.devDomain
			apiDomain: env.devtools.input.devApiDomain

			api: AcmeAPI & {
				hostname: "pr-\(prID).\(apiDomain)"
			}
			frontend: AcmeFrontend & {
				hostname: "pr-\(prID).\(domain)"
				apiHostname: api.hostname
				site: name: "acme-pr-\(prID)"
				app: source: directory & {
					from: pr.branch.tip.checkout
				}
			}
		}

		output: {

			// Frontend URL
			url: config.frontend.url

			// API URL
			apiUrl: config.api.url
		}
	}
}
