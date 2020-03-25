package main

// Environment to deploy a full review environment for each pull request on the monorepo,
// then post its URL as a comment on the pull request.

env: prReview: {

	output: {
		for prID, d in block.deployment {
			"PR \(prID) web": d.webUrl
			"PR \(prID) API": d.apiUrl
		}
	}

	block: {
		// Deploy a complete dev stack from each pull request,
		// for review and integration testing.
		for prID, pr in env.devInfra.block.monorepo.pr {
			"\(prID)": env.devInfra.Deployment & {
				name:   "pr\(prID)"
				source: pr.branch.tip.checkout
			}
		}
	}
	// FIXME: post a comment on the pull request
}
