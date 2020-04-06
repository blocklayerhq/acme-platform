package main

// Environment to deploy a full review environment for each pull request on the monorepo,
// then post its URL as a comment on the pull request.

env: prReview: {

	output: {
		for prID, d in config {
			"PR \(prID) web": d.web.url
			"PR \(prID) API": d.api.url
		}
	}

	config: {
		// Deploy a complete dev stack from each pull request,
		// for review and integration testing.
		for prID, pr in env.devInfra.config.monorepo.pr {
			"\(prID)": env.devInfra.Deployment & {
				name:   "pr\(prID)"
				source: pr.branch.tip.checkout
			}
		}
	}
	// FIXME: post a comment on the pull request
}
